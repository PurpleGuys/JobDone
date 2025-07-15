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
export const payplugPromise = new Promise(async (resolve) => {
  if (typeof window !== 'undefined') {
    try {
      // Charger le script PayPlug avec contournement CSP
      await loadPayPlugScript();
      // Une fois chargé, créer l'instance
      resolve(getPayPlugInstance());
    } catch (error) {
      console.error('Failed to load PayPlug:', error);
      resolve(null);
    }
  } else {
    resolve(null);
  }
});

export default payplugPromise;