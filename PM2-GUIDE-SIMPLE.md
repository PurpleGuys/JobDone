# 🚀 GUIDE PM2 SIMPLE ET CARRÉ

## INSTALLATION RAPIDE

```bash
# 1. Installer PM2 globalement
sudo npm install -g pm2

# 2. Aller dans votre application
cd ~/BennesPro

# 3. Démarrer avec PM2
pm2 start ecosystem.config.cjs --env production

# 4. Sauvegarder la config
pm2 save
pm2 startup
```

## COMMANDES PM2 ESSENTIELLES

```bash
# Voir status
pm2 status

# Voir logs en temps réel
pm2 logs

# Redémarrer
pm2 restart all

# Recharger sans downtime
pm2 reload all

# Arrêter
pm2 stop all

# Supprimer
pm2 delete all

# Monitoring temps réel
pm2 monit
```

## CONFIGURATION ECOSYSTEM

Le fichier `ecosystem.config.cjs` configure PM2 :
- **Cluster mode** : Utilise tous les CPU
- **Auto-restart** : Redémarre si crash
- **Logs** : Dans le dossier `logs/`
- **Memory limit** : Redémarre si >500MB

## DÉMARRAGE SIMPLE

```bash
# Option 1: Avec ecosystem file
pm2 start ecosystem.config.cjs

# Option 2: Direct
pm2 start server/index.ts --name bennespro --interpreter tsx

# Option 3: Avec npm
pm2 start npm --name bennespro -- start
```

## LOGS PM2

```bash
# Tous les logs
pm2 logs

# Logs d'une app
pm2 logs bennespro

# Clear logs
pm2 flush

# Logs dans fichiers
tail -f logs/pm2-out.log
tail -f logs/pm2-error.log
```

## AUTO-START AU BOOT

```bash
# Générer script startup
pm2 startup

# Copier/coller la commande donnée
# Puis sauvegarder
pm2 save
```

## NGINX + PM2

Configuration Nginx simple :
```nginx
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## MONITORING

```bash
# Dashboard temps réel
pm2 monit

# Info détaillée
pm2 info bennespro

# Métriques
pm2 status
```

## RÉSOLUTION PROBLÈMES

### App ne démarre pas
```bash
# Voir erreurs
pm2 logs --err

# Démarrer en mode fork pour debug
pm2 start server/index.ts --no-daemon
```

### Port déjà utilisé
```bash
# Voir qui utilise le port
sudo lsof -i :5000

# Kill et restart
pm2 kill
pm2 start ecosystem.config.cjs
```

### Logs trop gros
```bash
# Rotation automatique des logs
pm2 install pm2-logrotate

# Ou nettoyer manuellement
pm2 flush
```

## SCRIPT TOUT-EN-UN

Exécutez simplement :
```bash
bash VPS-PM2-SIMPLE.sh
```

Ce script fait tout :
- ✅ Installe PM2
- ✅ Configure l'app
- ✅ Démarre en cluster
- ✅ Configure Nginx
- ✅ Active au boot

C'est simple, carré, et ça marche !