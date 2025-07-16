#!/bin/bash

echo "🚀 INSTALLATION PM2 SIMPLE ET CARRÉ"
echo "==================================="

# Variables
APP_DIR="/home/$(whoami)/BennesPro"
APP_NAME="bennespro"
PORT=5000

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. INSTALLER PM2
echo -e "${YELLOW}📦 Installation PM2...${NC}"
sudo npm install -g pm2
pm2 --version

# 2. TROUVER L'APPLICATION
if [[ ! -d "$APP_DIR" ]]; then
    # Chercher dans d'autres endroits
    for dir in "/var/www/html/BennesPro" "/opt/BennesPro" "$(pwd)"; do
        if [[ -f "$dir/package.json" ]]; then
            APP_DIR="$dir"
            break
        fi
    done
fi

if [[ ! -d "$APP_DIR" ]]; then
    echo "❌ Application non trouvée!"
    exit 1
fi

echo -e "${GREEN}✅ Application trouvée: $APP_DIR${NC}"
cd "$APP_DIR"

# 3. ARRÊTER TOUT
echo -e "${YELLOW}🛑 Arrêt des processus existants...${NC}"
pm2 delete all 2>/dev/null || true
pkill -f node 2>/dev/null || true

# 4. CRÉER ECOSYSTEM FILE PM2
echo -e "${YELLOW}📝 Création configuration PM2...${NC}"
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: '$APP_NAME',
    script: './server/index.js',
    instances: 2,
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: $PORT
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true,
    watch: false,
    max_memory_restart: '500M'
  }]
}
EOF

# 5. CRÉER DOSSIER LOGS
mkdir -p logs

# 6. BUILD APPLICATION
echo -e "${YELLOW}🔨 Build application...${NC}"
npm run build || echo "Build échoué, on continue..."

# 7. DÉMARRER AVEC PM2
echo -e "${YELLOW}🚀 Démarrage avec PM2...${NC}"
pm2 start ecosystem.config.js

# 8. SAUVEGARDER CONFIGURATION
echo -e "${YELLOW}💾 Sauvegarde configuration PM2...${NC}"
pm2 save
pm2 startup systemd -u $(whoami) --hp /home/$(whoami)

# 9. CONFIGURER NGINX SIMPLE
echo -e "${YELLOW}⚙️  Configuration Nginx...${NC}"
sudo tee /etc/nginx/sites-available/bennespro > /dev/null << EOF
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://localhost:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/bennespro /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx

# 10. STATUS
echo ""
echo -e "${GREEN}✅ INSTALLATION TERMINÉE!${NC}"
echo "========================"
pm2 status
echo ""
echo "COMMANDES PM2 UTILES:"
echo "• pm2 status         - Voir status"
echo "• pm2 logs          - Voir logs"
echo "• pm2 restart all   - Redémarrer"
echo "• pm2 monit         - Monitoring"
echo "• pm2 reload all    - Reload sans downtime"
echo ""
echo "Logs dans: $APP_DIR/logs/"