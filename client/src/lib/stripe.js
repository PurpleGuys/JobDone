// STRIPE DÉSACTIVÉ - PAYPLUG ONLY
console.warn('Stripe désactivé - PayPlug utilisé');

// Exports vides pour éviter les erreurs
export const stripe = null;
export const loadStripe = () => null;
export const Stripe = null;
export const Elements = null;
export const CardElement = null;
export const useStripe = () => null;
export const useElements = () => null;

// Bloquer window.stripe
if (typeof window !== 'undefined') {
    window.stripe = null;
    window.Stripe = null;
}

export default null;
