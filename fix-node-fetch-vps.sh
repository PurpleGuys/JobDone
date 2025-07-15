#!/bin/bash

# Script de correction pour node-fetch sur VPS
echo "🔧 CORRECTION NODE-FETCH POUR VPS"
echo "=================================="

# Arrêter l'application si elle tourne
echo "1. Arrêt de l'application..."
sudo systemctl stop bennespro || true
sudo pm2 stop all || true

# Nettoyer les anciens builds
echo "2. Nettoyage des anciens builds..."
rm -rf dist/
rm -rf node_modules/

# Réinstaller les dépendances
echo "3. Réinstallation des dépendances..."
npm install

# Rebuild l'application
echo "4. Rebuild de l'application..."
npm run build

# Test rapide
echo "5. Test de l'import node-fetch..."
node -e "import('node-fetch').then(() => console.log('✅ node-fetch import OK')).catch(e => console.error('❌ Erreur:', e.message))"

echo ""
echo "✅ Correction appliquée!"
echo ""
echo "Pour démarrer l'application:"
echo "  - Avec PM2: sudo pm2 start ecosystem.config.cjs"
echo "  - Avec systemd: sudo systemctl start bennespro"
echo "  - En direct: sudo npm run start"