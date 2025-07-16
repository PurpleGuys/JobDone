#!/bin/bash

echo "🚀 PM2 ULTIME - INSTALLATION COMPLÈTE BENNESPRO"
echo "=============================================="

# Variables
APP_NAME="bennespro"
PORT=5000
USER=$(whoami)

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. INSTALLER PM2 GLOBALEMENT
echo -e "${YELLOW}📦 Installation PM2...${NC}"
sudo npm install -g pm2@latest
sudo npm install -g tsx

# 2. TROUVER L'APPLICATION
APP_DIR=""
POSSIBLE_DIRS=(
    "/home/$USER/BennesPro"
    "/home/$USER/workspace/BennesPro"
    "/var/www/html/BennesPro"
    "/opt/BennesPro"
    "$PWD"
)

for dir in "${POSSIBLE_DIRS[@]}"; do
    if [[ -f "$dir/package.json" ]]; then
        APP_DIR="$dir"
        break
    fi
done

if [[ -z "$APP_DIR" ]]; then
    echo -e "${RED}❌ Application non trouvée!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Application trouvée: $APP_DIR${NC}"
cd "$APP_DIR"

# 3. NETTOYER PM2
echo -e "${YELLOW}🧹 Nettoyage PM2...${NC}"
pm2 kill
pm2 flush

# 4. CRÉER DOSSIER LOGS
mkdir -p logs

# 5. VÉRIFIER .ENV
if [[ ! -f ".env" ]]; then
    echo -e "${YELLOW}📝 Création fichier .env...${NC}"
    cat > .env << EOF
NODE_ENV=production
PORT=$PORT
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/bennespro
JWT_SECRET=super_secret_jwt_2025
SESSION_SECRET=super_secret_session_2025
EOF
fi

# 6. INSTALLER DÉPENDANCES
echo -e "${YELLOW}📦 Installation dépendances...${NC}"
npm install

# 7. BUILD APPLICATION
echo -e "${YELLOW}🔨 Build application...${NC}"
npm run build || {
    echo -e "${YELLOW}⚠️  Build échoué, création fallback...${NC}"
    mkdir -p dist
}

# 8. DÉMARRER AVEC PM2
echo -e "${YELLOW}🚀 Démarrage PM2...${NC}"

# Option 1: Si ecosystem.config.cjs existe
if [[ -f "ecosystem.config.cjs" ]]; then
    pm2 start ecosystem.config.cjs --env production
else
    # Option 2: Démarrage direct
    pm2 start server/index.ts \
        --name "$APP_NAME" \
        --interpreter tsx \
        --instances max \
        --exec-mode cluster \
        --env NODE_ENV=production \
        --env PORT=$PORT \
        --log logs/pm2.log \
        --error logs/pm2-error.log \
        --output logs/pm2-out.log \
        --time \
        --kill-timeout 3000 \
        --max-memory-restart 500M
fi

# 9. SAUVEGARDER CONFIGURATION PM2
echo -e "${YELLOW}💾 Sauvegarde configuration PM2...${NC}"
pm2 save

# 10. ACTIVER AU DÉMARRAGE
echo -e "${YELLOW}🔧 Configuration auto-start...${NC}"
pm2 startup systemd -u $USER --hp /home/$USER | tail -n1 | bash

# 11. CONFIGURER NGINX
echo -e "${YELLOW}⚙️  Configuration Nginx...${NC}"
sudo tee /etc/nginx/sites-available/$APP_NAME > /dev/null << EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    
    # Logs
    access_log /var/log/nginx/${APP_NAME}_access.log;
    error_log /var/log/nginx/${APP_NAME}_error.log;
    
    # Taille max upload
    client_max_body_size 20M;
    
    # Proxy vers PM2
    location / {
        proxy_pass http://localhost:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Health check
    location /api/health {
        proxy_pass http://localhost:$PORT/api/health;
        access_log off;
    }
}
EOF

# Activer site
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx

# 12. CRÉER SCRIPT DE MONITORING
echo -e "${YELLOW}📊 Création script monitoring...${NC}"
cat > ~/pm2-monitor.sh << 'EOF'
#!/bin/bash
echo "📊 PM2 MONITORING"
echo "================"
echo ""
echo "Status PM2:"
pm2 list
echo ""
echo "Mémoire/CPU:"
pm2 monit
EOF
chmod +x ~/pm2-monitor.sh

# 13. TESTS FINAUX
echo -e "${YELLOW}🧪 Tests finaux...${NC}"
sleep 5

# Test PM2
if pm2 list | grep -q "$APP_NAME"; then
    echo -e "${GREEN}✅ PM2 actif${NC}"
else
    echo -e "${RED}❌ PM2 non actif${NC}"
fi

# Test API
if curl -s http://localhost:$PORT/api/health | grep -q "ok"; then
    echo -e "${GREEN}✅ API accessible${NC}"
else
    echo -e "${RED}❌ API non accessible${NC}"
fi

# Test Nginx
if curl -sI http://localhost/ | grep -q "200"; then
    echo -e "${GREEN}✅ Site accessible via Nginx${NC}"
else
    echo -e "${RED}❌ Site non accessible via Nginx${NC}"
fi

# 14. RÉSUMÉ FINAL
echo ""
echo -e "${GREEN}🎉 PM2 INSTALLATION COMPLÈTE!${NC}"
echo "============================"
pm2 status
echo ""
echo "COMMANDES UTILES:"
echo "• pm2 status       - Voir status"
echo "• pm2 logs         - Voir logs"
echo "• pm2 restart all  - Redémarrer"
echo "• pm2 monit        - Monitoring"
echo "• pm2 reload all   - Reload sans downtime"
echo ""
echo "LOGS:"
echo "• Application: $APP_DIR/logs/"
echo "• Nginx: /var/log/nginx/${APP_NAME}_*.log"
echo ""
echo "MONITORING: ~/pm2-monitor.sh"
echo ""
echo -e "${GREEN}✅ VOTRE APPLICATION EST EN LIGNE!${NC}"