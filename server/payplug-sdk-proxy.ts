import { Request, Response } from 'express';

// Cache pour stocker le SDK PayPlug
let payplugSDKCache: string | null = null;
let cacheTimestamp: number = 0;
const CACHE_DURATION = 3600000; // 1 heure en millisecondes

export async function servePayPlugSDK(req: Request, res: Response) {
  try {
    const now = Date.now();
    
    // Utiliser le cache si disponible et pas expiré
    if (payplugSDKCache && (now - cacheTimestamp) < CACHE_DURATION) {
      res.type('application/javascript');
      res.setHeader('Cache-Control', 'public, max-age=3600');
      res.setHeader('X-Content-Type-Options', 'nosniff');
      return res.send(payplugSDKCache);
    }

    // Récupérer le SDK depuis PayPlug
    const fetch = (await import('node-fetch')).default;
    const response = await fetch('https://cdn.payplug.com/js/integrated-payment/v1@1/index.js', {
      headers: {
        'User-Agent': 'BennesPro/1.0'
      }
    });

    if (!response.ok) {
      throw new Error(`Failed to fetch PayPlug SDK: ${response.status}`);
    }

    const sdkContent = await response.text();
    
    // Mettre en cache
    payplugSDKCache = sdkContent;
    cacheTimestamp = now;

    // Servir le contenu
    res.type('application/javascript');
    res.setHeader('Cache-Control', 'public, max-age=3600');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.send(sdkContent);

  } catch (error: any) {
    console.error('Failed to serve PayPlug SDK:', error);
    
    // En cas d'erreur, servir un script minimal qui évite les erreurs
    res.type('application/javascript');
    res.status(200).send(`
      // PayPlug SDK could not be loaded from CDN
      console.error('PayPlug SDK loading failed: ${error.message}');
      window.PayplugSDKError = '${error.message}';
    `);
  }
}