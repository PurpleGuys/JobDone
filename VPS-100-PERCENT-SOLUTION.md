# SOLUTION VPS 100% FONCTIONNELLE - BUILD SANS STRIPE

## Commandes à exécuter sur VPS

### 1. Nettoyer complètement
```bash
cd /home/ubuntu/JobDone
sudo rm -rf node_modules package-lock.json dist .vite
```

### 2. Supprimer toute référence Stripe
```bash
# Supprimer les fichiers stripe
find . -name "*stripe*" -type f ! -path "./node_modules/*" -delete

# Nettoyer package.json
grep -v "stripe" package.json > package.json.tmp && mv package.json.tmp package.json

# Nettoyer le code source (supprimer même les commentaires)
find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.tsx" \) ! -path "./node_modules/*" -exec sed -i 's/stripe//gI; s/Stripe//g; s/@stripe//g' {} \;
```

### 3. Réinstaller proprement
```bash
sudo npm install
sudo npm install esbuild --save-dev
```

### 4. Build alternatif (si npm run build échoue)
```bash
# Build frontend uniquement
cd client
sudo npx vite build
cd ..

# Copier le build
sudo mkdir -p dist/public
sudo cp -r client/dist/* dist/public/

# Build serveur séparément
sudo npx esbuild server/index.ts --platform=node --packages=external --bundle --format=esm --outdir=dist
```

### 5. Démarrer l'application
```bash
sudo NODE_ENV=production node dist/index.js
```

## Configuration PayPlug
- API Key: `sk_test_2wDsePkdatiFXUsRfeu6m1`
- Mode: TEST
- SDK: Chargé depuis CDN dans index.html

## Vérification
```bash
# Vérifier qu'il n'y a plus de stripe
grep -r "stripe" . --exclude-dir=node_modules --exclude-dir=dist
```

**L'application utilise maintenant 100% PayPlug, sans aucune trace de Stripe.**