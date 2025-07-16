#!/bin/bash

echo "🔧 FIX NGINX ERRORS"
echo "=================="

# 1. Corriger le fichier nginx sur le VPS
echo "📝 Correction du fichier nginx..."

# Supprimer la ligne problématique
sudo sed -i '/temp_file_write_size/d' /etc/nginx/sites-available/bennespro

# Corriger la syntaxe http2 (version moderne)
sudo sed -i 's/listen 443 ssl http2;/listen 443 ssl;/g' /etc/nginx/sites-available/bennespro
sudo sed -i 's/listen \[::\]:443 ssl http2;/listen [::]:443 ssl;/g' /etc/nginx/sites-available/bennespro

# Ajouter http2 on; après les listen 443
sudo sed -i '/listen \[::\]:443 ssl;/a\    http2 on;' /etc/nginx/sites-available/bennespro

# 2. Tester la configuration
echo "🧪 Test configuration..."
sudo nginx -t

# 3. Si le test est OK, démarrer nginx
if sudo nginx -t; then
    echo "✅ Configuration OK, démarrage nginx..."
    sudo systemctl start nginx
    sudo systemctl enable nginx
    
    # Vérifier le status
    echo ""
    echo "📊 Status nginx:"
    sudo systemctl status nginx --no-pager
    
    echo ""
    echo "✅ NGINX CORRIGÉ ET DÉMARRÉ!"
else
    echo "❌ Il reste des erreurs dans la configuration"
    echo "Vérifiez avec: sudo nginx -t"
fi