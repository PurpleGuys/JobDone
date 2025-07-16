// STRIPE COMPLÈTEMENT DÉSACTIVÉ - PAYPLUG ONLY
console.warn('Stripe désactivé - Utilisation exclusive de PayPlug');

// Mock Stripe pour éviter les erreurs
const mockStripe = {
  confirmCardPayment: () => Promise.reject(new Error('Stripe désactivé - Utilisez PayPlug')),
  createPaymentMethod: () => Promise.reject(new Error('Stripe désactivé - Utilisez PayPlug')),
  handleCardAction: () => Promise.reject(new Error('Stripe désactivé - Utilisez PayPlug')),
  elements: () => ({
    create: () => ({
      mount: () => {},
      unmount: () => {},
      destroy: () => {},
      on: () => {},
      off: () => {},
    }),
  }),
};

// Exports pour compatibilité totale
export const stripePromise = Promise.resolve(mockStripe);
export const stripe = mockStripe;
export const loadStripe = () => Promise.resolve(mockStripe);
export const Stripe = null;
export const Elements = ({ children }) => children;
export const CardElement = () => null;
export const useStripe = () => mockStripe;
export const useElements = () => ({ getElement: () => null });

// Bloquer au niveau global
if (typeof window !== 'undefined') {
    window.stripe = mockStripe;
    window.Stripe = null;
    window.stripePromise = stripePromise;
}

export default mockStripe;
