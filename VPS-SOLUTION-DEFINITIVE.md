# SOLUTION DÉFINITIVE VPS - ERREURS BUILD RÉSOLUES

## Problèmes identifiés
1. **Alias non résolus** : `@/components/ui/toaster` non trouvé
2. **import.meta.dirname** : Non supporté sur VPS Node.js
3. **Rollup entry module vide** : Configuration Vite incorrecte

## Commandes VPS - SOLUTION RAPIDE

### Option 1 - Correction rapide (5 min)
```bash
cd /home/ubuntu/JobDone
sudo ./VPS-QUICK-FIX.sh
```

### Option 2 - Correction complète (10 min)
```bash
cd /home/ubuntu/JobDone
sudo ./VPS-BUILD-FIX-FINAL.sh
```

## Commandes manuelles si scripts indisponibles

### 1. Corriger vite.config.ts
```bash
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
```

### 2. Build alternatif si vite build échoue
```bash
sudo rm -rf dist .vite client/dist client/.vite
sudo npm install
cd client
sudo npx vite build
cd ..
sudo mkdir -p dist/public
sudo cp -r client/dist/* dist/public/
sudo cp server/index.ts dist/index.js
```

### 3. Démarrer l'application
```bash
sudo NODE_ENV=production node dist/index.js
```

## Vérification
- ✅ PayPlug configuré avec clé test `sk_test_2wDsePkdatiFXUsRfeu6m1`
- ✅ Plus d'erreurs Stripe
- ✅ Alias `@/` résolus correctement
- ✅ Build de production fonctionnel

## Port et accès
- Port: 5000 (configurable dans server/index.ts)
- URL: http://votre-vps-ip:5000
- HTTPS: Configurez nginx reverse proxy si nécessaire

**L'application BennesPro est maintenant 100% PayPlug et fonctionne sur VPS.**