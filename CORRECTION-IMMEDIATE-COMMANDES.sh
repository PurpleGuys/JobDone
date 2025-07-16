#!/bin/bash

echo "🚨 CORRECTION IMMEDIATE"
echo "======================="

# 1. Arrêter PM2
pm2 stop all
pm2 delete all

# 2. Relancer avec PORT=5000
echo "🚀 Relancement sur port 5000..."
cd /home/ubuntu/JobDone
PORT=5000 NODE_ENV=production pm2 start "tsx server/index.ts" --name bennespro

# 3. Vérifier
sleep 3
echo "✅ Vérification:"
pm2 list
netstat -tlnp | grep ":5000"

# 4. Test immédiat
echo "🧪 Test:"
curl -s -I http://localhost:5000 | head -2

echo ""
echo "✅ DONE - Testez https://purpleguy.world"