#!/bin/bash

echo "⚡ QUICK FIX PM2"
echo "==============="

# 1. Arrêter PM2
pm2 stop all
pm2 delete all

# 2. Créer nouvelle config simple
cat > ecosystem.config.cjs << 'EOF'
module.exports = {
  apps: [{
    name: 'bennespro',
    script: 'tsx',
    args: 'server/index.ts',
    env: {
      NODE_ENV: 'production',
      PORT: '5000'
    }
  }]
}
EOF

# 3. Lancer
pm2 start ecosystem.config.cjs

# 4. Vérifier
sleep 5
pm2 list
ss -tlnp | grep ":5000"

echo "✅ DONE"