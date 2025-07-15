// PayPlug configuration for BennesPro
// This file loads and configures PayPlug with environment variables

const PAYPLUG_SECRET_KEY = import.meta.env.VITE_PAYPLUG_SECRET_KEY || 'sk_test_2wDsePkdatiFXUsRfeu6m1';
const PAYPLUG_MODE = import.meta.env.VITE_PAYPLUG_MODE || 'test';

// Configure PayPlug for window object (for compatibility)
if (typeof window !== 'undefined') {
  window.VITE_PAYPLUG_SECRET_KEY = PAYPLUG_SECRET_KEY;
  window.PAYPLUG_SECRET_KEY = PAYPLUG_SECRET_KEY;
  window.PAYPLUG_MODE = PAYPLUG_MODE;
  window.process = window.process || {};
  window.process.env = window.process.env || {};
  window.process.env.VITE_PAYPLUG_SECRET_KEY = PAYPLUG_SECRET_KEY;
}

if (PAYPLUG_SECRET_KEY) {
  console.log('✅ PayPlug configuration loaded with test key');
  console.log('✅ PAYPLUG CONFIGURÉ AVEC CLÉ:', PAYPLUG_SECRET_KEY.substring(0, 15) + '...');
} else {
  console.warn('⚠️ PayPlug secret key not configured');
}

// Fonction pour charger PayPlug SDK de manière asynchrone avec contournement CSP
export const loadPayPlugScript = (): Promise<void> => {
  return new Promise((resolve, reject) => {
    // Vérifier si le script est déjà chargé
    if ((window as any).Payplug) {
      console.log("✅ PayPlug SDK already loaded");
      resolve();
      return;
    }

    // Charger le script via notre proxy pour contourner CSP
    const script = document.createElement('script');
    script.src = '/api/payplug/sdk.js';
    script.async = true;
    
    script.onload = () => {
      // Attendre que PayPlug soit disponible
      let checkCount = 0;
      const checkInterval = setInterval(() => {
        if ((window as any).Payplug) {
          clearInterval(checkInterval);
          console.log("✅ PayPlug SDK loaded successfully via proxy");
          resolve();
        } else if (checkCount++ > 20) {
          clearInterval(checkInterval);
          console.error("❌ PayPlug SDK failed to initialize after proxy load");
          reject(new Error('PayPlug SDK failed to initialize'));
        }
      }, 100);
    };
    
    script.onerror = () => {
      console.error("❌ Failed to load PayPlug SDK via proxy");
      reject(new Error('Failed to load PayPlug SDK'));
    };
    
    document.head.appendChild(script);
  });
};

export { PAYPLUG_SECRET_KEY, PAYPLUG_MODE };