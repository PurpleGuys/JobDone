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

// Fonction pour charger PayPlug SDK
export const loadPayPlugScript = (): Promise<void> => {
  // Le SDK est déjà chargé via payplug-loader.js dans index.html
  return new Promise((resolve, reject) => {
    // Utiliser la fonction globale loadPayPlugSDK si disponible
    if ((window as any).loadPayPlugSDK) {
      (window as any).loadPayPlugSDK()
        .then(() => resolve())
        .catch((error: Error) => reject(error));
    } else if ((window as any).Payplug) {
      // Déjà chargé
      console.log("✅ PayPlug SDK already loaded");
      resolve();
    } else {
      // Fallback au cas où
      let checkCount = 0;
      const checkInterval = setInterval(() => {
        if ((window as any).Payplug) {
          clearInterval(checkInterval);
          console.log("✅ PayPlug SDK detected");
          resolve();
        } else if (checkCount++ > 50) {
          clearInterval(checkInterval);
          console.error("❌ PayPlug SDK not found");
          reject(new Error('PayPlug SDK not found'));
        }
      }, 100);
    }
  });
};

export { PAYPLUG_SECRET_KEY, PAYPLUG_MODE };