import { PAYPLUG_SECRET_KEY, PAYPLUG_MODE } from './payplug-config';

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
    const checkPayPlug = setInterval(() => {
      if (window.Payplug) {
        clearInterval(checkPayPlug);
        resolve(getPayPlugInstance());
      }
    }, 100);
    
    // Timeout after 10 seconds
    setTimeout(() => {
      clearInterval(checkPayPlug);
      resolve(null);
    }, 10000);
  } else {
    resolve(null);
  }
});

export default payplugPromise;