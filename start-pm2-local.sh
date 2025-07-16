#!/bin/bash

echo "🚀 DÉMARRAGE PM2 LOCAL"
echo "====================="

# 1. Vérifier si on est dans le bon dossier
if [ ! -f "ecosystem.config.cjs" ]; then
    echo "❌ ecosystem.config.cjs introuvable"
    echo "Création d'un fichier ecosystem.config.cjs..."
    
    cat > ecosystem.config.cjs << 'EOF'
module.exports = {
  apps: [{
    name: 'bennespro',
    script: 'tsx',
    args: 'server/index.ts',
    env: {
      NODE_ENV: 'production',
      PORT: '5000'
    },
    instances: 1,
    exec_mode: 'fork',
    watch: false,
    max_memory_restart: '1G',
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
}
EOF
    echo "✅ ecosystem.config.cjs créé"
fi

# 2. Créer le dossier logs
mkdir -p logs

# 3. Vérifier si server/index.ts existe
if [ ! -f "server/index.ts" ]; then
    echo "❌ server/index.ts introuvable"
    echo "Contenu du dossier actuel:"
    ls -la
    echo "Essayez de naviguer vers le dossier BennesPro"
    exit 1
fi

# 4. Installer tsx si nécessaire
if ! command -v tsx &> /dev/null; then
    echo "📦 Installation tsx..."
    npm install -g tsx
fi

# 5. Arrêter les processus PM2 existants
echo "🛑 Arrêt des processus existants..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# 6. Démarrer avec PM2
echo "🚀 Démarrage avec PM2..."
pm2 start ecosystem.config.cjs --env production

# 7. Vérifier le statut
echo ""
echo "📊 Status PM2:"
pm2 list

# 8. Attendre et tester
echo ""
echo "⏳ Attente démarrage (5 secondes)..."
sleep 5

# 9. Test de connexion
echo "🧪 Test de connexion..."
if curl -s http://localhost:5000 > /dev/null 2>&1; then
    echo "✅ Application démarrée avec succès!"
    echo "🌐 Testez https://purpleguy.world"
else
    echo "❌ Application ne répond pas"
    echo "📋 Logs récents:"
    pm2 logs --lines 10
    echo ""
    echo "🔍 Vérification du port 5000:"
    netstat -tlnp | grep ":5000" || echo "Aucun processus sur port 5000"
fi

# 10. Sauvegarder
pm2 save

echo ""
echo "✅ SCRIPT TERMINÉ"
echo "================"
echo "Commandes utiles:"
echo "pm2 list        - Voir les processus"
echo "pm2 logs        - Voir les logs"
echo "pm2 restart all - Redémarrer"