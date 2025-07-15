// REDIRECTION STRIPE VERS PAYPLUG
// Ce fichier remplace complètement Stripe par PayPlug

import { payplugPromise } from './payplug';

// Mock de loadStripe pour éviter les erreurs
export const loadStripe = () => {
  console.log('📦 Stripe remplacé par PayPlug');
  return payplugPromise;
};

// Export de stripePromise qui utilise en fait PayPlug
export const stripePromise = payplugPromise;

// Fournir une clé mock pour éviter l'erreur VITE_STRIPE_PUBLIC_KEY
window.VITE_STRIPE_PUBLIC_KEY = 'payplug_mode';
if (window.process && window.process.env) {
  window.process.env.VITE_STRIPE_PUBLIC_KEY = 'payplug_mode';
}
if (import.meta && import.meta.env) {
  import.meta.env.VITE_STRIPE_PUBLIC_KEY = 'payplug_mode';
}

console.log('✅ Migration Stripe → PayPlug complète');