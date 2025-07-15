#!/bin/bash
# Script pour corriger les CSP PayPlug sur le VPS

echo "🔧 Correction des CSP pour PayPlug sur VPS..."

# Vérifier si on est sur le VPS
if [ ! -d "/var/www/bennespro" ]; then
    echo "❌ Ce script doit être exécuté sur le VPS"
    exit 1
fi

# Sauvegarder la configuration actuelle
echo "📦 Sauvegarde de la configuration nginx actuelle..."
sudo cp /etc/nginx/sites-available/bennespro /etc/nginx/sites-available/bennespro.backup.$(date +%Y%m%d-%H%M%S)

# Appliquer la nouvelle configuration
echo "📝 Application de la nouvelle configuration avec CSP PayPlug..."
sudo cp nginx-vps-payplug.conf /etc/nginx/sites-available/bennespro

# Tester la configuration
echo "✅ Test de la configuration nginx..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "🔄 Rechargement de nginx..."
    sudo systemctl reload nginx
    echo "✅ Configuration appliquée avec succès!"
    echo ""
    echo "🌐 Testez maintenant sur: https://purpleguy.world/booking"
    echo ""
    echo "📋 Les domaines PayPlug autorisés sont:"
    echo "   - https://cdn.payplug.com (SDK JavaScript)"
    echo "   - https://secure.payplug.com (Interface de paiement)"
    echo "   - https://api.payplug.com (API PayPlug)"
else
    echo "❌ Erreur dans la configuration nginx"
    echo "🔙 Restauration de la configuration précédente..."
    sudo cp /etc/nginx/sites-available/bennespro.backup.$(date +%Y%m%d-%H%M%S) /etc/nginx/sites-available/bennespro
    exit 1
fi