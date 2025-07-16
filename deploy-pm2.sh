#!/bin/bash

echo "🚀 DÉPLOIEMENT PM2 BENNESPRO"
echo "============================"

# Installation PM2
echo "📦 Installation PM2 global..."
sudo npm install -g pm2

# Arrêt processus existants
echo "🛑 Arrêt processus existants..."
pm2 kill

# Build application
echo "🔨 Build application..."
npm run build

# Démarrage avec PM2
echo "🚀 Démarrage PM2..."
pm2 start ecosystem.config.cjs --env production

# Sauvegarde configuration
echo "💾 Sauvegarde configuration..."
pm2 save
pm2 startup

# Status
echo "✅ Déploiement terminé!"
pm2 status