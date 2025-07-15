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
  
  // Load PayPlug script
  const script = document.createElement('script');
  script.src = 'https://cdn.payplug.com/js/integrated-payment/v1@1/index.js';
  script.async = true;
  document.head.appendChild(script);
}

if (PAYPLUG_SECRET_KEY) {
  console.log('✅ PayPlug configuration loaded with test key');
  console.log('✅ PAYPLUG CONFIGURÉ AVEC CLÉ:', PAYPLUG_SECRET_KEY.substring(0, 15) + '...');
} else {
  console.warn('⚠️ PayPlug secret key not configured');
}

export { PAYPLUG_SECRET_KEY, PAYPLUG_MODE };