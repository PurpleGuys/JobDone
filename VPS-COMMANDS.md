# COMMANDES VPS POUR RÉSOUDRE ERREUR NGINX 500

## 1. Diagnostic complet
```bash
# Copiez ce script sur votre VPS et exécutez-le
bash VPS-FIX-NGINX-500-ERROR.sh
```

## 2. Commandes manuelles de diagnostic

### Vérifier les services
```bash
# Status nginx
sudo systemctl status nginx

# Status application
ps aux | grep -E "(node|tsx|npm)" | grep -v grep

# Ports utilisés
sudo netstat -tlnp | grep -E "(80|443|5000)"
```

### Vérifier les logs
```bash
# Logs nginx
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log

# Logs application (si elle tourne)
tail -f ~/BennesPro/app.log
```

### Tester la connectivité
```bash
# Test backend direct
curl -I http://localhost:5000/
curl -s http://localhost:5000/api/health

# Test nginx
curl -I http://localhost/
```

## 3. Solutions étape par étape

### Solution 1: Redémarrer nginx
```bash
sudo systemctl restart nginx
sudo systemctl status nginx
```

### Solution 2: Configurer nginx correctement
```bash
# Créer la configuration
sudo cp VPS-NGINX-CONFIG-SIMPLE.conf /etc/nginx/sites-available/bennespro

# Activer le site
sudo ln -sf /etc/nginx/sites-available/bennespro /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Tester et recharger
sudo nginx -t
sudo systemctl reload nginx
```

### Solution 3: Démarrer l'application
```bash
# Exécuter le script de démarrage
bash VPS-START-BENNESPRO.sh
```

### Solution 4: Vérification complète
```bash
# Vérifier que tout fonctionne
sudo systemctl status nginx
ps aux | grep node
curl -I http://localhost:5000/
curl -I http://localhost/
```

## 4. Debugging avancé

### Si l'erreur 500 persiste
```bash
# Augmenter le niveau de log nginx
sudo nano /etc/nginx/nginx.conf
# Changer: error_log /var/log/nginx/error.log warn;
# En: error_log /var/log/nginx/error.log debug;

# Redémarrer nginx
sudo systemctl restart nginx

# Tester et voir les logs détaillés
curl -I http://localhost/
sudo tail -f /var/log/nginx/error.log
```

### Vérifier les permissions
```bash
# Vérifier les permissions des fichiers
ls -la /var/log/nginx/
ls -la ~/BennesPro/

# Vérifier l'utilisateur nginx
ps aux | grep nginx
```

## 5. Configuration type qui fonctionne

### Fichier /etc/nginx/sites-available/bennespro
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
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }
}
```

## 6. Commandes finales de vérification
```bash
# Vérifier que tout est OK
sudo systemctl is-active nginx
sudo systemctl is-active nodejs 2>/dev/null || echo "Service nodejs non configuré"

# Test final
curl -I http://localhost/
curl -s http://localhost/api/health
```

## En cas d'urgence
Si rien ne fonctionne, redémarrez complètement:
```bash
sudo systemctl stop nginx
sudo pkill -f node
sudo systemctl start nginx
bash VPS-START-BENNESPRO.sh
```