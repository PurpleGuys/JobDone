import React, { useEffect, useState } from 'react';
import { useLocation, useRouter } from 'wouter';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { CheckCircle, Download, Mail, Calendar, MapPin } from 'lucide-react';
import { payplug } from '@/lib/payplug';

export default function PaymentSuccess() {
  const [location] = useLocation();
  const [, navigate] = useRouter();
  const [paymentData, setPaymentData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const urlParams = new URLSearchParams(location.split('?')[1]);
    const orderId = urlParams.get('order_id');
    const paymentId = urlParams.get('payment_id');

    if (!orderId) {
      setError('ID de commande manquant');
      setIsLoading(false);
      return;
    }

    const verifyPayment = async () => {
      try {
        if (paymentId) {
          const payment = await payplug.getPayment(paymentId);
          
          if (payment.is_paid) {
            setPaymentData({
              orderId,
              paymentId,
              amount: payplug.formatAmountFromCents ? payplug.formatAmountFromCents(payment.amount) : payment.amount / 100,
              currency: payment.currency,
              customerEmail: payment.billing.email,
              customerName: `${payment.billing.first_name} ${payment.billing.last_name}`,
              paidAt: payment.created_at,
            });
          } else {
            setError('Le paiement n\'a pas été confirmé');
          }
        } else {
          // Fallback without payment ID
          setPaymentData({
            orderId,
            paymentId: 'unknown',
            amount: 0,
            currency: 'EUR',
            customerEmail: 'unknown',
            customerName: 'Client',
            paidAt: new Date().toISOString(),
          });
        }
      } catch (err) {
        console.error('Erreur lors de la vérification du paiement:', err);
        setError('Erreur lors de la vérification du paiement');
      } finally {
        setIsLoading(false);
      }
    };

    verifyPayment();
  }, [location]);

  const formatPrice = (amount: number, currency: string) => {
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency: currency,
    }).format(amount);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('fr-FR', {
      day: 'numeric',
      month: 'long',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-gray-600">Vérification du paiement...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="max-w-md w-full mx-4">
          <Card className="border-red-200">
            <CardHeader>
              <CardTitle className="text-red-600">Erreur</CardTitle>
              <CardDescription>{error}</CardDescription>
            </CardHeader>
            <CardContent>
              <Button onClick={() => navigate('/')} className="w-full">
                Retour à l'accueil
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-3xl mx-auto px-4">
        {/* Success Header */}
        <div className="text-center mb-8">
          <div className="flex justify-center mb-4">
            <CheckCircle className="w-16 h-16 text-green-500" />
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            Paiement réussi !
          </h1>
          <p className="text-gray-600">
            Votre commande a été confirmée et le paiement a été traité avec succès.
          </p>
        </div>

        {/* Payment Details */}
        <Card className="mb-6">
          <CardHeader>
            <CardTitle>Détails du paiement</CardTitle>
            <CardDescription>
              Récapitulatif de votre transaction PayPlug
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <p className="text-sm text-gray-600">Numéro de commande</p>
                <p className="font-semibold">{paymentData?.orderId}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600">ID de transaction</p>
                <p className="font-semibold">{paymentData?.paymentId}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Montant payé</p>
                <p className="font-semibold text-green-600">
                  {formatPrice(paymentData?.amount || 0, paymentData?.currency || 'EUR')}
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Date et heure</p>
                <p className="font-semibold">{formatDate(paymentData?.paidAt || '')}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Order Information */}
        <Card className="mb-6">
          <CardHeader>
            <CardTitle>Informations sur la commande</CardTitle>
            <CardDescription>
              Détails de votre réservation de benne
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center gap-3 p-3 bg-blue-50 rounded-lg">
              <Mail className="w-5 h-5 text-blue-600" />
              <div>
                <p className="font-medium">Confirmation par email</p>
                <p className="text-sm text-gray-600">
                  Un email de confirmation a été envoyé à {paymentData?.customerEmail}
                </p>
              </div>
            </div>
            
            <div className="flex items-center gap-3 p-3 bg-green-50 rounded-lg">
              <Calendar className="w-5 h-5 text-green-600" />
              <div>
                <p className="font-medium">Prochaines étapes</p>
                <p className="text-sm text-gray-600">
                  Notre équipe vous contactera dans les 24h pour organiser la livraison
                </p>
              </div>
            </div>
            
            <div className="flex items-center gap-3 p-3 bg-purple-50 rounded-lg">
              <MapPin className="w-5 h-5 text-purple-600" />
              <div>
                <p className="font-medium">Suivi de commande</p>
                <p className="text-sm text-gray-600">
                  Vous pouvez suivre l'état de votre commande dans votre espace client
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Actions */}
        <Card>
          <CardContent className="pt-6">
            <div className="flex flex-col sm:flex-row gap-4">
              <Button 
                onClick={() => navigate('/dashboard')}
                className="flex-1"
              >
                Aller au tableau de bord
              </Button>
              <Button 
                variant="outline" 
                onClick={() => navigate('/orders')}
                className="flex-1"
              >
                Voir mes commandes
              </Button>
              <Button 
                variant="outline" 
                onClick={() => window.print()}
                className="flex-1"
              >
                <Download className="w-4 h-4 mr-2" />
                Imprimer le reçu
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Support Information */}
        <div className="mt-8 text-center text-sm text-gray-600">
          <p>
            Besoin d'aide ? Contactez notre service client au{' '}
            <a href="tel:+33123456789" className="text-primary hover:underline">
              01 23 45 67 89
            </a>
            {' '}ou par email à{' '}
            <a href="mailto:support@remondis.fr" className="text-primary hover:underline">
              support@remondis.fr
            </a>
          </p>
        </div>
      </div>
    </div>
  );
}