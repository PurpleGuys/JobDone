# VPS DEPLOYMENT GUIDE - FINAL VERSION
## BennesPro - Sans Stripe, Sans Scripts d'injection

### 🎯 OBJECTIF
Déployer BennesPro sur VPS en éliminant complètement :
- ✅ Toutes les dépendances Stripe
- ✅ Scripts d'injection Replit
- ✅ Erreurs CSP (Content Security Policy)
- ✅ Violations de sécurité scripts tiers

### 📋 PRÉREQUIS VPS
1. **Node.js v18+ installé**
2. **npm ou yarn**
3. **PostgreSQL configuré**
4. **Variables d'environnement correctes**

### 🔧 ÉTAPES DE DÉPLOIEMENT

#### 1. Configuration environnement
```bash
# Créer .env sur le VPS
cat > .env << 'EOF'
NODE_ENV=production
DATABASE_URL=postgresql://user:password@localhost:5432/bennespro
JWT_SECRET=your-super-secret-jwt-key-change-this
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
SENDGRID_API_KEY=your-sendgrid-api-key
EOF
```

#### 2. Installation dépendances
```bash
# Nettoyer le cache
npm cache clean --force
rm -rf node_modules

# Installer les packages
npm install

# Vérifier qu'il n'y a pas de dépendances Stripe
npm list | grep -i stripe || echo "✅ Pas de dépendances Stripe"
```

#### 3. Build production propre
```bash
# Créer tsconfig.node.json si manquant
cat > tsconfig.node.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "allowImportingTsExtensions": true,
    "strict": false,
    "skipLibCheck": true,
    "noEmit": true,
    "types": ["node"],
    "baseUrl": ".",
    "paths": {
      "@/*": ["./client/src/*"],
      "@shared/*": ["./shared/*"],
      "@assets/*": ["./attached_assets/*"]
    }
  },
  "include": [
    "vite.config.ts",
    "vite.config.production.ts",
    "tailwind.config.ts",
    "drizzle.config.ts",
    "postcss.config.js",
    "server/**/*",
    "shared/**/*",
    "scripts/**/*"
  ],
  "exclude": ["node_modules", "dist"]
}
EOF

# Build sans erreurs
npm run build
```

#### 4. Créer vite.config.production.ts
```bash
cat > vite.config.production.ts << 'EOF'
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";
import { fileURLToPath } from "url";

// Compatibility avec Node.js v18
const __dirname = path.dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./client/src"),
      "@shared": path.resolve(__dirname, "./shared"),
      "@assets": path.resolve(__dirname, "./attached_assets"),
    },
  },
  build: {
    outDir: "dist",
    emptyOutDir: true,
    rollupOptions: {
      input: {
        main: path.resolve(__dirname, "client/index.html"),
      },
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          ui: ['@radix-ui/react-dialog', '@radix-ui/react-dropdown-menu'],
        },
      },
    },
  },
  optimizeDeps: {
    include: ["react", "react-dom"],
  },
  server: {
    port: 5173,
    host: true,
  },
  preview: {
    port: 5173,
    host: true,
  },
});
EOF
```

#### 5. Lancer l'application
```bash
# Démarrer avec PM2 (recommandé)
pm2 start ecosystem.config.cjs

# OU démarrer directement
NODE_ENV=production npx tsx server/index.ts
```

### 🔍 VÉRIFICATIONS POST-DÉPLOIEMENT

#### 1. Vérifier l'API
```bash
curl http://localhost:5000/api/health
# Doit retourner: {"status":"ok"}
```

#### 2. Vérifier l'interface
```bash
curl -I http://localhost:5000
# Doit retourner: 200 OK
```

#### 3. Tester les logs
```bash
# Vérifier les logs PM2
pm2 logs

# Vérifier qu'il n'y a pas d'erreurs Stripe
pm2 logs | grep -i stripe || echo "✅ Pas d'erreurs Stripe"
```

### 🚨 DÉPANNAGE

#### Erreur "tsconfig.node.json manquant"
```bash
# Créer le fichier (voir étape 3)
```

#### Erreur "import.meta.dirname"
```bash
# Utiliser vite.config.production.ts (voir étape 4)
```

#### Erreur "Missing Stripe key"
```bash
# Vérifier qu'il n'y a pas de références Stripe dans le code
grep -r "STRIPE" client/src/ || echo "✅ Pas de références Stripe"
```

### 🎉 CONFIGURATION NGINX (Optionnel)
```nginx
server {
    listen 80;
    server_name yourdomain.com;
    
    # CSP sans Stripe
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.payplug.com https://secure.payplug.com https://api.payplug.com https://maps.googleapis.com https://maps.gstatic.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https: blob:; connect-src 'self' https://api.payplug.com https://secure.payplug.com https://maps.googleapis.com; font-src 'self' https://fonts.gstatic.com; frame-src 'self' https://secure.payplug.com;" always;
    
    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### ✅ SUCCÈS
Votre application BennesPro est maintenant déployée sans :
- ❌ Dépendances Stripe
- ❌ Scripts d'injection Replit
- ❌ Erreurs CSP
- ❌ Violations de sécurité

### 📞 SUPPORT
En cas de problème :
1. Vérifiez les logs : `pm2 logs`
2. Testez l'API : `curl http://localhost:5000/api/health`
3. Redémarrez : `pm2 restart all`

---
**Version finale - Juillet 2025**  
**BennesPro - Clean deployment sans scripts d'injection**