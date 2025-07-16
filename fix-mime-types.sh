#!/bin/bash

echo "🔧 FIX MIME TYPES NGINX"
echo "======================="

# 1. Vérifier l'état actuel
echo "📊 Status services:"
echo "PM2: $(pm2 list 2>/dev/null | grep -c "online" || echo "0") processus"
echo "Nginx: $(systemctl is-active nginx)"
echo "Port 5000: $(netstat -tlnp 2>/dev/null | grep -c ":5000")"

# 2. Tester les types MIME
echo ""
echo "🧪 Test types MIME:"
echo "JS file:"
curl -s -I https://purpleguy.world/assets/index-BGktlCn_.js | grep -i content-type || echo "Pas de réponse"
echo "CSS file:"
curl -s -I https://purpleguy.world/assets/index-BEb0iJbV.css | grep -i content-type || echo "Pas de réponse"

# 3. Chercher les fichiers dist
echo ""
echo "📁 Recherche fichiers dist:"
if [ -d "dist" ]; then
    echo "✅ Dossier dist trouvé localement"
    ls -la dist/
    echo "Fichiers assets:"
    ls -la dist/assets/ 2>/dev/null || echo "Pas de dossier assets"
else
    echo "❌ Dossier dist introuvable localement"
    echo "Recherche dans d'autres emplacements..."
    find . -name "dist" -type d 2>/dev/null | head -5
fi

# 4. Build de l'application si nécessaire
echo ""
echo "🔨 Build de l'application:"
if [ -f "package.json" ]; then
    echo "Building application..."
    npm run build
    
    if [ -d "dist" ]; then
        echo "✅ Build réussi, dossier dist créé"
        ls -la dist/
    else
        echo "❌ Build échoué, pas de dossier dist"
    fi
else
    echo "❌ Pas de package.json trouvé"
fi

# 5. Corriger la configuration nginx
echo ""
echo "🔧 Correction nginx pour fichiers statiques:"

# Backup de la config actuelle
sudo cp /etc/nginx/sites-available/bennespro /etc/nginx/sites-available/bennespro.backup

# Créer une nouvelle config avec gestion correcte des fichiers statiques
cat > /tmp/nginx-fixed.conf << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name purpleguy.world www.purpleguy.world;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    http2 on;
    server_name purpleguy.world www.purpleguy.world;

    ssl_certificate /etc/letsencrypt/live/purpleguy.world/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/purpleguy.world/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;
    
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    client_max_body_size 50M;
    
    # Fichiers statiques avec types MIME corrects
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        root /home/ubuntu/JobDone/dist;
        expires 1y;
        add_header Cache-Control "public, immutable";
        
        # Types MIME spécifiques
        location ~* \.js$ {
            add_header Content-Type "application/javascript";
        }
        location ~* \.css$ {
            add_header Content-Type "text/css";
        }
        location ~* \.(png|jpg|jpeg|gif)$ {
            add_header Content-Type "image/$1";
        }
        location ~* \.svg$ {
            add_header Content-Type "image/svg+xml";
        }
        location ~* \.(woff|woff2)$ {
            add_header Content-Type "font/woff";
        }
    }
    
    # Dossier assets spécifique
    location /assets/ {
        root /home/ubuntu/JobDone/dist;
        expires 1y;
        add_header Cache-Control "public, immutable";
        
        location ~* /assets/.*\.js$ {
            add_header Content-Type "application/javascript";
        }
        location ~* /assets/.*\.css$ {
            add_header Content-Type "text/css";
        }
    }
    
    # API routes
    location /api/ {
        proxy_pass http://localhost:5000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_cache_bypass $http_upgrade;
    }
    
    # Application principale
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Appliquer la nouvelle config
sudo cp /tmp/nginx-fixed.conf /etc/nginx/sites-available/bennespro

# 6. Tester et recharger nginx
echo ""
echo "🧪 Test nginx:"
if sudo nginx -t; then
    echo "✅ Configuration nginx OK"
    sudo systemctl reload nginx
    echo "✅ Nginx rechargé"
else
    echo "❌ Erreur nginx, restauration backup"
    sudo cp /etc/nginx/sites-available/bennespro.backup /etc/nginx/sites-available/bennespro
fi

# 7. Test final
echo ""
echo "🧪 Test final MIME types:"
sleep 2
echo "Test JS:"
curl -s -I https://purpleguy.world/assets/index-BGktlCn_.js | grep -i content-type
echo "Test CSS:"
curl -s -I https://purpleguy.world/assets/index-BEb0iJbV.css | grep -i content-type

echo ""
echo "✅ CORRECTION TERMINÉE"
echo "Testez https://purpleguy.world"