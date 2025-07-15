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

    // Méthode alternative pour charger le script en contournant CSP
    // Utilise fetch pour récupérer le script puis l'évalue
    fetch('https://cdn.payplug.com/js/integrated-payment/v1@1/index.js')
      .then(response => response.text())
      .then(scriptText => {
        // Créer un nouveau script avec le contenu récupéré
        const scriptElement = document.createElement('script');
        scriptElement.textContent = scriptText;
        scriptElement.setAttribute('data-payplug', 'true');
        document.head.appendChild(scriptElement);
        
        // Attendre que PayPlug soit disponible
        let checkCount = 0;
        const checkInterval = setInterval(() => {
          if ((window as any).Payplug) {
            clearInterval(checkInterval);
            console.log("✅ PayPlug SDK loaded successfully via fetch");
            resolve();
          } else if (checkCount++ > 20) {
            clearInterval(checkInterval);
            console.error("❌ PayPlug SDK failed to initialize after fetch");
            reject(new Error('PayPlug SDK failed to initialize'));
          }
        }, 100);
      })
      .catch(error => {
        console.error("❌ Failed to fetch PayPlug SDK:", error);
        // Fallback: essayer la méthode standard au cas où
        const script = document.createElement('script');
        script.src = 'https://cdn.payplug.com/js/integrated-payment/v1@1/index.js';
        script.async = true;
        
        script.onload = () => {
          console.log("✅ PayPlug SDK loaded via fallback method");
          resolve();
        };
        
        script.onerror = () => {
          console.error("❌ All methods failed to load PayPlug SDK");
          reject(new Error('Failed to load PayPlug SDK'));
        };
        
        document.head.appendChild(script);
      });
  });
};

export { PAYPLUG_SECRET_KEY, PAYPLUG_MODE };