import { loadStripe } from '@stripe/stripe-js';
import { STRIPE_PUBLIC_KEY } from './stripe-config';

// Initialize Stripe with public key
export const stripePromise = loadStripe(STRIPE_PUBLIC_KEY, {
  locale: 'fr'
});

// Export stripePromise as default for backward compatibility
export default stripePromise;