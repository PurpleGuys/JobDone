#!/bin/bash

echo "================================="
echo "CORRECTION RAPIDE VPS - ALIAS FIX"
echo "================================="

cd /home/ubuntu/JobDone

# 1. Corriger vite.config.ts pour VPS
echo "→ Correction vite.config.ts..."
sudo tee vite.config.ts > /dev/null << 'EOF'
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "client", "src"),
      "@shared": path.resolve(__dirname, "shared"),
      "@assets": path.resolve(__dirname, "attached_assets"),
    },
  },
  root: path.resolve(__dirname, "client"),
  build: {
    outDir: path.resolve(__dirname, "dist/public"),
    emptyOutDir: true,
  },
});
EOF

# 2. Nettoyer et rebuild
echo "→ Nettoyage et rebuild..."
sudo rm -rf dist .vite client/dist client/.vite
sudo npm install

# 3. Build frontend uniquement
echo "→ Build frontend..."
cd client
sudo npx vite build
cd ..

# 4. Copier le build
echo "→ Copie du build..."
sudo mkdir -p dist/public
sudo cp -r client/dist/* dist/public/

# 5. Copier le serveur
echo "→ Copie du serveur..."
sudo cp server/index.ts dist/index.js

echo "================================="
echo "✅ CORRECTION RAPIDE TERMINÉE"
echo "================================="
echo ""
echo "Démarrer avec:"
echo "  sudo NODE_ENV=production node dist/index.js"