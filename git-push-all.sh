#!/bin/bash

echo "📦 GIT PUSH - TOUS LES FICHIERS"
echo ""

# Vérifier si git est initialisé
if [ ! -d ".git" ]; then
  echo "❌ Pas de repository Git trouvé. Initialisation..."
  git init
fi

# Ajouter tous les fichiers
echo "➕ Ajout de tous les fichiers..."
git add -A

# Afficher le statut
echo ""
echo "📊 Statut Git:"
git status --short

# Commit avec message
echo ""
echo "💾 Commit en cours..."
git commit -m "VPS deployment fixes - Stripe hardcoded, Qt error fixed, build scripts added"

# Vérifier si remote existe
if ! git remote | grep -q origin; then
  echo ""
  echo "⚠️  Pas de remote 'origin' configuré."
  echo "Ajoutez votre remote avec:"
  echo "git remote add origin https://github.com/VOTRE_USERNAME/VOTRE_REPO.git"
  echo ""
  echo "Puis poussez avec:"
  echo "git push -u origin main"
else
  # Push vers origin
  echo ""
  echo "🚀 Push vers origin..."
  git push origin main || git push origin master || echo "⚠️  Erreur de push. Vérifiez votre branche et vos permissions."
fi

echo ""
echo "✅ Terminé!"