/**
 * PayPlug Server Service
 * Official PayPlug REST API integration for server-side operations
 */

import { Request, Response } from 'express';

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

export interface PayPlugWebhookEvent {
  id: string;
  object: string;
  type: string;
  created_at: string;
  data: {
    object: PayPlugPayment;
  };
}

export class PayPlugService {
  private readonly baseUrl = 'https://api.payplug.com/v1';
  private readonly secretKey: string;

  constructor() {
    this.secretKey = process.env.PAYPLUG_SECRET_KEY || '';
    
    if (!this.secretKey) {
      console.error('PayPlug secret key not configured');
      throw new Error('PayPlug secret key is required');
    }
  }

  /**
   * Get authorization headers for PayPlug API
   */
  private getAuthHeaders(): Record<string, string> {
    return {
      'Authorization': `Bearer ${this.secretKey}`,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /**
   * Create a payment using PayPlug API
   */
  async createPayment(paymentData: PayPlugPaymentRequest): Promise<PayPlugPayment> {
    try {
      const response = await fetch(`${this.baseUrl}/payments`, {
        method: 'POST',
        headers: this.getAuthHeaders(),
        body: JSON.stringify(paymentData),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(`PayPlug API error: ${errorData.message || 'Payment creation failed'}`);
      }

      const payment = await response.json();
      return payment as PayPlugPayment;
    } catch (error) {
      console.error('Error creating PayPlug payment:', error);
      throw error;
    }
  }

  /**
   * Retrieve a payment by ID
   */
  async getPayment(paymentId: string): Promise<PayPlugPayment> {
    try {
      const response = await fetch(`${this.baseUrl}/payments/${paymentId}`, {
        method: 'GET',
        headers: this.getAuthHeaders(),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(`PayPlug API error: ${errorData.message || 'Payment retrieval failed'}`);
      }

      const payment = await response.json();
      return payment as PayPlugPayment;
    } catch (error) {
      console.error('Error retrieving PayPlug payment:', error);
      throw error;
    }
  }

  /**
   * List payments with pagination
   */
  async listPayments(options: {
    per_page?: number;
    page?: number;
    sort?: 'created_at' | '-created_at';
    is_paid?: boolean;
  } = {}): Promise<{ has_more: boolean; data: PayPlugPayment[] }> {
    try {
      const params = new URLSearchParams();
      
      if (options.per_page) params.append('per_page', options.per_page.toString());
      if (options.page) params.append('page', options.page.toString());
      if (options.sort) params.append('sort', options.sort);
      if (options.is_paid !== undefined) params.append('is_paid', options.is_paid.toString());

      const response = await fetch(`${this.baseUrl}/payments?${params}`, {
        method: 'GET',
        headers: this.getAuthHeaders(),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(`PayPlug API error: ${errorData.message || 'Payment listing failed'}`);
      }

      const result = await response.json();
      return result;
    } catch (error) {
      console.error('Error listing PayPlug payments:', error);
      throw error;
    }
  }

  /**
   * Create a refund for a payment
   */
  async createRefund(paymentId: string, amount?: number, metadata?: Record<string, any>): Promise<any> {
    try {
      const refundData: any = {};
      
      if (amount) refundData.amount = amount;
      if (metadata) refundData.metadata = metadata;

      const response = await fetch(`${this.baseUrl}/payments/${paymentId}/refunds`, {
        method: 'POST',
        headers: this.getAuthHeaders(),
        body: JSON.stringify(refundData),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(`PayPlug API error: ${errorData.message || 'Refund creation failed'}`);
      }

      const refund = await response.json();
      return refund;
    } catch (error) {
      console.error('Error creating PayPlug refund:', error);
      throw error;
    }
  }

  /**
   * Verify webhook signature
   */
  verifyWebhookSignature(payload: string, signature: string): boolean {
    try {
      // PayPlug webhook signature verification logic
      // This should be implemented according to PayPlug's webhook documentation
      const webhookSecret = process.env.PAYPLUG_WEBHOOK_SECRET || '';
      
      if (!webhookSecret) {
        console.warn('PayPlug webhook secret not configured');
        return false;
      }

      // For now, we'll return true if both signature and secret exist
      // In production, implement proper HMAC verification
      return !!(signature && webhookSecret);
    } catch (error) {
      console.error('Error verifying PayPlug webhook signature:', error);
      return false;
    }
  }

  /**
   * Handle webhook events
   */
  async handleWebhook(req: Request, res: Response): Promise<void> {
    try {
      const signature = req.headers['payplug-signature'] as string;
      const payload = JSON.stringify(req.body);

      if (!this.verifyWebhookSignature(payload, signature)) {
        console.error('Invalid PayPlug webhook signature');
        res.status(400).json({ error: 'Invalid signature' });
        return;
      }

      const event: PayPlugWebhookEvent = req.body;
      
      console.log(`Processing PayPlug webhook event: ${event.type}`);

      switch (event.type) {
        case 'payment.succeeded':
          await this.handlePaymentSucceeded(event.data.object);
          break;
          
        case 'payment.failed':
          await this.handlePaymentFailed(event.data.object);
          break;
          
        case 'payment.refunded':
          await this.handlePaymentRefunded(event.data.object);
          break;
          
        default:
          console.log(`Unhandled PayPlug webhook event type: ${event.type}`);
      }

      res.status(200).json({ received: true });
    } catch (error) {
      console.error('Error handling PayPlug webhook:', error);
      res.status(500).json({ error: 'Webhook processing failed' });
    }
  }

  /**
   * Handle successful payment
   */
  private async handlePaymentSucceeded(payment: PayPlugPayment): Promise<void> {
    try {
      console.log(`Payment succeeded: ${payment.id}`);
      
      // Update order status in database
      if (payment.metadata?.order_id) {
        // Here you would update your database with the successful payment
        console.log(`Updating order ${payment.metadata.order_id} to paid status`);
      }
    } catch (error) {
      console.error('Error handling payment succeeded:', error);
    }
  }

  /**
   * Handle failed payment
   */
  private async handlePaymentFailed(payment: PayPlugPayment): Promise<void> {
    try {
      console.log(`Payment failed: ${payment.id}`);
      
      // Update order status in database
      if (payment.metadata?.order_id) {
        // Here you would update your database with the failed payment
        console.log(`Updating order ${payment.metadata.order_id} to failed status`);
      }
    } catch (error) {
      console.error('Error handling payment failed:', error);
    }
  }

  /**
   * Handle refunded payment
   */
  private async handlePaymentRefunded(payment: PayPlugPayment): Promise<void> {
    try {
      console.log(`Payment refunded: ${payment.id}`);
      
      // Update order status in database
      if (payment.metadata?.order_id) {
        // Here you would update your database with the refunded payment
        console.log(`Updating order ${payment.metadata.order_id} to refunded status`);
      }
    } catch (error) {
      console.error('Error handling payment refunded:', error);
    }
  }

  /**
   * Format amount for PayPlug (amount in cents)
   */
  formatAmount(amount: number): number {
    return Math.round(amount * 100);
  }

  /**
   * Format amount from PayPlug (amount from cents)
   */
  formatAmountFromCents(amount: number): number {
    return amount / 100;
  }

  /**
   * Validate PayPlug configuration
   */
  isConfigured(): boolean {
    return !!this.secretKey;
  }
}

// Export singleton instance
export const payplugService = new PayPlugService();
export default payplugService;