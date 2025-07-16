#!/bin/bash

echo "🔧 FIX NGINX RATE LIMIT ERROR"
echo "============================="

# 1. Supprimer les lignes problématiques du fichier site
echo "📝 Correction du fichier site..."
sudo sed -i '/limit_req_zone.*zone=bennespro/d' /etc/nginx/sites-available/bennespro

# 2. Ajouter la directive dans nginx.conf si elle n'existe pas
echo "📝 Ajout rate limiting dans nginx.conf..."
if ! grep -q "limit_req_zone.*zone=bennespro" /etc/nginx/nginx.conf; then
    # Ajouter après la ligne http {
    sudo sed -i '/^http {/a\    # Rate limiting pour BennesPro\n    limit_req_zone $binary_remote_addr zone=bennespro:10m rate=10r/s;' /etc/nginx/nginx.conf
fi

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
else
    echo "❌ Erreur persistante"
    echo ""
    echo "Solution alternative - Supprimer complètement le rate limiting:"
    echo "sudo sed -i '/limit_req/d' /etc/nginx/sites-available/bennespro"
    echo "sudo nginx -t"
    echo "sudo systemctl start nginx"
fi