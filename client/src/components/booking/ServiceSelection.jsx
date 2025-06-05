var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
import { useState, useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { useLocation } from "wouter";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Label } from "@/components/ui/label";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Calendar } from "@/components/ui/calendar";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { apiRequest } from "@/lib/queryClient";
import { Truck, AlertTriangle, MapPin, Calendar as CalendarIcon, Loader2 } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { format, addDays } from "date-fns";
import { fr } from "date-fns/locale";
import { cn } from "@/lib/utils";
export default function ServiceSelection() {
    var _this = this;
    var _a = useLocation(), setLocation = _a[1];
    var toast = useToast().toast;
    var _b = useState(null), selectedServiceId = _b[0], setSelectedServiceId = _b[1];
    var _c = useState(""), selectedWasteType = _c[0], setSelectedWasteType = _c[1];
    var _d = useState(""), deliveryAddress = _d[0], setDeliveryAddress = _d[1];
    var _e = useState(""), postalCode = _e[0], setPostalCode = _e[1];
    var _f = useState(""), city = _f[0], setCity = _f[1];
    var _g = useState(0), distance = _g[0], setDistance = _g[1];
    var _h = useState(false), isCalculatingDistance = _h[0], setIsCalculatingDistance = _h[1];
    var _j = useState(""), distanceError = _j[0], setDistanceError = _j[1];
    var _k = useState([]), addressSuggestions = _k[0], setAddressSuggestions = _k[1];
    var _l = useState(false), showSuggestions = _l[0], setShowSuggestions = _l[1];
    var _m = useState(false), isLoadingSuggestions = _m[0], setIsLoadingSuggestions = _m[1];
    var _o = useState(null), priceData = _o[0], setPriceData = _o[1];
    // Nouvelles variables pour la durée de location
    var _p = useState(undefined), startDate = _p[0], setStartDate = _p[1];
    var _q = useState(undefined), endDate = _q[0], setEndDate = _q[1];
    var _r = useState(false), isCalendarOpen = _r[0], setIsCalendarOpen = _r[1];
    var _s = useState(7), durationDays = _s[0], setDurationDays = _s[1]; // Durée par défaut: 1 semaine
    var _t = useQuery({
        queryKey: ['/api/services'],
    }), services = _t.data, isLoading = _t.isLoading, error = _t.error;
    // Récupérer les types de déchets configurés
    var wasteTypes = useQuery({
        queryKey: ['/api/waste-types'],
    }).data;
    // Récupérer les tarifs de traitement
    var treatmentPricing = useQuery({
        queryKey: ['/api/treatment-pricing'],
    }).data;
    var service = services ? services.find(function (s) { return s.id === selectedServiceId; }) : undefined;
    // Calculer automatiquement la date de fin basée sur la date de début et la durée
    useEffect(function () {
        if (startDate && durationDays > 0) {
            var calculatedEndDate = addDays(startDate, durationDays);
            setEndDate(calculatedEndDate);
        }
    }, [startDate, durationDays]);
    // Calcul automatique de la distance quand les données changent
    useEffect(function () {
        if (selectedServiceId && deliveryAddress && postalCode && city && selectedWasteType) {
            calculateDistance();
        }
    }, [selectedServiceId, deliveryAddress, postalCode, city, selectedWasteType, durationDays]);
    // Fonction pour valider et calculer la distance
    var calculateDistance = function () { return __awaiter(_this, void 0, void 0, function () {
        var wasteType, wasteTypeId, response, data, error_1;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    if (!selectedServiceId || !deliveryAddress || !postalCode || !city || !selectedWasteType) {
                        setDistance(0);
                        return [2 /*return*/];
                    }
                    setIsCalculatingDistance(true);
                    setDistanceError("");
                    _a.label = 1;
                case 1:
                    _a.trys.push([1, 4, 5, 6]);
                    wasteType = wasteTypes.find(function (wt) { return wt.name === selectedWasteType; });
                    wasteTypeId = wasteType ? wasteType.id : null;
                    if (!wasteTypeId) {
                        setDistanceError("Type de déchet non valide");
                        return [2 /*return*/];
                    }
                    return [4 /*yield*/, apiRequest('POST', '/api/calculate-pricing', {
                            serviceId: selectedServiceId,
                            wasteTypes: [wasteTypeId],
                            address: deliveryAddress,
                            postalCode: postalCode,
                            city: city,
                            durationDays: durationDays
                        })];
                case 2:
                    response = _a.sent();
                    return [4 /*yield*/, response.json()];
                case 3:
                    data = _a.sent();
                    if (data.success && data.distance) {
                        setDistance(data.distance.kilometers);
                        setPriceData(data); // Sauvegarder toutes les données de prix
                        setDistanceError("");
                    }
                    else {
                        setDistanceError(data.message || "Impossible de calculer la distance");
                        setDistance(15); // Distance estimée par défaut
                        setPriceData(null);
                    }
                    return [3 /*break*/, 6];
                case 4:
                    error_1 = _a.sent();
                    console.error('Erreur calcul distance:', error_1);
                    if (error_1.message.includes('Adresse du site industriel non configurée')) {
                        setDistanceError("Configuration requise : veuillez configurer l'adresse du site industriel dans le panneau d'administration");
                    }
                    else {
                        setDistanceError("Erreur lors du calcul de distance");
                    }
                    setDistance(15); // Distance estimée par défaut
                    return [3 /*break*/, 6];
                case 5:
                    setIsCalculatingDistance(false);
                    return [7 /*endfinally*/];
                case 6: return [2 /*return*/];
            }
        });
    }); };
    // Fonction pour récupérer les suggestions d'adresses
    var fetchAddressSuggestions = function (input) { return __awaiter(_this, void 0, void 0, function () {
        var response, data, error_2;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    if (input.length < 3) {
                        setAddressSuggestions([]);
                        setShowSuggestions(false);
                        return [2 /*return*/];
                    }
                    setIsLoadingSuggestions(true);
                    _a.label = 1;
                case 1:
                    _a.trys.push([1, 4, 5, 6]);
                    return [4 /*yield*/, apiRequest('GET', "/api/places/autocomplete?input=".concat(encodeURIComponent(input)))];
                case 2:
                    response = _a.sent();
                    return [4 /*yield*/, response.json()];
                case 3:
                    data = _a.sent();
                    if (data.suggestions) {
                        setAddressSuggestions(data.suggestions);
                        setShowSuggestions(true);
                    }
                    return [3 /*break*/, 6];
                case 4:
                    error_2 = _a.sent();
                    console.error('Erreur autocomplétion:', error_2);
                    return [3 /*break*/, 6];
                case 5:
                    setIsLoadingSuggestions(false);
                    return [7 /*endfinally*/];
                case 6: return [2 /*return*/];
            }
        });
    }); };
    var handleServiceSelect = function (service) {
        setSelectedServiceId(service.id);
    };
    var handleWasteTypeChange = function (wasteType) {
        setSelectedWasteType(wasteType);
    };
    var handleAddressChange = function (value) {
        setDeliveryAddress(value);
        fetchAddressSuggestions(value);
    };
    var handleSuggestionSelect = function (suggestion) {
        setDeliveryAddress(suggestion.description);
        setShowSuggestions(false);
        // Extraire code postal et ville de la suggestion
        var parts = suggestion.description.split(', ');
        if (parts.length >= 2) {
            var lastPart = parts[parts.length - 1];
            var postalMatch = lastPart.match(/\b\d{5}\b/);
            if (postalMatch) {
                setPostalCode(postalMatch[0]);
                var cityPart = lastPart.replace(postalMatch[0], '').trim();
                setCity(cityPart);
            }
        }
    };
    // Calculer le prix en fonction de la sélection
    var calculatePrice = function () {
        var _a, _b, _c, _d, _e, _f, _g;
        if (!service || !priceData) {
            return { service: 0, transport: 0, treatment: 0, total: 0, details: [] };
        }
        var servicePrice = ((_a = priceData.pricing) === null || _a === void 0 ? void 0 : _a.service) || parseFloat(service.basePrice);
        var durationSupplement = ((_b = priceData.pricing) === null || _b === void 0 ? void 0 : _b.durationSupplement) || 0;
        var transportCost = ((_c = priceData.pricing) === null || _c === void 0 ? void 0 : _c.transport) || 0;
        var totalTreatmentCost = ((_d = priceData.pricing) === null || _d === void 0 ? void 0 : _d.treatment) || 0;
        var total = ((_e = priceData.pricing) === null || _e === void 0 ? void 0 : _e.total) || (servicePrice + durationSupplement + transportCost + totalTreatmentCost);
        var details = [
            { label: "Service de base", amount: servicePrice },
        ];
        // Ajouter le supplément de durée si applicable
        if (durationSupplement > 0) {
            details.push({ label: "Suppl\u00E9ment dur\u00E9e (".concat(durationDays, " jours)"), amount: durationSupplement });
        }
        var roundTripKm = ((_f = priceData.distance) === null || _f === void 0 ? void 0 : _f.roundTripKm) || (distance * 2);
        details.push({ label: "Transport (".concat(roundTripKm.toFixed(1), " km aller-retour)"), amount: transportCost });
        // Ajouter les détails des coûts de traitement si disponibles
        if (totalTreatmentCost > 0) {
            var maxTonnage = ((_g = priceData.service) === null || _g === void 0 ? void 0 : _g.maxTonnage) || service.volume || 0;
            var wasteTypeName = selectedWasteType || "Déchets";
            details.push({
                label: "Traitement ".concat(wasteTypeName, " (").concat(maxTonnage, "T max)"),
                amount: totalTreatmentCost
            });
        }
        details.push({ label: "Total TTC", amount: total });
        return {
            service: servicePrice,
            transport: transportCost,
            treatment: totalTreatmentCost,
            total: total,
            details: details
        };
    };
    var priceCalculation = calculatePrice();
    // Fonction pour gérer la réservation
    var handleBooking = function () {
        if (!selectedServiceId || !selectedWasteType || !deliveryAddress || !postalCode || !city || !startDate || !endDate) {
            toast({
                title: "Informations manquantes",
                description: "Veuillez remplir tous les champs requis y compris les dates de location",
                variant: "destructive",
            });
            return;
        }
        if (!service) {
            toast({
                title: "Erreur",
                description: "Service non sélectionné",
                variant: "destructive",
            });
            return;
        }
        // Préparer les données de réservation avec les nouvelles informations de durée
        var bookingDetails = {
            serviceId: selectedServiceId,
            serviceName: service.name,
            serviceVolume: service.volume,
            address: deliveryAddress,
            postalCode: postalCode,
            city: city,
            wasteTypes: [selectedWasteType],
            distance: distance * 2, // Distance aller-retour
            // Nouvelles données de durée de location
            startDate: startDate.toISOString(),
            endDate: endDate.toISOString(),
            durationDays: durationDays,
            deliveryDate: startDate.toISOString(), // Date de livraison = date de début
            pricing: {
                service: priceCalculation.service,
                transport: priceCalculation.transport,
                total: priceCalculation.total
            }
        };
        // Sauvegarder dans sessionStorage et rediriger vers checkout
        sessionStorage.setItem('bookingDetails', JSON.stringify(bookingDetails));
        setLocation('/checkout');
    };
    // Obtenir les types de déchets disponibles depuis les configurations admin
    var availableWasteTypes = Array.isArray(wasteTypes) ? wasteTypes.map(function (wt) { return wt.name; }) : [];
    if (isLoading) {
        return (<div className="flex items-center justify-center py-8">
        <Loader2 className="h-8 w-8 animate-spin text-red-600"/>
        <span className="ml-2 text-gray-600">Chargement des services...</span>
      </div>);
    }
    if (error) {
        return (<Alert variant="destructive">
        <AlertTriangle className="h-4 w-4"/>
        <AlertDescription>
          Erreur lors du chargement des services. Veuillez réessayer.
        </AlertDescription>
      </Alert>);
    }
    return (<div className="grid lg:grid-cols-3 gap-8">
      {/* Left Column - Configuration */}
      <div className="lg:col-span-2 space-y-6">
        {/* Container Type Selection */}
        <div>
          <div className="flex items-center mb-4">
            <Truck className="h-5 w-5 mr-2 text-red-600"/>
            <h3 className="text-lg font-semibold text-gray-900">Choisissez votre benne</h3>
          </div>
          <div className="grid lg:grid-cols-1 gap-6">
            {Array.isArray(services) && services.map(function (service) {
            var _a;
            return (<div key={service.id} className={"relative cursor-pointer transition-all ".concat(selectedServiceId === service.id ? "ring-2 ring-red-500" : "")} onClick={function () { return handleServiceSelect(service); }}>
                <Card className={"".concat(selectedServiceId === service.id
                    ? "border-red-500 bg-red-50"
                    : "border-gray-200 hover:border-red-300")}>
                  <CardContent className="p-6">
                    <div className="grid md:grid-cols-3 gap-4">
                      {/* Image de la benne */}
                      <div className="md:col-span-1">
                        {service.imageUrl && (<img src={service.imageUrl} alt={service.name} className="w-full h-32 object-contain bg-gray-50 rounded-lg"/>)}
                      </div>
                      
                      {/* Informations principales */}
                      <div className="md:col-span-1">
                        <div className="flex items-center justify-between mb-3">
                          <h4 className="text-lg font-semibold text-gray-900">{service.name}</h4>
                          <span className="text-red-600 font-bold text-xl">
                            {parseFloat(service.basePrice).toFixed(0)}€
                          </span>
                        </div>
                        
                        <div className="space-y-2 text-sm text-gray-600">
                          <p><strong>Volume:</strong> {service.volume}m³</p>
                          {service.length && service.width && service.height && (<p><strong>Dimensions:</strong> {service.length}m × {service.width}m × {service.height}m</p>)}
                          {service.description && (<p className="text-gray-700 mt-2">{service.description}</p>)}
                        </div>
                      </div>
                      
                      {/* Prestations incluses */}
                      <div className="md:col-span-1">
                        <h5 className="font-medium text-gray-900 mb-2">Prestations incluses</h5>
                        <div className="space-y-1">
                          {(_a = service.includedServices) === null || _a === void 0 ? void 0 : _a.map(function (includedService, index) { return (<div key={index} className="flex items-center text-xs text-gray-600">
                              <div className="w-1.5 h-1.5 bg-green-500 rounded-full mr-2"></div>
                              {includedService}
                            </div>); })}
                        </div>
                      </div>
                    </div>
                    
                    {selectedServiceId === service.id && (<div className="mt-4 pt-4 border-t border-gray-200">
                        <Badge className="bg-red-600 text-white">✓ Sélectionné</Badge>
                      </div>)}
                  </CardContent>
                </Card>
              </div>);
        })}
          </div>
        </div>

        {/* Waste Type Selection */}
        <div>
          <h3 className="text-lg font-semibold text-gray-900 mb-3">Type de déchet</h3>
          {availableWasteTypes.length > 0 ? (<Select value={selectedWasteType} onValueChange={handleWasteTypeChange}>
              <SelectTrigger className="w-full">
                <SelectValue placeholder="Sélectionnez un type de déchet"/>
              </SelectTrigger>
              <SelectContent>
                {availableWasteTypes.map(function (wasteType) { return (<SelectItem key={wasteType} value={wasteType}>
                    {wasteType}
                  </SelectItem>); })}
              </SelectContent>
            </Select>) : (<div className="text-center text-gray-500 py-4 border-2 border-dashed border-gray-200 rounded-lg">
              <p className="text-sm">Aucun type de déchet configuré.</p>
              <p className="text-xs text-gray-400 mt-1">Contactez l'administrateur pour configurer les types de déchets.</p>
            </div>)}
        </div>

        {/* Address Section */}
        <div>
          <div className="flex items-center mb-4">
            <MapPin className="h-5 w-5 mr-2 text-red-600"/>
            <h3 className="text-lg font-semibold text-gray-900">Adresse de livraison</h3>
          </div>
          
          <div className="space-y-4">
            <div className="relative">
              <Label htmlFor="address">Adresse *</Label>
              <Input id="address" type="text" value={deliveryAddress} onChange={function (e) { return handleAddressChange(e.target.value); }} placeholder="Tapez votre adresse..." className="mt-1"/>
              
              {/* Suggestions d'adresses */}
              {showSuggestions && addressSuggestions.length > 0 && (<div className="absolute z-10 w-full mt-1 bg-white border border-gray-200 rounded-md shadow-lg max-h-60 overflow-auto">
                  {addressSuggestions.map(function (suggestion, index) { return (<div key={index} className="px-4 py-2 hover:bg-gray-100 cursor-pointer text-sm" onClick={function () { return handleSuggestionSelect(suggestion); }}>
                      <div className="font-medium">{suggestion.main_text}</div>
                      <div className="text-gray-500 text-xs">{suggestion.secondary_text}</div>
                    </div>); })}
                </div>)}
              
              {isLoadingSuggestions && (<div className="absolute right-3 top-9">
                  <Loader2 className="h-4 w-4 animate-spin text-gray-400"/>
                </div>)}
            </div>
            
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="postalCode">Code postal *</Label>
                <Input id="postalCode" type="text" value={postalCode} onChange={function (e) { return setPostalCode(e.target.value); }} placeholder="75001" className="mt-1"/>
              </div>
              <div>
                <Label htmlFor="city">Ville *</Label>
                <Input id="city" type="text" value={city} onChange={function (e) { return setCity(e.target.value); }} placeholder="Paris" className="mt-1"/>
              </div>
            </div>
          </div>

          {/* Section Durée de location */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 flex items-center">
              <CalendarIcon className="h-5 w-5 mr-2 text-red-600"/>
              Durée de location
            </h3>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {/* Date de début */}
              <div>
                <Label>Date de début de location *</Label>
                <Popover open={isCalendarOpen} onOpenChange={setIsCalendarOpen}>
                  <PopoverTrigger asChild>
                    <Button variant="outline" className={cn("w-full justify-start text-left font-normal mt-1", !startDate && "text-muted-foreground")}>
                      <CalendarIcon className="mr-2 h-4 w-4"/>
                      {startDate ? format(startDate, "PPP", { locale: fr }) : "Sélectionner une date"}
                    </Button>
                  </PopoverTrigger>
                  <PopoverContent className="w-auto p-0" align="start">
                    <Calendar mode="single" selected={startDate} onSelect={function (date) {
            setStartDate(date);
            setIsCalendarOpen(false);
        }} disabled={function (date) { return date < new Date(); }} initialFocus/>
                  </PopoverContent>
                </Popover>
              </div>

              {/* Durée en jours */}
              <div>
                <Label htmlFor="duration">Durée (jours) *</Label>
                <Select value={durationDays.toString()} onValueChange={function (value) { return setDurationDays(parseInt(value)); }}>
                  <SelectTrigger className="mt-1">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="1">1 jour</SelectItem>
                    <SelectItem value="3">3 jours</SelectItem>
                    <SelectItem value="7">1 semaine (7 jours)</SelectItem>
                    <SelectItem value="14">2 semaines (14 jours)</SelectItem>
                    <SelectItem value="21">3 semaines (21 jours)</SelectItem>
                    <SelectItem value="30">1 mois (30 jours)</SelectItem>
                    <SelectItem value="60">2 mois (60 jours)</SelectItem>
                    <SelectItem value="90">3 mois (90 jours)</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>

            {/* Résumé des dates */}
            {startDate && endDate && (<div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
                <div className="flex items-center text-sm text-blue-800">
                  <CalendarIcon className="h-4 w-4 mr-2"/>
                  <span className="font-medium">Période de location :</span>
                </div>
                <div className="mt-2 text-sm text-blue-700">
                  <div><strong>Début :</strong> {format(startDate, "EEEE d MMMM yyyy", { locale: fr })}</div>
                  <div><strong>Fin :</strong> {format(endDate, "EEEE d MMMM yyyy", { locale: fr })}</div>
                  <div><strong>Durée :</strong> {durationDays} jour{durationDays > 1 ? 's' : ''}</div>
                </div>
                <div className="mt-2 text-xs text-blue-600">
                  📋 La livraison sera programmée le {format(startDate, "d MMMM yyyy", { locale: fr })} sauf en cas d'indisponibilité
                </div>
              </div>)}
          </div>

          {/* Distance et erreurs */}
          {isCalculatingDistance && (<div className="mt-4 flex items-center text-sm text-gray-600">
              <Loader2 className="h-4 w-4 animate-spin mr-2"/>
              Calcul de la distance en cours...
            </div>)}
          
          {distanceError && (<Alert variant="destructive" className="mt-4">
              <AlertTriangle className="h-4 w-4"/>
              <AlertDescription>{distanceError}</AlertDescription>
            </Alert>)}
          
          {distance > 0 && !isCalculatingDistance && (<div className="mt-4 p-3 bg-green-50 border border-green-200 rounded-lg">
              <p className="text-sm text-green-800">
                Distance calculée : {distance.toFixed(1)} km (aller-retour : {(distance * 2).toFixed(1)} km)
              </p>
            </div>)}
        </div>
      </div>

      {/* Right Column - Price Summary */}
      <div className="lg:col-span-1">
        <Card className="sticky top-4 shadow-lg border-red-100">
          <CardContent className="p-6">
            <h3 className="text-xl font-semibold text-gray-900 mb-4">Devis instantané</h3>
            
            {priceCalculation.total > 0 ? (<div className="space-y-3">
                {priceCalculation.details.map(function (item, index) {
                var isTotal = item.label === "Total TTC";
                var isSubItem = item.isSubItem;
                return (<div key={index} className={"flex justify-between text-sm ".concat(isSubItem ? "ml-4 text-xs text-gray-500" : "")}>
                      <span className={isTotal ? "font-medium" :
                        isSubItem ? "text-gray-500" : "text-gray-600"}>
                        {item.label}
                      </span>
                      <span className={isTotal ? "font-medium" :
                        isSubItem ? "text-gray-500" : ""}>
                        {item.amount.toFixed(2)}€
                      </span>
                    </div>);
            })}
                
                {/* Affichage spécial du tonnage si disponible */}
                {(priceData === null || priceData === void 0 ? void 0 : priceData.maxTonnage) > 0 && (<div className="mt-2 p-2 bg-blue-50 border border-blue-200 rounded text-xs">
                    <div className="flex justify-between">
                      <span className="text-blue-800">Capacité / prix de traitement:</span>
                      <span className="text-blue-800 font-medium">{priceData.maxTonnage} tonnes</span>
                    </div>
                  </div>)}
                
                <hr className="border-gray-200"/>
                <div className="flex justify-between text-xl font-bold text-red-600">
                  <span>Total TTC</span>
                  <span>{priceCalculation.total.toFixed(2)}€</span>
                </div>
                
                {/* Mentions légales TVA */}
                <div className="text-xs text-gray-500 mt-2 space-y-1">
                  <p>• Prix TTC (TVA 20% incluse)</p>
                  <p>• Facture émise après prestation</p>
                  <p>• Conforme aux réglementations environnementales</p>
                </div>
                
                <Button className="w-full mt-4 bg-red-600 hover:bg-red-700 text-white" onClick={handleBooking} disabled={!selectedServiceId || !selectedWasteType || !deliveryAddress || !postalCode || !city || !startDate || !endDate}>
                  Réserver maintenant
                </Button>
              </div>) : (<div className="text-center text-gray-500 py-8">
                <Truck className="h-12 w-12 mx-auto mb-3 text-gray-300"/>
                <p>Sélectionnez une benne pour voir le prix</p>
              </div>)}
          </CardContent>
        </Card>
      </div>
    </div>);
}
