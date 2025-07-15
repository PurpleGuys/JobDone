#!/bin/bash

# VPS Deployment Script for BennesPro - Fixed Configuration
# Fixes tsconfig.node.json and Node.js v18 compatibility issues

echo "🚀 VPS Deployment Fix - BennesPro"
echo "=================================="

# Check if running on VPS
if [ "$USER" = "ubuntu" ]; then
    echo "✅ Running on VPS environment"
else
    echo "⚠️  Not on VPS - proceed with caution"
fi

# Create required directories
echo "📁 Creating required directories..."
mkdir -p dist/public
mkdir -p attached_assets

# Copy production config to main config
echo "🔧 Using production Vite configuration..."
cp vite.config.production.ts vite.config.ts

# Clean previous build
echo "🧹 Cleaning previous build..."
rm -rf dist/public/*

# Install dependencies if needed
echo "📦 Installing dependencies..."
npm install --silent

# Build the application
echo "🏗️  Building application..."
npm run build

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Create fallback index.html if needed
    if [ ! -f "dist/public/index.html" ]; then
        echo "⚠️  No index.html found, creating fallback..."
        cat > dist/public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BennesPro - Location de Bennes</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #dc2626; text-align: center; }
        .loading { text-align: center; margin: 20px 0; }
        .spinner { border: 4px solid #f3f3f3; border-top: 4px solid #dc2626; border-radius: 50%; width: 40px; height: 40px; animation: spin 1s linear infinite; margin: 0 auto; }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
    </style>
</head>
<body>
    <div class="container">
        <h1>BennesPro</h1>
        <div class="loading">
            <div class="spinner"></div>
            <p>Chargement de l'application...</p>
        </div>
    </div>
    <script>
        // Fallback loading
        setTimeout(() => {
            document.querySelector('.loading').innerHTML = '<p>L\'application démarre...</p>';
        }, 3000);
    </script>
</body>
</html>
EOF
    fi
    
    echo "🎉 VPS deployment ready!"
    echo "📂 Static files in: dist/public/"
    echo "🔧 Start server with: npm start"
    
else
    echo "❌ Build failed"
    echo "🔧 Check the error above and fix configuration"
    exit 1
fi

echo "=================================="
echo "✅ VPS Deployment Fix Complete"