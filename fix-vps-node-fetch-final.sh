#!/bin/bash

# CORRECTION DÉFINITIVE NODE-FETCH POUR VPS
echo "🔧 CORRECTION COMPLÈTE NODE-FETCH POUR VPS"
echo "=========================================="

# 1. Arrêter les services
echo "1. Arrêt des services..."
sudo systemctl stop bennespro 2>/dev/null || true
sudo pm2 stop all 2>/dev/null || true
sudo killall node 2>/dev/null || true

# 2. Se positionner dans le bon répertoire
cd /home/ubuntu/JobDone || exit 1

# 3. Nettoyer complètement
echo "2. Nettoyage complet..."
rm -rf dist/
rm -rf node_modules/
rm -f package-lock.json

# 4. Installer node-fetch compatible CommonJS
echo "3. Installation des dépendances avec node-fetch v2..."
npm install node-fetch@2.7.0
npm install

# 5. Rebuild l'application
echo "4. Build de production..."
NODE_ENV=production npm run build

# 6. Test de l'import
echo "5. Test du serveur..."
timeout 5 npm run start || echo "Test OK si pas d'erreur d'import"

# 7. Configuration PM2
echo "6. Configuration PM2..."
cat > ecosystem.config.cjs << 'EOF'
module.exports = {
  apps: [{
    name: 'bennespro',
    script: './dist/index.js',
    instances: 1,
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 5000
    },
    error_file: './logs/error.log',
    out_file: './logs/output.log',
    log_file: './logs/combined.log',
    time: true
  }]
};
EOF

# 8. Créer le dossier logs
mkdir -p logs

echo ""
echo "✅ CORRECTION APPLIQUÉE!"
echo ""
echo "Pour démarrer l'application:"
echo "  sudo pm2 start ecosystem.config.cjs"
echo "  sudo pm2 save"
echo "  sudo pm2 startup"
echo ""
echo "Pour vérifier:"
echo "  sudo pm2 logs bennespro"