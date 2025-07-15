// Stripe configuration for BennesPro
// This file loads and configures Stripe with environment variables

const STRIPE_PUBLIC_KEY = import.meta.env.VITE_STRIPE_PUBLIC_KEY || '';

// Configure Stripe for window object (for compatibility)
if (typeof window !== 'undefined') {
  window.VITE_STRIPE_PUBLIC_KEY = STRIPE_PUBLIC_KEY;
  window.process = window.process || {};
  window.process.env = window.process.env || {};
  window.process.env.VITE_STRIPE_PUBLIC_KEY = STRIPE_PUBLIC_KEY;
}

if (STRIPE_PUBLIC_KEY) {
  console.log('✅ Stripe configuration loaded with production key');
  console.log('✅ STRIPE CONFIGURÉ AVEC CLÉ PRODUCTION:', STRIPE_PUBLIC_KEY.substring(0, 15) + '...');
} else {
  console.warn('⚠️ Stripe public key not configured');
}

export { STRIPE_PUBLIC_KEY };