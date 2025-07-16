#!/bin/bash

echo "⚡ ULTRA SIMPLE PM2"
echo "=================="

# 1. Arrêter PM2
pm2 stop all
pm2 delete all

# 2. Lancer directement avec npx
echo "🚀 Lancement direct..."
PORT=5000 NODE_ENV=production pm2 start "npx tsx server/index.ts" --name bennespro

# 3. Vérifier
sleep 5
pm2 list
ss -tlnp | grep ":5000"

echo "✅ DONE"