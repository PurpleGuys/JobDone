# 🚀 GUIDE VPS 100% FONCTIONNEL

## OPTION 1: MÉGA SCRIPT COMPLET (Recommandé)

Ce script fait TOUT de A à Z :

```bash
# Sur votre VPS
wget https://votre-url/VPS-MEGA-SCRIPT-10000-PERCENT.sh
chmod +x VPS-MEGA-SCRIPT-10000-PERCENT.sh
sudo ./VPS-MEGA-SCRIPT-10000-PERCENT.sh
```

### Ce que fait le méga script :
1. ✅ Met à jour le système Ubuntu
2. ✅ Installe Node.js v20, PostgreSQL, Redis, Nginx
3. ✅ Configure la base de données
4. ✅ Clone/configure votre application
5. ✅ Crée tous les fichiers nécessaires
6. ✅ Build l'application
7. ✅ Configure Nginx avec proxy
8. ✅ Crée un service systemd
9. ✅ Configure le firewall
10. ✅ Démarre tout automatiquement
11. ✅ Teste que tout fonctionne

## OPTION 2: NUCLEAR CLEAN (Réparation rapide)

Si votre VPS a déjà l'application mais rien ne marche :

```bash
# Sur votre VPS
wget https://votre-url/VPS-NUCLEAR-CLEAN.sh
chmod +x VPS-NUCLEAR-CLEAN.sh
sudo ./VPS-NUCLEAR-CLEAN.sh
```

### Ce que fait le nuclear clean :
1. 🔥 Kill tous les processus
2. 🧹 Nettoie complètement Nginx
3. 🗑️  Supprime tous les logs
4. 📦 Réinstalle les dépendances
5. 🔨 Force le build
6. ⚙️  Reconfigure Nginx simplement
7. 🚀 Redémarre tout
8. 🧪 Teste que ça marche

## APRÈS L'INSTALLATION

### 1. Configurer les clés API
Éditez le fichier `.env` :
```bash
nano ~/BennesPro/.env
```

Ajoutez vos vraies clés :
- `PAYPLUG_SECRET_KEY`
- `VITE_PAYPLUG_PUBLIC_KEY`
- `GOOGLE_MAPS_API_KEY`
- `SENDGRID_API_KEY`

### 2. Configurer SSL (HTTPS)
```bash
sudo certbot --nginx -d purpleguy.world -d www.purpleguy.world
```

### 3. Vérifier le status
```bash
# Script de monitoring créé automatiquement
~/check-bennespro.sh

# Ou manuellement
sudo systemctl status bennespro
sudo systemctl status nginx
curl http://localhost/api/health
```

### 4. Voir les logs
```bash
# Logs application
tail -f /var/log/bennespro/app.log

# Logs Nginx
sudo tail -f /var/log/nginx/error.log

# Logs système
sudo journalctl -u bennespro -f
```

## COMMANDES UTILES

```bash
# Redémarrer l'application
sudo systemctl restart bennespro

# Redémarrer Nginx
sudo systemctl restart nginx

# Voir tous les processus
ps aux | grep node

# Tuer tous les processus node
sudo pkill -f node

# Rebuild l'application
cd ~/BennesPro && npm run build

# Voir l'utilisation mémoire
htop
```

## EN CAS DE PROBLÈME

### Erreur 500 Nginx
```bash
# Vérifier que l'app tourne
curl http://localhost:5000/api/health

# Si pas de réponse, redémarrer
sudo systemctl restart bennespro
```

### Application ne démarre pas
```bash
# Voir les erreurs
tail -50 /var/log/bennespro/app.log

# Démarrer manuellement pour debug
cd ~/BennesPro
node server/index.js
```

### Port déjà utilisé
```bash
# Voir qui utilise le port 5000
sudo lsof -i :5000

# Tuer le processus
sudo kill -9 <PID>
```

## RÉSULTAT ATTENDU

Après exécution du script, vous devez avoir :
- ✅ Site accessible sur http://votre-ip/
- ✅ API health retourne `{"status":"ok"}`
- ✅ Nginx actif sans erreur 500
- ✅ PostgreSQL avec base de données
- ✅ Service systemd bennespro actif
- ✅ Logs dans /var/log/bennespro/

## SUPPORT

Si ça ne marche toujours pas après le méga script :
1. Exécutez le nuclear clean
2. Vérifiez les logs : `tail -100 /var/log/bennespro/app.log`
3. Testez manuellement : `cd ~/BennesPro && node server/index.js`