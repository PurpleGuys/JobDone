import React, { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { useToast } from '@/hooks/use-toast';
import { CreditCard, Lock, Euro, AlertCircle } from 'lucide-react';
import { payplug } from '@/lib/payplug';
import type { PayPlugPaymentRequest } from '@/lib/payplug';

interface PaymentStepProps {
  orderData: {
    id: string;
    amount: number;
    currency: string;
    customer: {
      email: string;
      firstName: string;
      lastName: string;
      address: string;
      city: string;
      postalCode: string;
      country: string;
      phone: string;
    };
    services: Array<{
      id: number;
      name: string;
      quantity: number;
      unitPrice: number;
    }>;
    deliveryAddress: string;
    pickupAddress: string;
    deliveryDate: string;
    pickupDate: string;
  };
  onPaymentSuccess: (paymentId: string) => void;
  onPaymentError: (error: string) => void;
}

export default function PaymentStep({ orderData, onPaymentSuccess, onPaymentError }: PaymentStepProps) {
  const [isProcessing, setIsProcessing] = useState(false);
  const [paymentError, setPaymentError] = useState<string | null>(null);
  const { toast } = useToast();

  const handlePayment = async () => {
    if (!payplug.isConfigured()) {
      setPaymentError('PayPlug n\'est pas configuré. Veuillez contacter l\'administrateur.');
      return;
    }

    setIsProcessing(true);
    setPaymentError(null);

    try {
      // Prepare payment data for PayPlug
      const paymentData: PayPlugPaymentRequest = {
        amount: payplug.formatAmount(orderData.amount),
        currency: orderData.currency.toUpperCase(),
        billing: payplug.formatBillingAddress({
          email: orderData.customer.email,
          firstName: orderData.customer.firstName,
          lastName: orderData.customer.lastName,
          address: orderData.customer.address,
          city: orderData.customer.city,
          postalCode: orderData.customer.postalCode,
          country: orderData.customer.country,
          language: 'fr',
        }),
        shipping: payplug.formatShippingAddress({
          firstName: orderData.customer.firstName,
          lastName: orderData.customer.lastName,
          address: orderData.deliveryAddress,
          city: orderData.customer.city,
          postalCode: orderData.customer.postalCode,
          country: orderData.customer.country,
        }),
        hosted_payment: {
          return_url: payplug.getReturnUrl(orderData.id),
          cancel_url: payplug.getCancelUrl(orderData.id),
        },
        notification_url: payplug.getNotificationUrl(),
        metadata: {
          order_id: orderData.id,
          customer_email: orderData.customer.email,
          customer_phone: orderData.customer.phone,
          delivery_date: orderData.deliveryDate,
          pickup_date: orderData.pickupDate,
        },
      };

      // Create payment with PayPlug
      const payment = await payplug.createPayment(paymentData);

      // Redirect to PayPlug hosted payment page
      if (payment.payment_url) {
        window.location.href = payment.payment_url;
      } else {
        throw new Error('URL de paiement non reçue de PayPlug');
      }

    } catch (error) {
      console.error('Erreur lors du paiement:', error);
      const errorMessage = error instanceof Error ? error.message : 'Erreur lors du paiement';
      setPaymentError(errorMessage);
      onPaymentError(errorMessage);
      
      toast({
        title: "Erreur de paiement",
        description: errorMessage,
        variant: "destructive",
      });
    } finally {
      setIsProcessing(false);
    }
  };

  const formatPrice = (amount: number) => {
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency: orderData.currency,
    }).format(amount);
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      {/* Order Summary */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Euro className="w-5 h-5" />
            Récapitulatif de la commande
          </CardTitle>
          <CardDescription>
            Vérifiez les détails de votre commande avant de procéder au paiement
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <h4 className="font-semibold">Services commandés:</h4>
            {orderData.services.map((service, index) => (
              <div key={index} className="flex justify-between items-center p-2 bg-gray-50 rounded">
                <span>{service.name} x{service.quantity}</span>
                <span className="font-medium">{formatPrice(service.unitPrice * service.quantity)}</span>
              </div>
            ))}
          </div>

          <div className="border-t pt-4">
            <div className="flex justify-between items-center text-lg font-semibold">
              <span>Total à payer:</span>
              <span className="text-primary">{formatPrice(orderData.amount)}</span>
            </div>
          </div>

          <div className="space-y-2 text-sm text-gray-600">
            <div><strong>Livraison:</strong> {orderData.deliveryAddress}</div>
            <div><strong>Date de livraison:</strong> {new Date(orderData.deliveryDate).toLocaleDateString('fr-FR')}</div>
            <div><strong>Date de collecte:</strong> {new Date(orderData.pickupDate).toLocaleDateString('fr-FR')}</div>
          </div>
        </CardContent>
      </Card>

      {/* Payment Method */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <CreditCard className="w-5 h-5" />
            Méthode de paiement
          </CardTitle>
          <CardDescription>
            Paiement sécurisé avec PayPlug
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center gap-4 p-4 bg-blue-50 rounded-lg">
            <Lock className="w-6 h-6 text-blue-600" />
            <div>
              <p className="font-semibold text-blue-900">Paiement 100% sécurisé</p>
              <p className="text-sm text-blue-700">
                Vos données sont chiffrées et protégées par PayPlug
              </p>
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="customer-email">Email de facturation</Label>
            <Input
              id="customer-email"
              type="email"
              value={orderData.customer.email}
              disabled
              className="bg-gray-50"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="customer-firstname">Prénom</Label>
              <Input
                id="customer-firstname"
                value={orderData.customer.firstName}
                disabled
                className="bg-gray-50"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="customer-lastname">Nom</Label>
              <Input
                id="customer-lastname"
                value={orderData.customer.lastName}
                disabled
                className="bg-gray-50"
              />
            </div>
          </div>

          {paymentError && (
            <div className="flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded-lg">
              <AlertCircle className="w-5 h-5 text-red-600" />
              <p className="text-sm text-red-800">{paymentError}</p>
            </div>
          )}

          <Button
            onClick={handlePayment}
            disabled={isProcessing || !payplug.isConfigured()}
            className="w-full"
            size="lg"
          >
            {isProcessing ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2" />
                Redirection vers PayPlug...
              </>
            ) : (
              <>
                <Lock className="w-4 h-4 mr-2" />
                Payer {formatPrice(orderData.amount)} avec PayPlug
              </>
            )}
          </Button>

          <div className="text-xs text-gray-500 text-center">
            En cliquant sur "Payer", vous serez redirigé vers la page de paiement sécurisée PayPlug.
            Vous pourrez payer par carte bancaire ou autres moyens de paiement disponibles.
          </div>
        </CardContent>
      </Card>

      {/* Payment Security Info */}
      <Card>
        <CardContent className="pt-6">
          <div className="text-center space-y-2">
            <h4 className="font-semibold">Pourquoi PayPlug ?</h4>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
              <div className="flex flex-col items-center">
                <Lock className="w-8 h-8 text-green-600 mb-2" />
                <p className="font-medium">Sécurité maximale</p>
                <p className="text-gray-600">Chiffrement SSL 256-bit</p>
              </div>
              <div className="flex flex-col items-center">
                <CreditCard className="w-8 h-8 text-blue-600 mb-2" />
                <p className="font-medium">Tous moyens de paiement</p>
                <p className="text-gray-600">Visa, MasterCard, AMEX</p>
              </div>
              <div className="flex flex-col items-center">
                <Euro className="w-8 h-8 text-purple-600 mb-2" />
                <p className="font-medium">Conformité européenne</p>
                <p className="text-gray-600">PCI DSS Level 1</p>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}