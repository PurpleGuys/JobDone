#!/bin/bash

echo "🚀 DÉMARRAGE BENNESPRO SUR VPS"
echo "==============================="

# Trouver le répertoire de l'application
APP_DIR=""
POSSIBLE_DIRS=(
    "/home/$(whoami)/BennesPro"
    "/var/www/html/BennesPro"
    "/opt/BennesPro"
    "/home/$(whoami)/workspace/BennesPro"
    "$(pwd)"
)

for dir in "${POSSIBLE_DIRS[@]}"; do
    if [[ -d "$dir" && -f "$dir/package.json" ]]; then
        APP_DIR="$dir"
        break
    fi
done

if [[ -z "$APP_DIR" ]]; then
    echo "❌ Répertoire BennesPro non trouvé"
    echo "Répertoires vérifiés:"
    for dir in "${POSSIBLE_DIRS[@]}"; do
        echo "  - $dir"
    done
    exit 1
fi

echo "📁 Application trouvée dans: $APP_DIR"
cd "$APP_DIR"

# Vérifier Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js non installé"
    exit 1
fi

NODE_VERSION=$(node --version)
echo "📦 Node.js version: $NODE_VERSION"

# Vérifier npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm non installé"
    exit 1
fi

# Arrêter les processus existants
echo "🛑 Arrêt des processus existants..."
pkill -f "node.*server" || true
pkill -f "tsx.*server" || true
pkill -f "npm.*start" || true

# Installer les dépendances
echo "📦 Installation des dépendances..."
npm install

# Variables d'environnement
if [[ -f ".env" ]]; then
    echo "✅ Fichier .env trouvé"
    source .env
else
    echo "⚠️  Fichier .env non trouvé, création d'un fichier minimal..."
    cat > .env << 'EOF'
NODE_ENV=production
PORT=5000
DATABASE_URL=your_database_url_here
JWT_SECRET=your_jwt_secret_here
EOF
fi

# Build de l'application
echo "🔨 Build de l'application..."
npm run build

# Démarrer l'application
echo "🚀 Démarrage de l'application..."
export NODE_ENV=production
export PORT=5000

# Démarrer avec nohup pour que ça continue après déconnexion
nohup npm start > app.log 2>&1 &
APP_PID=$!

echo "⏳ Attente du démarrage (10 secondes)..."
sleep 10

# Vérifier si l'application démarre
if ps -p $APP_PID > /dev/null; then
    echo "✅ Application démarrée avec PID: $APP_PID"
    
    # Test de l'API
    if curl -s http://localhost:5000/api/health > /dev/null; then
        echo "✅ API health accessible"
    else
        echo "⚠️  API health non accessible"
    fi
    
    # Test de la page d'accueil
    if curl -s http://localhost:5000/ > /dev/null; then
        echo "✅ Page d'accueil accessible"
    else
        echo "⚠️  Page d'accueil non accessible"
    fi
else
    echo "❌ Échec du démarrage de l'application"
    echo "📋 Logs de l'application:"
    tail -20 app.log
    exit 1
fi

echo ""
echo "🎉 BENNESPRO DÉMARRÉ AVEC SUCCÈS"
echo "================================"
echo "🌐 Application accessible sur: http://localhost:5000"
echo "📋 Logs en temps réel: tail -f $APP_DIR/app.log"
echo "🛑 Pour arrêter: kill $APP_PID"
echo ""
echo "Maintenant configurez Nginx pour proxy vers port 5000"