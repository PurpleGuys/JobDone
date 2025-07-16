#!/bin/bash

echo "🔧 FIX NGINX DIRECTORY ERROR"
echo "============================"

# 1. Créer le répertoire manquant
echo "📁 Création du répertoire nginx..."
sudo mkdir -p /var/nginx/client_body_temp
sudo mkdir -p /var/nginx/proxy_temp
sudo mkdir -p /var/nginx/fastcgi_temp
sudo mkdir -p /var/nginx/uwsgi_temp
sudo mkdir -p /var/nginx/scgi_temp

# 2. Définir les permissions appropriées
echo "🔐 Configuration des permissions..."
sudo chown -R www-data:www-data /var/nginx/
sudo chmod 755 /var/nginx/
sudo chmod 755 /var/nginx/client_body_temp
sudo chmod 755 /var/nginx/proxy_temp
sudo chmod 755 /var/nginx/fastcgi_temp
sudo chmod 755 /var/nginx/uwsgi_temp
sudo chmod 755 /var/nginx/scgi_temp

# 3. Tester la configuration
echo "🧪 Test configuration..."
if sudo nginx -t; then
    echo "✅ Configuration OK!"
    echo "🚀 Démarrage nginx..."
    sudo systemctl start nginx
    sudo systemctl enable nginx
    
    echo ""
    echo "📊 Status nginx:"
    sudo systemctl status nginx --no-pager
    
    echo ""
    echo "✅ NGINX DÉMARRÉ AVEC SUCCÈS!"
    echo "🌐 Vérifiez https://purpleguy.world"
else
    echo "❌ Erreur persistante"
    echo ""
    echo "Alternative - Supprimer la directive client_body_temp_path:"
    echo "sudo sed -i '/client_body_temp_path/d' /etc/nginx/sites-available/bennespro"
    echo "sudo nginx -t"
    echo "sudo systemctl start nginx"
fi