#!/bin/bash

echo "🚀 PM2 AVEC NODE.JS SIMPLE"
echo "=========================="

# SOLUTION ULTRA SIMPLE - PAS DE TSX

# 1. Nettoyer PM2
pm2 kill
pm2 flush

# 2. Trouver app
cd /home/$(whoami)/BennesPro || cd /var/www/html/BennesPro || cd $(pwd)

# 3. Build
echo "🔨 Build..."
npm run build

# 4. Démarrer avec Node.js standard
echo "🚀 Démarrage avec Node.js..."
pm2 start npm --name bennespro -- start

# Ou directement:
# pm2 start "node dist/index.js" --name bennespro

# 5. Sauvegarder
pm2 save --force
pm2 startup

# 6. Status
pm2 status

echo "✅ TERMINÉ - PM2 avec Node.js standard!"