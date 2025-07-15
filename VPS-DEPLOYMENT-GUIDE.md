# 🚀 VPS Deployment Guide - BennesPro

## Problèmes résolus ✅
- ✅ Erreur `tsconfig.node.json` manquant
- ✅ Erreur `import.meta.dirname` non compatible Node.js v18
- ✅ Erreur `Cannot find package 'stripe'` dans server/routes.ts
- ✅ Build Vite compatible production VPS

## Installation VPS - Guide rapide

### 1. Prérequis VPS
```bash
# Vérifier Node.js version
node --version  # Doit être >= 18.0.0
npm --version   # Doit être >= 8.0.0

# Si Node.js pas installé:
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 2. Déploiement automatique
```bash
# Cloner le projet
git clone <votre-repo-url>
cd JobDone

# Exécuter le script de déploiement VPS
chmod +x vps-fix-complete.sh
./vps-fix-complete.sh
```

### 3. Configuration environnement
```bash
# Créer .env avec vos clés
cp .env.example .env
nano .env

# Variables requises:
DATABASE_URL=your_postgresql_url
PAYPLUG_SECRET_KEY=your_payplug_key
GOOGLE_MAPS_API_KEY=your_google_maps_key
SENDGRID_API_KEY=your_sendgrid_key
```

### 4. Démarrage serveur
```bash
# Démarrer en mode production
npm start

# Ou avec PM2 (recommandé):
sudo npm install -g pm2
pm2 start npm --name "bennespro" -- start
pm2 save
pm2 startup
```

## Configuration Nginx (optionnel)
```nginx
server {
    listen 80;
    server_name yourdomain.com;
    
    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Dépannage VPS

### Si build échoue encore:
```bash
# Nettoyer complètement
rm -rf node_modules
rm -rf dist
npm cache clean --force

# Réinstaller
npm install
npm run build
```

### Vérifier que l'application fonctionne:
```bash
# Tester l'API
curl http://localhost:5000/api/health
# Doit retourner: {"status":"ok"}

# Tester interface web
curl -I http://localhost:5000
# Doit retourner: 200 OK
```

## ✅ Résolution des erreurs

### 1. tsconfig.node.json manquant
- **Problème**: `ENOENT: no such file or directory, open 'tsconfig.node.json'`
- **Solution**: Fichier créé automatiquement par le script

### 2. import.meta.dirname Node.js v18
- **Problème**: `import.meta.dirname is not defined`
- **Solution**: Utilisation de `fileURLToPath(import.meta.url)` dans vite.config.production.ts

### 3. Stripe package manquant
- **Problème**: `Cannot find package 'stripe'`
- **Solution**: Références Stripe supprimées, utilisation de PayPlug uniquement

## Support
Si vous rencontrez encore des problèmes:
1. Vérifier les logs: `npm run dev`
2. Vérifier la version Node.js: `node --version`
3. Vérifier les permissions: `ls -la`
4. Nettoyer et réinstaller: `rm -rf node_modules && npm install`

## Structure finale
```
JobDone/
├── tsconfig.node.json          ✅ Créé
├── vite.config.production.ts   ✅ Compatible Node.js v18
├── vps-fix-complete.sh         ✅ Script de déploiement
├── dist/public/                ✅ Build production
└── server/routes.ts            ✅ Sans Stripe
```

**🎉 Votre application BennesPro est maintenant prête pour le déploiement VPS!**