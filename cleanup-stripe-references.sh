#!/bin/bash

# NETTOYAGE COMPLET DES RÉFÉRENCES STRIPE
echo "🧹 NETTOYAGE COMPLET DES RÉFÉRENCES STRIPE -> PAYPLUG"
echo "===================================================="

# Fonction pour remplacer dans tous les fichiers
replace_in_files() {
    local search="$1"
    local replace="$2"
    local files="$3"
    
    echo "Remplacement: $search -> $replace"
    
    # Utiliser sed pour remplacer dans tous les fichiers
    for file in $files; do
        if [ -f "$file" ]; then
            sed -i "s/$search/$replace/g" "$file"
            echo "  ✓ $file"
        fi
    done
}

# Liste des fichiers à nettoyer
FILES="deploy-corrected.sh deploy-final.sh deploy-vps-ultimate.sh docker-deploy-auto.sh fix-all-api-keys.sh fix-env-jobdone.sh fix-port-mapping-immediate.sh fix-postgresql-force.sh fix-vps-100-percent.sh"

echo "📁 Fichiers à nettoyer: $FILES"
echo ""

# Remplacements systématiques
replace_in_files "STRIPE_SECRET_KEY" "PAYPLUG_SECRET_KEY" "$FILES"
replace_in_files "VITE_STRIPE_PUBLIC_KEY" "VITE_PAYPLUG_PUBLIC_KEY" "$FILES"
replace_in_files "STRIPE_WEBHOOK_SECRET" "PAYPLUG_WEBHOOK_SECRET" "$FILES"
replace_in_files "stripe" "payplug" "$FILES"
replace_in_files "Stripe" "PayPlug" "$FILES"
replace_in_files "STRIPE" "PAYPLUG" "$FILES"

# Remplacements spécifiques pour les URLs et domaines
replace_in_files "https://api.stripe.com" "https://api.payplug.com" "$FILES"
replace_in_files "https://js.stripe.com" "https://js.payplug.com" "$FILES"
replace_in_files "https://hooks.stripe.com" "https://secure.payplug.com" "$FILES"

echo ""
echo "✅ NETTOYAGE TERMINÉ"
echo "Toutes les références Stripe ont été remplacées par PayPlug"