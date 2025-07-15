/**
 * PayPlug Configuration - Remplace Stripe
 * Configuration pour le système de paiement PayPlug
 */

// Configuration PayPlug
export const PAYPLUG_CONFIG = {
  publicKey: import.meta.env.VITE_PAYPLUG_PUBLIC_KEY || '',
  environment: import.meta.env.NODE_ENV === 'production' ? 'live' : 'test',
  currency: 'EUR',
  locale: 'fr'
};

// Types PayPlug
export interface PayPlugPayment {
  id: string;
  amount: number;
  currency: string;
  status: 'pending' | 'completed' | 'failed';
  metadata?: Record<string, any>;
}

export interface PayPlugError {
  message: string;
  type: string;
  code?: string;
}

// Simulation PayPlug (pour développement)
export class PayPlugSimulation {
  private static instance: PayPlugSimulation;
  
  private constructor() {}
  
  static getInstance(): PayPlugSimulation {
    if (!PayPlugSimulation.instance) {
      PayPlugSimulation.instance = new PayPlugSimulation();
    }
    return PayPlugSimulation.instance;
  }
  
  async createPayment(amount: number, metadata?: Record<string, any>): Promise<PayPlugPayment> {
    // Simulation d'un délai réseau
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    return {
      id: `pay_${Date.now()}`,
      amount,
      currency: 'EUR',
      status: 'pending',
      metadata
    };
  }
  
  async processPayment(paymentId: string): Promise<PayPlugPayment> {
    // Simulation du traitement du paiement
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    return {
      id: paymentId,
      amount: 0,
      currency: 'EUR',
      status: 'completed'
    };
  }
  
  async refundPayment(paymentId: string): Promise<PayPlugPayment> {
    // Simulation du remboursement
    await new Promise(resolve => setTimeout(resolve, 1500));
    
    return {
      id: paymentId,
      amount: 0,
      currency: 'EUR',
      status: 'completed'
    };
  }
}

// Configuration par défaut
export const payplug = PayPlugSimulation.getInstance();

// Fonction d'initialisation
export function initPayPlug() {
  if (!PAYPLUG_CONFIG.publicKey) {
    console.warn('PayPlug: Clé publique non configurée. Utilisation du mode simulation.');
    return false;
  }
  
  console.log('PayPlug: Initialisé avec succès');
  return true;
}

// Export par défaut
export default payplug;