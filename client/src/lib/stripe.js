// FICHIER STRIPE.JS VIDE - REMPLACÉ PAR PAYPLUG
console.warn('Stripe désactivé - PayPlug utilisé à la place');

// Export vide pour éviter les erreurs d'import
export const stripe = null;
export const loadStripe = () => Promise.resolve(null);
export const Stripe = null;
export const Elements = null;
export const CardElement = null;
export const useStripe = () => null;
export const useElements = () => null;

// Export par défaut
export default null;