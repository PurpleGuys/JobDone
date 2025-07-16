# Correction Manuelle Nginx

## Problèmes identifiés:
1. `temp_file_write_size` n'est pas une directive valide nginx
2. La syntaxe `listen ... http2` est dépréciée dans les nouvelles versions

## Solution rapide:

```bash
# 1. Éditer le fichier
sudo nano /etc/nginx/sites-available/bennespro
```

## 2. Corrections à faire:

### Supprimer cette ligne (ligne 71):
```
temp_file_write_size 64k;
```

### Remplacer (lignes 16-17):
```
listen 443 ssl http2;
listen [::]:443 ssl http2;
```

### Par:
```
listen 443 ssl;
listen [::]:443 ssl;
http2 on;
```

## 3. Sauvegarder et tester:
```bash
# Tester
sudo nginx -t

# Si OK, démarrer
sudo systemctl start nginx
sudo systemctl enable nginx

# Vérifier
sudo systemctl status nginx
```

## Alternative: Utiliser la version simple

Si trop d'erreurs, utilisez la configuration simple:
```bash
sudo cp nginx-simple.conf /etc/nginx/sites-available/bennespro
sudo nginx -t
sudo systemctl restart nginx
```