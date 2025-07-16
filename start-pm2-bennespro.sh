#!/bin/bash

echo "🚀 DÉMARRAGE PM2 BENNESPRO"
echo "=========================="

# 1. Aller dans le dossier BennesPro
cd /home/ubuntu/BennesPro || {
    echo "❌ Dossier BennesPro introuvable"
    exit 1
}

# 2. Installer les dépendances si nécessaire
echo "📦 Vérification des dépendances..."
if [ ! -d "node_modules" ]; then
    echo "Installation des dépendances..."
    npm install
fi

# 3. Installer tsx globalement si nécessaire
if ! command -v tsx &> /dev/null; then
    echo "📦 Installation tsx..."
    npm install -g tsx
fi

# 4. Stopper PM2 existant
echo "🛑 Arrêt des processus PM2 existants..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# 5. Démarrer avec PM2
echo "🚀 Démarrage BennesPro avec PM2..."
pm2 start ecosystem.config.cjs --env production

# 6. Vérifier le statut
echo ""
echo "📊 Status PM2:"
pm2 list
pm2 logs --lines 5

# 7. Attendre et tester
echo ""
echo "⏳ Attente démarrage (10 secondes)..."
sleep 10

# 8. Test de connexion
echo "🧪 Test de connexion..."
if curl -s http://localhost:5000/api/health > /dev/null; then
    echo "✅ Application démarrée avec succès!"
    echo "🌐 Testez https://purpleguy.world"
else
    echo "❌ Application ne répond pas"
    echo "📋 Logs récents:"
    pm2 logs --lines 20
fi

# 9. Sauvegarder la configuration PM2
pm2 save
pm2 startup

echo ""
echo "✅ DÉMARRAGE TERMINÉ!"
echo "====================="
echo "Commandes utiles:"
echo "pm2 list        - Voir les processus"
echo "pm2 logs        - Voir les logs"
echo "pm2 restart all - Redémarrer"
echo "pm2 stop all    - Arrêter"