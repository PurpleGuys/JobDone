# Solution PayPlug VPS - Guide Complet de Déploiement Production

## Le Problème
Le VPS retourne une erreur 404 pour `/api/payplug/sdk.js` et les CSP bloquent le chargement direct depuis `https://cdn.payplug.com`.

## Solution Production Propre

### 1. Configuration Nginx (OBLIGATOIRE)

Ajouter ces headers dans votre configuration nginx du VPS:

```nginx
# Dans /etc/nginx/sites-available/bennespro
server {
    listen 443 ssl http2;
    server_name purpleguy.world;
    
    # ... votre config SSL existante ...
    
    root /var/www/bennespro/dist/public;
    index index.html;
    
    # Headers CSP pour PayPlug - IMPORTANT: tout sur une ligne
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.payplug.com https://secure.payplug.com https://api.payplug.com https://maps.googleapis.com https://maps.gstatic.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https: blob:; connect-src 'self' https://api.payplug.com https://secure.payplug.com https://cdn.payplug.com https://maps.googleapis.com ws: wss:; font-src 'self' https://fonts.gstatic.com; frame-src 'self' https://secure.payplug.com https://api.payplug.com;" always;
    
    # Autres headers de sécurité
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Servir les fichiers statiques
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Proxy API vers backend Node.js
    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 2. Chargement Direct du SDK

Modifier `client/index.html` pour charger PayPlug directement:

```html
<head>
    <!-- ... autres balises ... -->
    
    <!-- PayPlug SDK - Chargement direct -->
    <script src="https://cdn.payplug.com/js/integrated-payment/v1@1/index.js"></script>
</head>
```

### 3. Simplifier le Code JavaScript

Dans `client/src/lib/payplug.ts`:

```typescript
// PayPlug instance simple et directe
export const getPayPlugInstance = () => {
  if (typeof window !== 'undefined' && window.Payplug) {
    return new window.Payplug.IntegratedPayment(true); // true = mode test
  }
  return null;
};

export const payplugPromise = new Promise((resolve) => {
  if (typeof window !== 'undefined') {
    // Attendre que le DOM soit chargé
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => {
        resolve(getPayPlugInstance());
      });
    } else {
      resolve(getPayPlugInstance());
    }
  } else {
    resolve(null);
  }
});
```

### 4. Variables d'Environnement VPS

Dans `.env` sur le VPS:
```
PAYPLUG_SECRET_KEY=sk_test_2wDsePkdatiFXUsRfeu6m1
VITE_PAYPLUG_MODE=test
NODE_ENV=production
```

### 5. Commandes de Déploiement

```bash
# Sur le VPS
cd /var/www/bennespro

# 1. Mettre à jour le code
git pull

# 2. Installer les dépendances
npm install

# 3. Build
npm run build

# 4. Mettre à jour nginx
sudo nano /etc/nginx/sites-available/bennespro
# Ajouter les headers CSP ci-dessus

# 5. Tester et recharger nginx
sudo nginx -t
sudo systemctl reload nginx

# 6. Redémarrer l'app
sudo systemctl restart bennespro
```

## Points Critiques

1. **CSP Headers**: DOIVENT être configurés dans nginx, pas dans Node.js
2. **SDK Loading**: Charger directement depuis le CDN PayPlug dans index.html
3. **Pas de Proxy**: Ne PAS utiliser de route proxy `/api/payplug/sdk.js`
4. **Mode Test**: Utiliser la clé test `sk_test_2wDsePkdatiFXUsRfeu6m1`

## Vérification

Après déploiement, vérifier dans la console du navigateur:
```javascript
// Doit retourner true
window.Payplug !== undefined

// Doit créer une instance
new window.Payplug.IntegratedPayment(true)
```

## Erreurs Communes et Solutions

- **404 sur /api/payplug/sdk.js**: Normal, on n'utilise plus cette route
- **CSP blocked**: Vérifier les headers nginx
- **PayPlug undefined**: Attendre le chargement complet du DOM