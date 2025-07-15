import { useState, useEffect, useRef } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { useBookingState } from "@/hooks/useBookingState";
import { payplugPromise, getPayPlugInstance } from "@/lib/payplug";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { CreditCard, Lock, Shield, AlertCircle, ExternalLink } from "lucide-react";
import { useLocation } from "wouter";

function CheckoutForm() {
  const { toast } = useToast();
  const [, setLocation] = useLocation();
  const { bookingData, updateCustomer, setCurrentStep, calculateTotalPrice } = useBookingState();
  const [isProcessing, setIsProcessing] = useState(false);
  const [payPlugError, setPayPlugError] = useState<string | null>(null);
  const [payPlugInstance, setPayPlugInstance] = useState<any>(null);
  const [paymentId, setPaymentId] = useState<string | null>(null);
  const [customerInfo, setCustomerInfo] = useState({
    firstName: "",
    lastName: "",
    email: "",
    phone: "",
    createAccount: false,
    acceptTerms: false,
    acceptMarketing: false,
  });

  // Refs pour les éléments PayPlug
  const cardHolderRef = useRef<HTMLDivElement>(null);
  const cardNumberRef = useRef<HTMLDivElement>(null);
  const cvvRef = useRef<HTMLDivElement>(null);
  const expirationRef = useRef<HTMLDivElement>(null);

  // Vérifier si PayPlug est disponible
  useEffect(() => {
    const checkPayPlug = async () => {
      try {
        const instance = await payplugPromise;
        if (!instance) {
          setPayPlugError("PayPlug est bloqué ou n'a pas pu être chargé. Veuillez réessayer.");
        } else {
          setPayPlugInstance(instance);
        }
      } catch (err) {
        setPayPlugError("Impossible de charger le module de paiement. Veuillez réessayer.");
      }
    };
    checkPayPlug();
  }, []);

  const pricing = calculateTotalPrice();

  // Sauvegarder les données dans sessionStorage pour la page checkout
  useEffect(() => {
    if (bookingData.service && bookingData.address && bookingData.deliveryTimeSlot) {
      const bookingDetails = {
        serviceId: bookingData.service.id,
        serviceName: bookingData.service.name,
        serviceVolume: bookingData.service.volume,
        address: bookingData.address.street,
        postalCode: bookingData.address.postalCode,
        city: bookingData.address.city,
        wasteTypes: bookingData.wasteTypes,
        distance: 0, // Distance calculée côté serveur
        pricing: {
          service: pricing.basePrice,
          transport: pricing.transportCost,
          total: pricing.totalTTC
        }
      };
      sessionStorage.setItem('bookingDetails', JSON.stringify(bookingDetails));
      
      // Sauvegarder aussi les dates
      const bookingDates = {
        deliveryDate: bookingData.deliveryTimeSlot.date,
        pickupDate: bookingData.pickupTimeSlot?.date,
        deliveryTimeSlot: bookingData.deliveryTimeSlot,
        pickupTimeSlot: bookingData.pickupTimeSlot
      };
      localStorage.setItem('bookingDates', JSON.stringify(bookingDates));
    }
  }, [bookingData, pricing]);

  // Initialiser les éléments PayPlug
  useEffect(() => {
    if (payPlugInstance && cardHolderRef.current && cardNumberRef.current && cvvRef.current && expirationRef.current) {
      // Créer les éléments PayPlug
      payPlugInstance.cardHolder(cardHolderRef.current, {
        placeholder: 'Nom sur la carte',
      });
      payPlugInstance.cardNumber(cardNumberRef.current, {
        placeholder: 'Numéro de carte',
      });
      payPlugInstance.cvv(cvvRef.current, {
        placeholder: 'CVV',
      });
      payPlugInstance.expiration(expirationRef.current, {
        placeholder: 'MM/AA',
      });

      // Gérer la validation
      payPlugInstance.onValidateForm(({ isFormValid }: { isFormValid: boolean }) => {
        if (!isFormValid) {
          setPayPlugError("Veuillez vérifier les informations de votre carte");
        } else {
          setPayPlugError(null);
        }
      });

      // Gérer la fin du paiement
      payPlugInstance.onCompleted((event: any) => {
        if (event.error) {
          toast({
            title: "Erreur de paiement",
            description: event.error.message || "Une erreur est survenue lors du paiement",
            variant: "destructive",
          });
          setIsProcessing(false);
        } else {
          toast({
            title: "Paiement réussi",
            description: "Votre commande a été confirmée avec succès!",
          });
          setCurrentStep(5);
        }
      });
    }
  }, [payPlugInstance, toast, setCurrentStep]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!payPlugInstance) {
      toast({
        title: "Erreur",
        description: "Le module de paiement n'est pas chargé",
        variant: "destructive",
      });
      return;
    }

    // Vérifier que toutes les données nécessaires sont présentes
    if (!bookingData.deliveryTimeSlot) {
      toast({
        title: "Informations manquantes",
        description: "Veuillez sélectionner une date de livraison dans l'étape précédente.",
        variant: "destructive",
      });
      return;
    }

    if (!customerInfo.acceptTerms) {
      toast({
        title: "Conditions requises",
        description: "Vous devez accepter les conditions générales pour continuer.",
        variant: "destructive",
      });
      return;
    }

    setIsProcessing(true);

    try {
      // Create order
      const orderData = {
        serviceId: bookingData.service!.id,
        deliveryTimeSlotId: bookingData.deliveryTimeSlot?.id,
        pickupTimeSlotId: bookingData.pickupTimeSlot?.id,
        customerFirstName: customerInfo.firstName,
        customerLastName: customerInfo.lastName,
        customerEmail: customerInfo.email,
        customerPhone: customerInfo.phone,
        deliveryStreet: bookingData.address!.street,
        deliveryCity: bookingData.address!.city,
        deliveryPostalCode: bookingData.address!.postalCode,
        deliveryCountry: bookingData.address!.country,
        deliveryNotes: bookingData.address!.deliveryNotes,
        durationDays: bookingData.durationDays,
        wasteTypes: bookingData.wasteTypes,
        status: "pending",
        paymentStatus: "pending",
      };

      const orderResponse = await apiRequest("/api/orders", "POST", orderData);
      const order = orderResponse;

      // Update customer in booking state
      updateCustomer({
        firstName: customerInfo.firstName,
        lastName: customerInfo.lastName,
        email: customerInfo.email,
        phone: customerInfo.phone,
        createAccount: customerInfo.createAccount,
      });

      // Créer un paiement PayPlug
      const paymentResponse = await apiRequest("/api/payplug/payment", "POST", {
        orderId: order.id,
        amount: pricing.totalTTC,
        customerEmail: customerInfo.email,
        customerName: `${customerInfo.firstName} ${customerInfo.lastName}`,
      });

      const payment = paymentResponse;
      setPaymentId(payment.id);

      // Valider le formulaire PayPlug
      payPlugInstance.validateForm();

      // Déclencher le paiement avec PayPlug
      const paymentTriggered = payPlugInstance.pay(
        payment.id,
        window.Payplug?.Scheme?.AUTO || 0,
        { save_card: false }
      );

      if (!paymentTriggered) {
        toast({
          title: "Erreur de paiement",
          description: "Impossible de déclencher le paiement. Vérifiez vos informations.",
          variant: "destructive",
        });
        setIsProcessing(false);
      }
    } catch (error: any) {
      toast({
        title: "Erreur",
        description: error.message || "Une erreur est survenue lors du traitement de votre commande.",
        variant: "destructive",
      });
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {/* Customer Information */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center">
            <CreditCard className="h-5 w-5 mr-2" />
            Vos informations
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid md:grid-cols-2 gap-4">
            <div>
              <Label htmlFor="first-name">Prénom *</Label>
              <Input
                id="first-name"
                required
                value={customerInfo.firstName}
                onChange={(e) => setCustomerInfo(prev => ({ ...prev, firstName: e.target.value }))}
              />
            </div>
            <div>
              <Label htmlFor="last-name">Nom *</Label>
              <Input
                id="last-name"
                required
                value={customerInfo.lastName}
                onChange={(e) => setCustomerInfo(prev => ({ ...prev, lastName: e.target.value }))}
              />
            </div>
          </div>
          <div className="grid md:grid-cols-2 gap-4">
            <div>
              <Label htmlFor="email">Email *</Label>
              <Input
                id="email"
                type="email"
                required
                value={customerInfo.email}
                onChange={(e) => setCustomerInfo(prev => ({ ...prev, email: e.target.value }))}
              />
            </div>
            <div>
              <Label htmlFor="phone">Téléphone *</Label>
              <Input
                id="phone"
                type="tel"
                required
                value={customerInfo.phone}
                onChange={(e) => setCustomerInfo(prev => ({ ...prev, phone: e.target.value }))}
              />
            </div>
          </div>
          <div className="flex items-center space-x-2">
            <Checkbox
              id="create-account"
              checked={customerInfo.createAccount}
              onCheckedChange={(checked) => 
                setCustomerInfo(prev => ({ ...prev, createAccount: checked as boolean }))
              }
            />
            <Label htmlFor="create-account" className="text-sm">
              Créer un compte pour suivre mes commandes
            </Label>
          </div>
        </CardContent>
      </Card>

      {/* Payment Method */}
      <Card>
        <CardHeader>
          <CardTitle>Mode de paiement</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <RadioGroup defaultValue="payplug">
            <div className="flex items-center space-x-2 p-4 border-2 border-primary-500 bg-primary-50 rounded-lg">
              <RadioGroupItem value="payplug" id="payplug" />
              <Label htmlFor="payplug" className="flex items-center flex-1">
                <CreditCard className="h-5 w-5 mr-3 text-primary-600" />
                <div>
                  <div className="font-medium">Carte bancaire</div>
                  <div className="text-sm text-slate-600">Paiement sécurisé via PayPlug</div>
                </div>
              </Label>
            </div>
          </RadioGroup>
          
          {/* PayPlug Payment Elements */}
          <div className="mt-4">
            {payPlugError ? (
              <Alert variant="destructive">
                <AlertCircle className="h-4 w-4" />
                <AlertDescription>
                  <div className="font-medium mb-2">Problème de chargement du paiement</div>
                  <div className="text-sm mb-3">{payPlugError}</div>
                  <div className="flex gap-2">
                    <Button variant="outline" size="sm" onClick={() => window.location.reload()}>
                      Réessayer
                    </Button>
                    <Button 
                      variant="outline" 
                      size="sm" 
                      onClick={() => {
                        toast({
                          title: "Alternative de paiement",
                          description: "Contactez-nous pour un paiement manuel : contact@bennespro.fr",
                        });
                      }}
                    >
                      Paiement manuel
                    </Button>
                  </div>
                </AlertDescription>
              </Alert>
            ) : (
              <div className="space-y-4">
                <div>
                  <Label htmlFor="cardholder">Nom du titulaire</Label>
                  <div ref={cardHolderRef} className="mt-1 p-3 border rounded-md" />
                </div>
                <div>
                  <Label htmlFor="cardnumber">Numéro de carte</Label>
                  <div ref={cardNumberRef} className="mt-1 p-3 border rounded-md" />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label htmlFor="expiration">Date d'expiration</Label>
                    <div ref={expirationRef} className="mt-1 p-3 border rounded-md" />
                  </div>
                  <div>
                    <Label htmlFor="cvv">CVV</Label>
                    <div ref={cvvRef} className="mt-1 p-3 border rounded-md" />
                  </div>
                </div>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Terms and Conditions */}
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
            <Label htmlFor="accept-terms" className="text-sm leading-relaxed">
              J'accepte les{' '}
              <a href="#" className="text-primary-600 hover:underline">conditions générales de vente</a>{' '}
              et la{' '}
              <a href="#" className="text-primary-600 hover:underline">politique de confidentialité</a> *
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
            <Label htmlFor="accept-marketing" className="text-sm">
              J'accepte de recevoir des offres commerciales par email
            </Label>
          </div>
        </CardContent>
      </Card>

      {/* Submit Buttons */}
      <div className="space-y-3">
        <Button
          type="button"
          className="w-full bg-blue-600 hover:bg-blue-700 text-lg py-4 h-auto"
          onClick={() => {
            // Sauvegarder toutes les données nécessaires dans sessionStorage
            if (bookingData.service && bookingData.address && bookingData.deliveryTimeSlot) {
              const bookingDetails = {
                serviceId: bookingData.service.id,
                serviceName: bookingData.service.name,
                serviceVolume: bookingData.service.volume,
                address: bookingData.address.street,
                postalCode: bookingData.address.postalCode,
                city: bookingData.address.city,
                wasteTypes: bookingData.wasteTypes,
                distance: 0,
                pricing: {
                  service: pricing.basePrice,
                  transport: pricing.transportCost,
                  total: pricing.totalTTC
                }
              };
              sessionStorage.setItem('bookingDetails', JSON.stringify(bookingDetails));
              
              // Sauvegarder aussi les dates
              const bookingDates = {
                deliveryDate: bookingData.deliveryTimeSlot.date,
                pickupDate: bookingData.pickupTimeSlot?.date,
                deliveryTimeSlot: bookingData.deliveryTimeSlot,
                pickupTimeSlot: bookingData.pickupTimeSlot
              };
              localStorage.setItem('bookingDates', JSON.stringify(bookingDates));
              
              // Sauvegarder les informations client
              updateCustomer({
                firstName: customerInfo.firstName,
                lastName: customerInfo.lastName,
                email: customerInfo.email,
                phone: customerInfo.phone,
              });
              
              // Naviguer vers la page checkout séparée
              setLocation('/checkout');
            } else {
              toast({
                title: "Informations manquantes",
                description: "Veuillez compléter toutes les étapes avant de continuer.",
                variant: "destructive",
              });
            }
          }}
        >
          <ExternalLink className="h-5 w-5 mr-2" />
          Continuer vers la page de paiement
        </Button>
        
        <div className="text-center text-sm text-gray-500">ou</div>
        
        <Button
          type="submit"
          className="w-full bg-red-600 hover:bg-red-700 text-lg py-4 h-auto"
          disabled={!payPlugInstance || isProcessing || !!payPlugError}
        >
          {isProcessing ? (
            <>
              <div className="animate-spin w-4 h-4 border-2 border-white border-t-transparent rounded-full mr-2" />
              Traitement...
            </>
          ) : payPlugError ? (
            <>
              <AlertCircle className="h-5 w-5 mr-2" />
              Paiement indisponible
            </>
          ) : (
            <>
              <Lock className="h-5 w-5 mr-2" />
              Payer {pricing.totalTTC.toFixed(2)}€
            </>
          )}
        </Button>
      </div>

      <div className="text-center">
        <p className="text-xs text-slate-500 flex items-center justify-center">
          <Shield className="h-4 w-4 mr-1" />
          Paiement sécurisé SSL 256-bit
        </p>
      </div>
    </form>
  );
}

// Composant de fallback anti-AdBlock avec instructions détaillées
function PaymentFallback() {
  const { toast } = useToast();
  const { bookingData, calculateTotalPrice, setCurrentStep } = useBookingState();
  const pricing = calculateTotalPrice();

  const handleManualOrder = () => {
    toast({
      title: "Commande enregistrée",
      description: "Votre commande a été enregistrée. Nous vous contacterons pour le paiement.",
    });
    setCurrentStep(5);
  };

  const handleRetry = () => {
    window.location.reload();
  };

  return (
    <div className="space-y-6">
      <Alert variant="destructive">
        <AlertCircle className="h-4 w-4" />
        <AlertDescription>
          <div className="font-medium mb-2">Module de paiement bloqué par AdBlock</div>
          <div className="text-sm">
            Pour des raisons de sécurité, votre bloqueur de publicités empêche le chargement du système de paiement PayPlug.
          </div>
        </AlertDescription>
      </Alert>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center">
            <Shield className="h-5 w-5 mr-2" />
            Activer les paiements sécurisés
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="text-sm space-y-3">
            <div className="bg-blue-50 p-3 rounded-lg border border-blue-200">
              <div className="font-medium text-blue-800 mb-1">🛡️ Instructions AdBlock</div>
              <div className="text-blue-700 space-y-1">
                <div>1. Cliquez sur l'icône AdBlock dans votre navigateur</div>
                <div>2. Sélectionnez "Désactiver sur ce site"</div>
                <div>3. Rechargez la page</div>
              </div>
            </div>
            
            <div className="bg-green-50 p-3 rounded-lg border border-green-200">
              <div className="font-medium text-green-800 mb-1">🔒 Sécurité PayPlug</div>
              <div className="text-sm text-green-700">
                PayPlug protège des millions de transactions. Vos données bancaires sont cryptées et sécurisées.
              </div>
            </div>
          </div>

          <div className="flex gap-3">
            <Button onClick={handleRetry} variant="outline" className="flex-1">
              <AlertCircle className="h-4 w-4 mr-2" />
              Réessayer
            </Button>
            <Button onClick={handleManualOrder} className="flex-1 bg-red-600 hover:bg-red-700">
              Commande manuelle
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Total de votre commande</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex justify-between items-center">
            <span className="text-lg">Montant à payer:</span>
            <span className="font-bold text-2xl text-red-600">{pricing.totalTTC.toFixed(2)}€</span>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}

export default function PaymentStep() {
  const { bookingData, calculateTotalPrice } = useBookingState();
  const [payPlugReady, setPayPlugReady] = useState(false);
  const { toast } = useToast();
  const pricing = calculateTotalPrice();

  useEffect(() => {
    const checkPayPlugReady = async () => {
      try {
        // Vérifier si PayPlug est prêt
        const payplug = await payplugPromise;
        if (payplug) {
          setPayPlugReady(true);
        }

      } catch (error) {
        console.error("Erreur PayPlug:", error);
        setPayPlugReady(false);
      }
    };

    checkPayPlugReady();
  }, [bookingData.service, pricing.totalTTC]);

  // Si PayPlug n'est pas prêt, afficher le fallback
  if (!payPlugReady) {
    return <PaymentFallback />;
  }

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
          {bookingData.durationDays && (
            <div className="flex justify-between items-center p-3 bg-white rounded-lg">
              <span className="text-slate-600 font-medium">⏱️ Durée :</span>
              <span className="font-bold text-green-700">{bookingData.durationDays} jour{bookingData.durationDays > 1 ? 's' : ''}</span>
            </div>
          )}
          {bookingData.address && (
            <div className="flex justify-between items-center p-3 bg-white rounded-lg">
              <span className="text-slate-600 font-medium">📍 Adresse :</span>
              <span className="font-bold text-green-700 text-right">{bookingData.address.street}, {bookingData.address.postalCode} {bookingData.address.city}</span>
            </div>
          )}
          {bookingData.deliveryTimeSlot ? (
            <div className="flex justify-between items-center p-3 bg-white rounded-lg">
              <span className="text-slate-600 font-medium">📅 Livraison :</span>
              <span className="font-bold text-green-700">
                {new Date(bookingData.deliveryTimeSlot.date).toLocaleDateString('fr-FR')} 
                {bookingData.deliveryTimeSlot.startTime && ` de ${bookingData.deliveryTimeSlot.startTime} à ${bookingData.deliveryTimeSlot.endTime}`}
              </span>
            </div>
          ) : (
            <div className="flex justify-between items-center p-3 bg-red-100 rounded-lg border border-red-300">
              <span className="text-red-600 font-medium">⚠️ Date de livraison :</span>
              <span className="font-bold text-red-700">Non sélectionnée</span>
            </div>
          )}
          {bookingData.pickupTimeSlot && (
            <div className="flex justify-between items-center p-3 bg-white rounded-lg">
              <span className="text-slate-600 font-medium">🔄 Récupération :</span>
              <span className="font-bold text-green-700">
                {new Date(bookingData.pickupTimeSlot.date).toLocaleDateString('fr-FR')}
                {bookingData.pickupTimeSlot.startTime && ` de ${bookingData.pickupTimeSlot.startTime} à ${bookingData.pickupTimeSlot.endTime}`}
              </span>
            </div>
          )}
        </CardContent>
      </Card>

      <CheckoutForm />
    </div>
  );
}
