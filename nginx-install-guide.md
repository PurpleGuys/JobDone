# Guide Installation Nginx BennesPro

## 1. Copier la configuration

```bash
# Copier le fichier sur votre VPS
sudo cp nginx-bennespro.conf /etc/nginx/sites-available/bennespro
```

## 2. Vérifier et adapter les chemins

Éditer le fichier si nécessaire :
```bash
sudo nano /etc/nginx/sites-available/bennespro
```

Vérifier que les chemins correspondent à votre installation :
- `/home/ubuntu/BennesPro` → remplacer par votre chemin réel
- `purpleguy.world` → remplacer par votre domaine

## 3. Activer le site

```bash
# Créer le lien symbolique
sudo ln -s /etc/nginx/sites-available/bennespro /etc/nginx/sites-enabled/

# Supprimer la config par défaut
sudo rm -f /etc/nginx/sites-enabled/default
```

## 4. Tester la configuration

```bash
# Test de syntaxe
sudo nginx -t

# Si OK, recharger nginx
sudo systemctl reload nginx
```

## 5. Installer SSL avec Let's Encrypt

```bash
# Installer certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtenir le certificat SSL
sudo certbot --nginx -d purpleguy.world -d www.purpleguy.world
```

## 6. Vérifier que tout fonctionne

```bash
# Status nginx
sudo systemctl status nginx

# Logs nginx
sudo tail -f /var/log/nginx/bennespro_error.log

# Test site
curl -I https://purpleguy.world
```

## Commandes utiles

```bash
# Redémarrer nginx
sudo systemctl restart nginx

# Voir les logs d'accès
sudo tail -f /var/log/nginx/bennespro_access.log

# Voir les logs d'erreur
sudo tail -f /var/log/nginx/bennespro_error.log

# Renouveler SSL (automatique normalement)
sudo certbot renew --dry-run
```

## Optimisations incluses

✅ Compression Gzip activée
✅ Headers de sécurité (XSS, Clickjacking, etc.)
✅ Support WebSocket
✅ Cache pour fichiers statiques
✅ Timeouts augmentés pour éviter 504
✅ Configuration SSL moderne (A+ sur SSL Labs)
✅ HSTS activé
✅ Support uploads jusqu'à 20MB