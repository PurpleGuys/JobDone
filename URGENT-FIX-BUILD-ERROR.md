# CORRECTION URGENTE ERREUR BUILD VPS - STRIPE

## Problème
```
error during build:
Could not resolve entry module "@stripe/stripe-js".
```

## Solution Immédiate

### 1. Sur votre VPS, exécutez:
```bash
# Télécharger et exécuter le script de correction
sudo ./FIX-VPS-BUILD-100-PERCENT.sh
```

### 2. Si le problème persiste:
```bash
# Nettoyer manuellement
rm -rf node_modules package-lock.json dist .vite
grep -v "stripe" package.json > package.json.tmp && mv package.json.tmp package.json
npm install
npm run build
```

### 3. Alternative rapide:
```bash
# Build frontend uniquement (sans le serveur)
cd client
npm run build
cd ..
# Copier le build
cp -r client/dist/* dist/public/
```

## Vérification
```bash
# Vérifier qu'il n'y a plus de références Stripe
grep -r "stripe" . --include="*.js" --include="*.ts" --include="*.tsx" --exclude-dir=node_modules
```

## Configuration PayPlug
- Clé API: `sk_test_2wDsePkdatiFXUsRfeu6m1`
- Mode: TEST
- SDK: Chargé depuis CDN dans index.html

## Build Final
```bash
sudo npm run build
sudo npm start
```

**L'application utilise maintenant 100% PayPlug pour les paiements.**