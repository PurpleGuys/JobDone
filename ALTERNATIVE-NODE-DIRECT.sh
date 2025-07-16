#!/bin/bash

echo "🔧 ALTERNATIVE NODE DIRECT"
echo "=========================="

# 1. Arrêter PM2
pm2 stop all
pm2 delete all

# 2. Compiler TypeScript
echo "🔨 Compilation TypeScript..."
npx tsc --outDir build server/index.ts --target es2022 --module commonjs --moduleResolution node --allowSyntheticDefaultImports --esModuleInterop --skipLibCheck

# 3. Si compilation échoue, utiliser autre approche
if [ ! -f "build/server/index.js" ]; then
    echo "❌ Compilation échouée, utilisation ts-node..."
    npm install ts-node --save-dev
    
    # Config PM2 avec ts-node
    cat > ecosystem.config.cjs << 'EOF'
module.exports = {
  apps: [{
    name: 'bennespro',
    script: 'npx',
    args: 'ts-node server/index.ts',
    env: {
      NODE_ENV: 'production',
      PORT: '5000'
    }
  }]
}
EOF
else
    echo "✅ Compilation réussie"
    
    # Config PM2 avec fichier compilé
    cat > ecosystem.config.cjs << 'EOF'
module.exports = {
  apps: [{
    name: 'bennespro',
    script: 'build/server/index.js',
    env: {
      NODE_ENV: 'production',
      PORT: '5000'
    }
  }]
}
EOF
fi

# 4. Démarrer PM2
echo "🚀 Démarrage PM2..."
pm2 start ecosystem.config.cjs

# 5. Vérifier
sleep 10
echo "📊 Status:"
pm2 list

echo "🔍 Port 5000:"
ss -tlnp | grep ":5000" || echo "❌ Pas de port 5000"

echo "📋 Logs:"
pm2 logs --lines 5

echo ""
echo "✅ DONE"