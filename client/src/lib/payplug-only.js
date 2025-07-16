// PAYPLUG ONLY - NO STRIPE
export const payplugClient = {
  isConfigured: () => {
    return !!import.meta.env.VITE_PAYPLUG_PUBLIC_KEY;
  },
  
  createPayment: async (paymentData) => {
    const response = await fetch('/api/payments/create', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(paymentData),
    });
    
    if (!response.ok) {
      throw new Error('Erreur lors de la création du paiement');
    }
    
    return response.json();
  },
  
  getReturnUrl: (orderId) => {
    return `${window.location.origin}/payment/success?order=${orderId}`;
  },
  
  getCancelUrl: (orderId) => {
    return `${window.location.origin}/payment/cancel?order=${orderId}`;
  },
};

// Block all Stripe references
if (typeof window !== 'undefined') {
  window.Stripe = null;
  window.stripe = null;
  Object.defineProperty(window, 'Stripe', {
    get: () => {
      console.warn('Stripe is disabled. Use PayPlug instead.');
      return null;
    },
    set: () => {
      console.warn('Cannot set Stripe. PayPlug only.');
    }
  });
}