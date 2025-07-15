import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Checkbox } from "@/components/ui/checkbox";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { useToast } from "@/hooks/use-toast";
import { useBookingState } from "@/hooks/useBookingState";
import { apiRequest } from "@/lib/queryClient";
import { 
  CreditCard, 
  CheckCircle, 
  Calendar, 
  AlertCircle,
  Shield,
  MapPin,
  Clock,
  X
} from "lucide-react";

interface CustomerInfo {
  email: string;
  phone: string;
  firstName: string;
  lastName: string;
  company: string;
  address: string;
  city: string;
  zipCode: string;
  acceptTerms: boolean;
  acceptMarketing: boolean;
}

// PayPlug Payment Component - Sans scripts d'injection
function PayPlugPayment() {
  const { toast } = useToast();
  const [isProcessing, setIsProcessing] = useState(false);

  const handlePayment = async () => {
    setIsProcessing(true);
    
    try {
      // Simulation paiement PayPlug
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      toast({
        title: "Paiement confirmé",
        description: "Votre commande a été enregistrée avec succès",
      });
      
      // Redirection vers page de confirmation
      window.location.href = "/booking/confirmation";
    } catch (error) {
      toast({
        title: "Erreur de paiement",
        description: "Une erreur est survenue lors du traitement de votre paiement",
        variant: "destructive",
      });
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <div className="space-y-4">
      <div className="p-4 bg-blue-50 rounded-lg border border-blue-200">
        <div className="flex items-center justify-center text-center">
          <Shield className="h-8 w-8 text-blue-600 mr-3" />
          <div>
            <div className="font-semibold text-blue-900">Paiement sécurisé PayPlug</div>
            <div className="text-sm text-blue-700">
              Vos données sont cryptées et protégées
            </div>
          </div>
        </div>
      </div>

      <div className="space-y-3">
        <div className="grid grid-cols-2 gap-3">
          <div>
            <Label htmlFor="cardNumber">Numéro de carte</Label>
            <Input id="cardNumber" placeholder="1234 5678 9012 3456" className="mt-1" />
          </div>
          <div>
            <Label htmlFor="cardExpiry">Date d'expiration</Label>
            <Input id="cardExpiry" placeholder="MM/YY" className="mt-1" />
          </div>
        </div>
        
        <div className="grid grid-cols-2 gap-3">
          <div>
            <Label htmlFor="cardCvc">CVC</Label>
            <Input id="cardCvc" placeholder="123" className="mt-1" />
          </div>
          <div>
            <Label htmlFor="cardName">Nom sur la carte</Label>
            <Input id="cardName" placeholder="Jean Dupont" className="mt-1" />
          </div>
        </div>
      </div>

      <Button 
        onClick={handlePayment}
        className="w-full bg-blue-600 hover:bg-blue-700"
        disabled={isProcessing}
      >
        {isProcessing ? (
          <>
            <div className="animate-spin h-4 w-4 mr-2 border-2 border-white border-t-transparent rounded-full" />
            Traitement en cours...
          </>
        ) : (
          <>
            <CreditCard className="h-4 w-4 mr-2" />
            Payer maintenant
          </>
        )}
      </Button>
    </div>
  );
}

export default function PaymentStep() {
  const { bookingData, calculateTotalPrice } = useBookingState();
  const { toast } = useToast();
  const pricing = calculateTotalPrice();

  const [customerInfo, setCustomerInfo] = useState<CustomerInfo>({
    email: '',
    phone: '',
    firstName: '',
    lastName: '',
    company: '',
    address: '',
    city: '',
    zipCode: '',
    acceptTerms: false,
    acceptMarketing: false
  });

  const [paymentMethod, setPaymentMethod] = useState('payplug');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!customerInfo.acceptTerms) {
      toast({
        title: "Conditions générales",
        description: "Veuillez accepter les conditions générales",
        variant: "destructive",
      });
      return;
    }

    setIsSubmitting(true);
    
    try {
      const response = await apiRequest("/api/orders", {
        method: "POST",
        body: JSON.stringify({
          ...bookingData,
          customerInfo,
          paymentMethod,
          pricing
        })
      });

      if (response.ok) {
        toast({
          title: "Commande enregistrée",
          description: "Votre commande a été enregistrée avec succès",
        });
      }
    } catch (error) {
      toast({
        title: "Erreur",
        description: "Une erreur est survenue lors de l'enregistrement",
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="text-center">
        <h2 className="text-2xl font-bold text-slate-900 mb-2">Finaliser la commande</h2>
        <p className="text-slate-600">Complétez vos informations et procédez au paiement</p>
      </div>

      {/* Résumé de la réservation */}
      <Card className="border-2 border-green-200 bg-green-50/50">
        <CardHeader>
          <CardTitle className="flex items-center text-green-800">
            <CheckCircle className="h-6 w-6 mr-3" />
            Résumé de votre réservation
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {bookingData.service && (
            <div className="flex justify-between items-center p-3 bg-white rounded-lg">
              <span className="text-slate-600 font-medium">🚛 Service :</span>
              <span className="font-bold text-green-700">{bookingData.service.name}</span>
            </div>
          )}
          
          {bookingData.selectedDate && (
            <div className="flex justify-between items-center p-3 bg-white rounded-lg">
              <span className="text-slate-600 font-medium flex items-center">
                <Calendar className="h-4 w-4 mr-2" />
                Date :
              </span>
              <span className="font-bold text-green-700">
                {new Date(bookingData.selectedDate).toLocaleDateString('fr-FR')}
              </span>
            </div>
          )}

          {bookingData.selectedTimeSlot && (
            <div className="flex justify-between items-center p-3 bg-white rounded-lg">
              <span className="text-slate-600 font-medium flex items-center">
                <Clock className="h-4 w-4 mr-2" />
                Créneau :
              </span>
              <span className="font-bold text-green-700">{bookingData.selectedTimeSlot}</span>
            </div>
          )}

          {bookingData.deliveryAddress && (
            <div className="flex justify-between items-center p-3 bg-white rounded-lg">
              <span className="text-slate-600 font-medium flex items-center">
                <MapPin className="h-4 w-4 mr-2" />
                Adresse :
              </span>
              <span className="font-bold text-green-700">{bookingData.deliveryAddress}</span>
            </div>
          )}

          <div className="p-3 bg-green-100 rounded-lg border border-green-300">
            <div className="flex justify-between items-center text-lg">
              <span className="font-bold text-green-800">Total TTC :</span>
              <span className="font-bold text-2xl text-green-700">{pricing.totalTTC.toFixed(2)}€</span>
            </div>
          </div>
        </CardContent>
      </Card>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Informations client */}
        <Card>
          <CardHeader>
            <CardTitle>Informations de contact</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="firstName">Prénom *</Label>
                <Input
                  id="firstName"
                  value={customerInfo.firstName}
                  onChange={(e) => setCustomerInfo(prev => ({ ...prev, firstName: e.target.value }))}
                  required
                />
              </div>
              <div>
                <Label htmlFor="lastName">Nom *</Label>
                <Input
                  id="lastName"
                  value={customerInfo.lastName}
                  onChange={(e) => setCustomerInfo(prev => ({ ...prev, lastName: e.target.value }))}
                  required
                />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="email">Email *</Label>
                <Input
                  id="email"
                  type="email"
                  value={customerInfo.email}
                  onChange={(e) => setCustomerInfo(prev => ({ ...prev, email: e.target.value }))}
                  required
                />
              </div>
              <div>
                <Label htmlFor="phone">Téléphone *</Label>
                <Input
                  id="phone"
                  type="tel"
                  value={customerInfo.phone}
                  onChange={(e) => setCustomerInfo(prev => ({ ...prev, phone: e.target.value }))}
                  required
                />
              </div>
            </div>

            <div>
              <Label htmlFor="company">Entreprise (optionnel)</Label>
              <Input
                id="company"
                value={customerInfo.company}
                onChange={(e) => setCustomerInfo(prev => ({ ...prev, company: e.target.value }))}
              />
            </div>

            <div>
              <Label htmlFor="address">Adresse *</Label>
              <Input
                id="address"
                value={customerInfo.address}
                onChange={(e) => setCustomerInfo(prev => ({ ...prev, address: e.target.value }))}
                required
              />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="city">Ville *</Label>
                <Input
                  id="city"
                  value={customerInfo.city}
                  onChange={(e) => setCustomerInfo(prev => ({ ...prev, city: e.target.value }))}
                  required
                />
              </div>
              <div>
                <Label htmlFor="zipCode">Code postal *</Label>
                <Input
                  id="zipCode"
                  value={customerInfo.zipCode}
                  onChange={(e) => setCustomerInfo(prev => ({ ...prev, zipCode: e.target.value }))}
                  required
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Méthode de paiement */}
        <Card>
          <CardHeader>
            <CardTitle>Méthode de paiement</CardTitle>
          </CardHeader>
          <CardContent>
            <RadioGroup value={paymentMethod} onValueChange={setPaymentMethod}>
              <div className="flex items-center space-x-2 p-3 border rounded-lg">
                <RadioGroupItem value="payplug" id="payplug" />
                <Label htmlFor="payplug" className="flex items-center flex-1 cursor-pointer">
                  <CreditCard className="h-5 w-5 mr-3 text-blue-600" />
                  <div>
                    <div className="font-medium">Carte bancaire</div>
                    <div className="text-sm text-slate-600">Paiement sécurisé via PayPlug</div>
                  </div>
                </Label>
              </div>
            </RadioGroup>
            
            {paymentMethod === 'payplug' && (
              <div className="mt-4">
                <PayPlugPayment />
              </div>
            )}
          </CardContent>
        </Card>

        {/* Conditions générales */}
        <Card>
          <CardHeader>
            <CardTitle>Conditions générales</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex items-start space-x-2">
              <Checkbox
                id="accept-terms"
                required
                checked={customerInfo.acceptTerms}
                onCheckedChange={(checked) => 
                  setCustomerInfo(prev => ({ ...prev, acceptTerms: checked as boolean }))
                }
              />
              <Label htmlFor="accept-terms" className="text-sm leading-relaxed cursor-pointer">
                J'accepte les{' '}
                <a href="#" className="text-blue-600 hover:underline">conditions générales de vente</a>{' '}
                et la{' '}
                <a href="#" className="text-blue-600 hover:underline">politique de confidentialité</a> *
              </Label>
            </div>
            
            <div className="flex items-start space-x-2">
              <Checkbox
                id="accept-marketing"
                checked={customerInfo.acceptMarketing}
                onCheckedChange={(checked) => 
                  setCustomerInfo(prev => ({ ...prev, acceptMarketing: checked as boolean }))
                }
              />
              <Label htmlFor="accept-marketing" className="text-sm cursor-pointer">
                J'accepte de recevoir des offres commerciales par email
              </Label>
            </div>
          </CardContent>
        </Card>

        {/* Boutons d'action */}
        <div className="flex flex-col md:flex-row gap-4">
          <Button 
            type="button" 
            variant="outline" 
            className="flex-1"
            onClick={() => window.history.back()}
          >
            Retour
          </Button>
          
          <Button 
            type="submit"
            className="flex-1 bg-green-600 hover:bg-green-700"
            disabled={isSubmitting || !customerInfo.acceptTerms}
          >
            {isSubmitting ? (
              <>
                <div className="animate-spin h-4 w-4 mr-2 border-2 border-white border-t-transparent rounded-full" />
                Traitement...
              </>
            ) : (
              <>
                <CheckCircle className="h-4 w-4 mr-2" />
                Finaliser la commande
              </>
            )}
          </Button>
        </div>
      </form>
    </div>
  );
}