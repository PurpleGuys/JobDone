# GUIDE RÉSOLUTION ERREUR NGINX 500 SUR VPS

## 🚨 SOLUTION IMMÉDIATE

Copiez ce script sur votre VPS et exécutez-le :

```bash
# Copier le script sur le VPS
scp VPS-SOLUTION-IMMEDIATE.sh user@votre-vps:/tmp/

# Se connecter au VPS
ssh user@votre-vps

# Exécuter la solution
sudo bash /tmp/VPS-SOLUTION-IMMEDIATE.sh
```

## 📋 CAUSE PROBABLE

L'erreur nginx 500 vient probablement de :
1. **Application Node.js non démarrée** sur le port 5000
2. **Configuration nginx incorrecte** pour le proxy
3. **Permissions ou timeouts** nginx

## 🔧 SOLUTIONS ÉTAPE PAR ÉTAPE

### 1. Vérifier l'application Node.js
```bash
# Vérifier si l'app tourne
ps aux | grep node

# Tester l'API directement
curl -I http://localhost:5000/api/health

# Si pas accessible, démarrer l'app
cd /chemin/vers/BennesPro
npm start
```

### 2. Corriger la configuration nginx
```bash
# Créer la bonne configuration
sudo nano /etc/nginx/sites-available/bennespro

# Contenu :
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }
}

# Activer la configuration
sudo ln -sf /etc/nginx/sites-available/bennespro /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
```

### 3. Redémarrer nginx
```bash
# Tester la configuration
sudo nginx -t

# Redémarrer nginx
sudo systemctl restart nginx
```

### 4. Vérifier les logs
```bash
# Logs nginx
sudo tail -f /var/log/nginx/error.log

# Logs application
tail -f ~/BennesPro/app.log
```

## 🧪 TESTS DE VÉRIFICATION

```bash
# Test application directe
curl -I http://localhost:5000/

# Test à travers nginx
curl -I http://localhost/

# Test API
curl -s http://localhost:5000/api/health
```

## 📱 SCRIPTS FOURNIS

1. **VPS-SOLUTION-IMMEDIATE.sh** - Solution rapide automatique
2. **VPS-FIX-NGINX-500-ERROR.sh** - Diagnostic complet
3. **VPS-START-BENNESPRO.sh** - Démarrage de l'application
4. **VPS-NGINX-CONFIG-SIMPLE.conf** - Configuration nginx correcte

## 🆘 EN CAS D'ÉCHEC

Si l'erreur 500 persiste :

1. Vérifiez les logs détaillés :
```bash
sudo tail -f /var/log/nginx/error.log
```

2. Vérifiez que l'application Node.js fonctionne :
```bash
curl -v http://localhost:5000/
```

3. Redémarrez tout :
```bash
sudo systemctl stop nginx
sudo pkill -f node
sudo systemctl start nginx
cd /chemin/vers/BennesPro && npm start
```

4. Vérifiez les permissions :
```bash
ls -la /var/log/nginx/
ps aux | grep nginx
```

## ✅ RÉSULTAT ATTENDU

Après application de la solution :
- nginx status : active (running)
- Application Node.js sur port 5000 : accessible
- Site web : accessible sans erreur 500
- API health : retourne 200 OK

Testez sur Firefox : **http://votre-domaine.com**