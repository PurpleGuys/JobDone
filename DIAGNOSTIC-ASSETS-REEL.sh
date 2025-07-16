#!/bin/bash

echo "🔍 DIAGNOSTIC ASSETS REEL"
echo "========================="

# 1. Localiser les vrais fichiers assets
echo "📁 Recherche des fichiers assets..."
find /home/ubuntu -name "index-BGktlCn_.js" 2>/dev/null
find /home/ubuntu -name "index-BEb0iJbV.css" 2>/dev/null
find /home/ubuntu -name "dist" -type d 2>/dev/null

echo ""
echo "📂 Contenu dossier JobDone:"
ls -la /home/ubuntu/JobDone/

if [ -d "/home/ubuntu/JobDone/dist" ]; then
    echo ""
    echo "📂 Contenu dist:"
    ls -la /home/ubuntu/JobDone/dist/
    
    if [ -d "/home/ubuntu/JobDone/dist/assets" ]; then
        echo ""
        echo "📂 Contenu assets:"
        ls -la /home/ubuntu/JobDone/dist/assets/
        
        echo ""
        echo "🔍 Recherche des fichiers spécifiques:"
        find /home/ubuntu/JobDone/dist -name "*.js" -o -name "*.css" | head -10
    else
        echo "❌ Pas de dossier assets dans dist"
    fi
else
    echo "❌ Pas de dossier dist"
fi

# 2. Vérifier le build
echo ""
echo "🔨 Vérification du build..."
cd /home/ubuntu/JobDone
if [ -f "package.json" ]; then
    echo "📦 package.json trouvé"
    echo "🔨 Lancement du build..."
    npm run build
    
    echo ""
    echo "📂 Contenu après build:"
    ls -la dist/
    if [ -d "dist/assets" ]; then
        echo "📂 Assets après build:"
        ls -la dist/assets/
    fi
else
    echo "❌ Pas de package.json"
fi

# 3. Permissions
echo ""
echo "🔐 Vérification des permissions:"
ls -la /home/ubuntu/JobDone/dist/ 2>/dev/null || echo "Pas de dist"

# 4. Test direct des fichiers
echo ""
echo "🧪 Test direct des fichiers:"
if [ -f "/home/ubuntu/JobDone/dist/assets/index-BGktlCn_.js" ]; then
    echo "✅ JS trouvé"
    ls -la /home/ubuntu/JobDone/dist/assets/index-BGktlCn_.js
else
    echo "❌ JS non trouvé"
fi

if [ -f "/home/ubuntu/JobDone/dist/assets/index-BEb0iJbV.css" ]; then
    echo "✅ CSS trouvé"
    ls -la /home/ubuntu/JobDone/dist/assets/index-BEb0iJbV.css
else
    echo "❌ CSS non trouvé"
fi

echo ""
echo "🎯 RÉSUMÉ DIAGNOSTIC"
echo "==================="
echo "Dossier de travail: /home/ubuntu/JobDone"
echo "Dist existe: $([ -d "/home/ubuntu/JobDone/dist" ] && echo "✅" || echo "❌")"
echo "Assets existe: $([ -d "/home/ubuntu/JobDone/dist/assets" ] && echo "✅" || echo "❌")"
echo "Fichiers JS: $(find /home/ubuntu/JobDone/dist -name "*.js" 2>/dev/null | wc -l)"
echo "Fichiers CSS: $(find /home/ubuntu/JobDone/dist -name "*.css" 2>/dev/null | wc -l)"