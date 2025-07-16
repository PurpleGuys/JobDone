#!/bin/bash

echo "🔧 FIX STATIC FILES FINAL"
echo "========================"

# 1. Diagnostic des fichiers
echo "📁 Vérification des fichiers:"
PWD_PATH=$(pwd)
echo "Dossier actuel: $PWD_PATH"

if [ -d "dist" ]; then
    echo "✅ Dossier dist trouvé"
    echo "Contenu dist/:"
    ls -la dist/
    if [ -d "dist/assets" ]; then
        echo "✅ Dossier assets trouvé"
        ls -la dist/assets/ | head -5
    else
        echo "❌ Pas de dossier assets"
    fi
else
    echo "❌ Pas de dossier dist"
    if [ -f "package.json" ]; then
        echo "🔨 Build de l'application..."
        npm run build
        if [ -d "dist" ]; then
            echo "✅ Build réussi"
        else
            echo "❌ Build échoué"
            exit 1
        fi
    else
        echo "❌ Pas de package.json"
        exit 1
    fi
fi

# 2. Configuration nginx complète
echo ""
echo "🔧 Configuration nginx pour fichiers statiques:"

cat > /tmp/nginx-static-fix.conf << EOF
server {
    listen 80;
    listen [::]:80;
    server_name purpleguy.world www.purpleguy.world;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    http2 on;
    server_name purpleguy.world www.purpleguy.world;

    # SSL
    ssl_certificate /etc/letsencrypt/live/purpleguy.world/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/purpleguy.world/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;
    
    # Headers
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    client_max_body_size 50M;
    
    # SERVIR LES FICHIERS STATIQUES DIRECTEMENT
    location /assets/ {
        alias $PWD_PATH/dist/assets/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Access-Control-Allow-Origin "*";
        
        # Types MIME corrects
        location ~* \.js\$ {
            add_header Content-Type "application/javascript; charset=utf-8";
            add_header X-Content-Type-Options "nosniff";
        }
        
        location ~* \.css\$ {
            add_header Content-Type "text/css; charset=utf-8";
            add_header X-Content-Type-Options "nosniff";
        }
        
        location ~* \.(png|jpg|jpeg|gif|ico|svg)\$ {
            add_header Content-Type "image/\$1";
        }
        
        location ~* \.(woff|woff2|ttf|eot)\$ {
            add_header Content-Type "font/woff";
        }
    }
    
    # Autres fichiers statiques
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)\$ {
        root $PWD_PATH/dist;
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
    }
    
    # Favicon
    location = /favicon.ico {
        root $PWD_PATH/dist;
        expires 1y;
        add_header Cache-Control "public, immutable";
        log_not_found off;
        access_log off;
    }
    
    # API routes
    location /api/ {
        proxy_pass http://localhost:5000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_cache_bypass \$http_upgrade;
    }
    
    # Application React (tout le reste)
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# 3. Sauvegarder la config actuelle
sudo cp /etc/nginx/sites-available/bennespro /etc/nginx/sites-available/bennespro.backup.$(date +%s)

# 4. Appliquer la nouvelle config
sudo cp /tmp/nginx-static-fix.conf /etc/nginx/sites-available/bennespro

# 5. Tester la config
echo ""
echo "🧪 Test configuration nginx:"
if sudo nginx -t; then
    echo "✅ Configuration valide"
    sudo systemctl reload nginx
    echo "✅ Nginx rechargé"
else
    echo "❌ Erreur configuration"
    echo "Restauration backup..."
    sudo cp /etc/nginx/sites-available/bennespro.backup.$(date +%s) /etc/nginx/sites-available/bennespro
    exit 1
fi

# 6. Vérifier les permissions
echo ""
echo "🔐 Vérification permissions:"
sudo chown -R www-data:www-data $PWD_PATH/dist 2>/dev/null || true
sudo chmod -R 755 $PWD_PATH/dist 2>/dev/null || true

# 7. Test des fichiers statiques
echo ""
echo "🧪 Test des fichiers statiques:"
sleep 3

# Tester les types MIME
echo "Test CSS:"
curl -s -I https://purpleguy.world/assets/index-BEb0iJbV.css | grep -i content-type || echo "Pas de réponse CSS"

echo "Test JS:"
curl -s -I https://purpleguy.world/assets/index-BGktlCn_.js | grep -i content-type || echo "Pas de réponse JS"

echo "Test contenu (premiers caractères):"
curl -s https://purpleguy.world/assets/index-BEb0iJbV.css | head -c 50 || echo "Pas de contenu CSS"

echo ""
echo "✅ CONFIGURATION TERMINÉE"
echo "========================"
echo "🌐 Testez https://purpleguy.world"
echo "📊 Status services:"
echo "- PM2: $(pm2 list 2>/dev/null | grep -c online || echo '0') processus"
echo "- Nginx: $(systemctl is-active nginx)"
echo "- Fichiers dist: $(ls -1 dist/assets/ 2>/dev/null | wc -l || echo '0') fichiers"