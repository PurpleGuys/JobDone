import React, { useEffect } from 'react';
import { useLocation, useRouter } from 'wouter';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { XCircle, RefreshCw, Home, CreditCard } from 'lucide-react';

export default function PaymentCancel() {
  const [location] = useLocation();
  const [, navigate] = useRouter();

  useEffect(() => {
    // Log the cancellation for analytics
    console.log('Payment cancelled:', location);
  }, [location]);

  const urlParams = new URLSearchParams(location.split('?')[1]);
  const orderId = urlParams.get('order_id');

  const handleRetryPayment = () => {
    if (orderId) {
      navigate(`/checkout?order_id=${orderId}`);
    } else {
      navigate('/booking');
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-2xl mx-auto px-4">
        {/* Cancel Header */}
        <div className="text-center mb-8">
          <div className="flex justify-center mb-4">
            <XCircle className="w-16 h-16 text-orange-500" />
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            Paiement annulé
          </h1>
          <p className="text-gray-600">
            Votre paiement a été annulé. Aucun montant n'a été débité.
          </p>
        </div>

        {/* Information Card */}
        <Card className="mb-6">
          <CardHeader>
            <CardTitle>Que s'est-il passé ?</CardTitle>
            <CardDescription>
              Votre paiement a été interrompu pour l'une des raisons suivantes :
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-3">
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 bg-orange-500 rounded-full mt-2"></div>
                <div>
                  <p className="font-medium">Annulation volontaire</p>
                  <p className="text-sm text-gray-600">
                    Vous avez cliqué sur "Annuler" ou fermé la fenêtre de paiement
                  </p>
                </div>
              </div>
              
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 bg-orange-500 rounded-full mt-2"></div>
                <div>
                  <p className="font-medium">Problème technique</p>
                  <p className="text-sm text-gray-600">
                    Une erreur technique a interrompu le processus de paiement
                  </p>
                </div>
              </div>
              
              <div className="flex items-start gap-3">
                <div className="w-2 h-2 bg-orange-500 rounded-full mt-2"></div>
                <div>
                  <p className="font-medium">Session expirée</p>
                  <p className="text-sm text-gray-600">
                    Le délai de paiement a été dépassé
                  </p>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Order Information */}
        {orderId && (
          <Card className="mb-6">
            <CardHeader>
              <CardTitle>Votre commande</CardTitle>
              <CardDescription>
                Votre réservation est toujours en attente
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-3 p-3 bg-blue-50 rounded-lg">
                <CreditCard className="w-5 h-5 text-blue-600" />
                <div>
                  <p className="font-medium">Commande #{orderId}</p>
                  <p className="text-sm text-gray-600">
                    Votre réservation est conservée pendant 30 minutes
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Actions */}
        <Card className="mb-6">
          <CardContent className="pt-6">
            <div className="space-y-4">
              <h3 className="font-semibold text-center">Que souhaitez-vous faire ?</h3>
              
              <div className="flex flex-col sm:flex-row gap-4">
                <Button 
                  onClick={handleRetryPayment}
                  className="flex-1"
                  size="lg"
                >
                  <RefreshCw className="w-4 h-4 mr-2" />
                  Réessayer le paiement
                </Button>
                
                <Button 
                  variant="outline" 
                  onClick={() => navigate('/')}
                  className="flex-1"
                  size="lg"
                >
                  <Home className="w-4 h-4 mr-2" />
                  Retour à l'accueil
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Help Information */}
        <Card>
          <CardHeader>
            <CardTitle>Besoin d'aide ?</CardTitle>
            <CardDescription>
              Notre équipe est là pour vous accompagner
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 bg-primary/10 rounded-full flex items-center justify-center">
                  <span className="text-primary font-semibold">📞</span>
                </div>
                <div>
                  <p className="font-medium">Service client</p>
                  <p className="text-sm text-gray-600">01 23 45 67 89</p>
                  <p className="text-xs text-gray-500">Lun-Ven 9h-18h</p>
                </div>
              </div>
              
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 bg-primary/10 rounded-full flex items-center justify-center">
                  <span className="text-primary font-semibold">✉️</span>
                </div>
                <div>
                  <p className="font-medium">Email</p>
                  <p className="text-sm text-gray-600">support@remondis.fr</p>
                  <p className="text-xs text-gray-500">Réponse sous 24h</p>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Security Note */}
        <div className="mt-8 text-center text-sm text-gray-600">
          <p className="mb-2">
            <strong>Sécurité :</strong> Aucun montant n'a été débité de votre compte.
          </p>
          <p>
            Toutes les transactions sont sécurisées par PayPlug et conformes aux normes PCI DSS.
          </p>
        </div>
      </div>
    </div>
  );
}