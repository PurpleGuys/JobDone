#!/bin/bash

echo "🔧 CORRECTION TSX PM2"
echo "====================="

# 1. Arrêter PM2
pm2 stop all
pm2 delete all

# 2. Installer tsx localement
echo "📦 Installation tsx localement..."
npm install tsx --save-dev

# 3. Créer script de démarrage
echo "📝 Création script de démarrage..."
cat > start-server.js << 'EOF'
const { spawn } = require('child_process');

const server = spawn('npx', ['tsx', 'server/index.ts'], {
  stdio: 'inherit',
  env: {
    ...process.env,
    NODE_ENV: 'production',
    PORT: '5000'
  }
});

server.on('close', (code) => {
  console.log(`Server exited with code ${code}`);
  process.exit(code);
});

server.on('error', (err) => {
  console.error('Failed to start server:', err);
  process.exit(1);
});
EOF

# 4. Nouvelle config PM2
echo "📝 Création nouvelle config PM2..."
cat > ecosystem.config.cjs << 'EOF'
module.exports = {
  apps: [{
    name: 'bennespro',
    script: 'start-server.js',
    cwd: '/home/ubuntu/JobDone',
    instances: 1,
    exec_mode: 'fork',
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: '5000'
    },
    autorestart: true,
    max_restarts: 5,
    min_uptime: '10s'
  }]
}
EOF

# 5. Démarrer PM2
echo "🚀 Démarrage PM2..."
pm2 start ecosystem.config.cjs

# 6. Attendre et vérifier
echo "⏳ Attente 10 secondes..."
sleep 10

echo "📊 Status PM2:"
pm2 list

echo "🔍 Port 5000:"
ss -tlnp | grep ":5000" || echo "❌ Pas de port 5000"

echo "🧪 Test local:"
curl -s -I http://localhost:5000 | head -3 || echo "❌ Échec test local"

echo "📋 Logs récents:"
pm2 logs --lines 5

echo ""
echo "✅ CORRECTION TERMINÉE"
echo "🌐 Testez https://purpleguy.world"