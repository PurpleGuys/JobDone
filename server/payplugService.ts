import fetch from 'node-fetch';
import { ENV } from '../ensure-env-loaded';

export class PayPlugService {
  private static readonly API_KEY = ENV.PAYPLUG_SECRET_KEY || 'sk_test_2wDsePkdatiFXUsRfeu6m1';
  private static readonly API_URL = 'https://api.payplug.com/v1';

  /**
   * Create a PayPlug payment
   */
  static async createPayment(data: {
    amount: number; // in cents
    currency: string;
    customer: {
      email: string;
      first_name: string;
      last_name: string;
    };
    metadata?: Record<string, any>;
    hosted_payment?: {
      return_url: string;
      cancel_url: string;
    };
  }) {
    try {
      const response = await fetch(`${this.API_URL}/payments`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.API_KEY}`,
          'Content-Type': 'application/json',
          'PayPlug-Version': '2019-08-06'
        },
        body: JSON.stringify(data)
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || 'PayPlug payment creation failed');
      }

      const payment = await response.json();
      return payment;
    } catch (error: any) {
      console.error('PayPlug payment creation error:', error);
      throw error;
    }
  }

  /**
   * Retrieve a PayPlug payment
   */
  static async retrievePayment(paymentId: string) {
    try {
      const response = await fetch(`${this.API_URL}/payments/${paymentId}`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${this.API_KEY}`,
          'PayPlug-Version': '2019-08-06'
        }
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || 'PayPlug payment retrieval failed');
      }

      const payment = await response.json();
      return payment;
    } catch (error: any) {
      console.error('PayPlug payment retrieval error:', error);
      throw error;
    }
  }

  /**
   * Check if PayPlug is configured
   */
  static isConfigured(): boolean {
    return !!this.API_KEY;
  }

  /**
   * Check if using test mode
   */
  static isTestMode(): boolean {
    return this.API_KEY.startsWith('sk_test_');
  }
}

export const payPlugService = new PayPlugService();