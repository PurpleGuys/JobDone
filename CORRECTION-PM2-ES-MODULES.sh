#!/bin/bash

echo "🔧 CORRECTION PM2 ES MODULES"
echo "============================"

# 1. Arrêter PM2
echo "⏹️ Arrêt PM2..."
pm2 stop all
pm2 delete all

# 2. Vérifier les fichiers
echo "📁 Vérification des fichiers:"
ls -la server/
echo ""

# 3. Corriger ecosystem.config.cjs
echo "📝 Création ecosystem.config.cjs correct..."
cat > ecosystem.config.cjs << 'EOF'
module.exports = {
  apps: [{
    name: 'bennespro',
    script: 'tsx',
    args: 'server/index.ts',
    cwd: '/home/ubuntu/JobDone',
    instances: 1,
    exec_mode: 'fork',
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: '5000'
    },
    error_file: '/home/ubuntu/JobDone/logs/pm2-error.log',
    out_file: '/home/ubuntu/JobDone/logs/pm2-out.log',
    log_file: '/home/ubuntu/JobDone/logs/pm2-combined.log',
    time: true,
    autorestart: true,
    max_restarts: 5,
    min_uptime: '10s'
  }]
}
EOF

# 4. Créer dossier logs
mkdir -p logs

# 5. Vérifier tsx
echo "🔍 Vérification tsx:"
which tsx || echo "❌ tsx non trouvé"
npm list tsx || echo "❌ tsx non installé"

# 6. Installer tsx si nécessaire
if ! npm list tsx > /dev/null 2>&1; then
    echo "📦 Installation tsx..."
    npm install tsx
fi

# 7. Démarrer avec la nouvelle config
echo "🚀 Démarrage avec nouvelle config..."
pm2 start ecosystem.config.cjs --env production

# 8. Attendre et vérifier (remplacer netstat par ss)
echo "⏳ Attente 10 secondes..."
sleep 10

echo "🔍 Vérification avec ss:"
ss -tlnp | grep ":5000" || echo "❌ Pas de port 5000"

# 9. Status PM2
echo ""
echo "📊 Status PM2:"
pm2 list

# 10. Logs récents
echo ""
echo "📋 Logs récents:"
pm2 logs --lines 5

# 11. Test local
echo ""
echo "🧪 Test local:"
curl -s -I http://localhost:5000 | head -3 || echo "❌ Échec test local"

# 12. Redémarrer nginx
echo ""
echo "🔄 Redémarrage nginx..."
sudo systemctl reload nginx

echo ""
echo "✅ CORRECTION TERMINÉE"
echo "🌐 Testez https://purpleguy.world"