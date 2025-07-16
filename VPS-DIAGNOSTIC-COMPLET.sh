#!/bin/bash

echo "🔍 DIAGNOSTIC VPS COMPLET"
echo "========================="

# 1. Vérifier les services
echo "📊 Status des services:"
echo "PM2: $(pm2 list 2>/dev/null | grep -c online || echo '0') processus online"
echo "Nginx: $(systemctl is-active nginx 2>/dev/null || echo 'inactive')"
echo "Port 5000: $(netstat -tlnp 2>/dev/null | grep -c ':5000' || echo '0') processus"

# 2. Vérifier les fichiers
echo ""
echo "📁 Vérification des fichiers:"
echo "Dossier actuel: $(pwd)"
echo "Contenu:"
ls -la

# Chercher les fichiers de l'application
if [ -f "server/index.ts" ]; then
    echo "✅ server/index.ts trouvé"
    APP_DIR=$(pwd)
elif [ -f "../server/index.ts" ]; then
    echo "✅ server/index.ts trouvé dans le dossier parent"
    APP_DIR=$(cd .. && pwd)
else
    echo "❌ server/index.ts introuvable"
    echo "Recherche dans le système..."
    find /home -name "server" -type d 2>/dev/null | head -5
    APP_DIR=""
fi

# 3. Vérifier le build
echo ""
echo "🔨 Vérification du build:"
if [ -n "$APP_DIR" ]; then
    cd "$APP_DIR"
    echo "Dans le dossier: $(pwd)"
    
    if [ -d "dist" ]; then
        echo "✅ Dossier dist existe"
        echo "Contenu dist:"
        ls -la dist/
        
        if [ -d "dist/assets" ]; then
            echo "✅ Dossier assets existe"
            echo "Fichiers assets:"
            ls -la dist/assets/ | head -5
        else
            echo "❌ Pas de dossier assets"
        fi
    else
        echo "❌ Pas de dossier dist"
        echo "🔨 Tentative de build..."
        if [ -f "package.json" ]; then
            npm run build
            if [ -d "dist" ]; then
                echo "✅ Build réussi"
            else
                echo "❌ Build échoué"
            fi
        else
            echo "❌ Pas de package.json"
        fi
    fi
else
    echo "❌ Impossible de localiser l'application"
fi

# 4. Tester les URLs
echo ""
echo "🧪 Test des URLs:"
echo "Test CSS:"
curl -s -I https://purpleguy.world/assets/index-BEb0iJbV.css | head -3

echo "Test JS:"
curl -s -I https://purpleguy.world/assets/index-BGktlCn_.js | head -3

echo "Test contenu JS (premiers caractères):"
curl -s https://purpleguy.world/assets/index-BGktlCn_.js | head -c 100

# 5. Vérifier la configuration nginx
echo ""
echo "🔧 Configuration nginx actuelle:"
if [ -f "/etc/nginx/sites-available/bennespro" ]; then
    echo "✅ Configuration nginx existe"
    echo "Lignes importantes:"
    grep -n "location.*assets" /etc/nginx/sites-available/bennespro || echo "Pas de configuration assets"
    grep -n "proxy_pass" /etc/nginx/sites-available/bennespro | head -3
else
    echo "❌ Configuration nginx introuvable"
fi

# 6. Vérifier les logs nginx
echo ""
echo "📋 Logs nginx récents:"
sudo tail -5 /var/log/nginx/error.log 2>/dev/null || echo "Pas de logs nginx"

# 7. Résumé et recommandations
echo ""
echo "🎯 RÉSUMÉ:"
echo "========="
echo "APP_DIR: ${APP_DIR:-'Non trouvé'}"
echo "DIST: $([ -d "$APP_DIR/dist" ] && echo 'Existe' || echo 'Manquant')"
echo "ASSETS: $([ -d "$APP_DIR/dist/assets" ] && echo 'Existe' || echo 'Manquant')"
echo "PM2: $(pm2 list 2>/dev/null | grep -c online || echo '0') processus"
echo "NGINX: $(systemctl is-active nginx 2>/dev/null || echo 'inactive')"

echo ""
echo "🔧 RECOMMANDATIONS:"
if [ ! -d "$APP_DIR/dist" ]; then
    echo "1. Faire le build: cd $APP_DIR && npm run build"
fi
echo "2. Configurer nginx pour servir les fichiers statiques"
echo "3. Redémarrer nginx: sudo systemctl reload nginx"
echo "4. Vérifier PM2: pm2 list"