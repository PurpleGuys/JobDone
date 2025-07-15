import { PAYPLUG_SECRET_KEY, PAYPLUG_MODE, loadPayPlugScript } from './payplug-config';

// Type declarations for PayPlug
declare global {
  interface Window {
    Payplug: any;
  }
}

// PayPlug instance will be created when the script is loaded
export const getPayPlugInstance = () => {
  if (typeof window !== 'undefined' && window.Payplug) {
    const testMode = PAYPLUG_MODE === 'test';
    return new window.Payplug.IntegratedPayment(testMode);
  }
  return null;
};

// Export PayPlug promise for compatibility with Stripe-like pattern
export const payplugPromise = new Promise((resolve) => {
  if (typeof window !== 'undefined') {
    // Attendre que le DOM et PayPlug soient chargés
    const checkPayPlug = () => {
      if (window.Payplug) {
        console.log('✅ PayPlug SDK ready');
        resolve(getPayPlugInstance());
      } else {
        // Réessayer après un court délai
        setTimeout(checkPayPlug, 100);
      }
    };
    
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', checkPayPlug);
    } else {
      checkPayPlug();
    }
  } else {
    resolve(null);
  }
});

export default payplugPromise;