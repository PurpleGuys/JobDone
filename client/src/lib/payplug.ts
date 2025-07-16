/**
 * PayPlug API Integration
 * Official PayPlug REST API implementation
 */

export interface PayPlugPayment {
  id: string;
  object: string;
  amount: number;
  currency: string;
  created_at: string;
  is_live: boolean;
  is_paid: boolean;
  payment_url: string;
  return_url: string;
  cancel_url: string;
  failure: any;
  authorization: any;
  refunds: any[];
  billing: {
    email: string;
    first_name: string;
    last_name: string;
    address1?: string;
    address2?: string;
    city?: string;
    postcode?: string;
    country?: string;
    language?: string;
  };
  shipping?: {
    first_name: string;
    last_name: string;
    address1?: string;
    address2?: string;
    city?: string;
    postcode?: string;
    country?: string;
  };
  metadata?: { [key: string]: any };
}

export interface PayPlugPaymentRequest {
  amount: number;
  currency: string;
  billing: {
    email: string;
    first_name: string;
    last_name: string;
    address1?: string;
    address2?: string;
    city?: string;
    postcode?: string;
    country?: string;
    language?: string;
  };
  shipping?: {
    first_name: string;
    last_name: string;
    address1?: string;
    address2?: string;
    city?: string;
    postcode?: string;
    country?: string;
  };
  hosted_payment: {
    return_url: string;
    cancel_url: string;
  };
  notification_url?: string;
  metadata?: { [key: string]: any };
}

export interface PayPlugError {
  error: string;
  message: string;
  details?: any;
}

class PayPlugAPI {
  private readonly baseUrl = 'https://api.payplug.com/v1';
  private readonly publicKey: string;
  
  constructor() {
    this.publicKey = import.meta.env.VITE_PAYPLUG_PUBLIC_KEY;
    
    if (!this.publicKey) {
      console.error('PayPlug public key not configured');
      throw new Error('PayPlug public key is required');
    }
  }

  /**
   * Create a payment using PayPlug REST API
   */
  async createPayment(paymentData: PayPlugPaymentRequest): Promise<PayPlugPayment> {
    try {
      const response = await fetch('/api/payments/create', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(paymentData),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || 'Payment creation failed');
      }

      const payment = await response.json();
      return payment as PayPlugPayment;
    } catch (error) {
      console.error('Error creating PayPlug payment:', error);
      throw error;
    }
  }

  /**
   * Retrieve payment details
   */
  async getPayment(paymentId: string): Promise<PayPlugPayment> {
    try {
      const response = await fetch(`/api/payments/${paymentId}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || 'Payment retrieval failed');
      }

      const payment = await response.json();
      return payment as PayPlugPayment;
    } catch (error) {
      console.error('Error retrieving PayPlug payment:', error);
      throw error;
    }
  }

  /**
   * Verify payment status
   */
  async verifyPayment(paymentId: string): Promise<boolean> {
    try {
      const payment = await this.getPayment(paymentId);
      return payment.is_paid;
    } catch (error) {
      console.error('Error verifying PayPlug payment:', error);
      return false;
    }
  }

  /**
   * Format amount for PayPlug (amount in cents)
   */
  formatAmount(amount: number): number {
    return Math.round(amount * 100);
  }

  /**
   * Get return URL for successful payment
   */
  getReturnUrl(orderId: string): string {
    const baseUrl = window.location.origin;
    return `${baseUrl}/payment/success?order_id=${orderId}`;
  }

  /**
   * Get cancel URL for cancelled payment
   */
  getCancelUrl(orderId: string): string {
    const baseUrl = window.location.origin;
    return `${baseUrl}/payment/cancel?order_id=${orderId}`;
  }

  /**
   * Get notification URL for webhooks
   */
  getNotificationUrl(): string {
    const baseUrl = window.location.origin;
    return `${baseUrl}/api/webhooks/payplug`;
  }

  /**
   * Validate PayPlug configuration
   */
  isConfigured(): boolean {
    return !!this.publicKey;
  }

  /**
   * Format billing address for PayPlug
   */
  formatBillingAddress(address: any): PayPlugPaymentRequest['billing'] {
    return {
      email: address.email || '',
      first_name: address.firstName || '',
      last_name: address.lastName || '',
      address1: address.address || '',
      city: address.city || '',
      postcode: address.postalCode || '',
      country: address.country || 'FR',
      language: address.language || 'fr',
    };
  }

  /**
   * Format shipping address for PayPlug
   */
  formatShippingAddress(address: any): PayPlugPaymentRequest['shipping'] {
    return {
      first_name: address.firstName || '',
      last_name: address.lastName || '',
      address1: address.address || '',
      city: address.city || '',
      postcode: address.postalCode || '',
      country: address.country || 'FR',
    };
  }
}

// Create singleton instance
export const payplug = new PayPlugAPI();
export default payplug;