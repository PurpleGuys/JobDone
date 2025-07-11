var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
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
import { useState } from "react";
import { apiRequest } from "@/lib/queryClient";
export function useBookingState() {
    var _this = this;
    var _a = useState(1), currentStep = _a[0], setCurrentStep = _a[1];
    var _b = useState(null), priceData = _b[0], setPriceData = _b[1];
    var _c = useState({
        service: null,
        durationDays: 1,
        wasteTypes: [],
        address: null,
        deliveryTimeSlot: null,
        pickupTimeSlot: null,
        customer: null,
        paymentMethod: "stripe",
    }), bookingData = _c[0], setBookingData = _c[1];
    var updateService = function (service) {
        setBookingData(function (prev) { return (__assign(__assign({}, prev), { service: service })); });
    };
    var updateDuration = function (days) {
        setBookingData(function (prev) { return (__assign(__assign({}, prev), { durationDays: days })); });
    };
    var updateWasteTypes = function (wasteTypes) {
        setBookingData(function (prev) { return (__assign(__assign({}, prev), { wasteTypes: wasteTypes })); });
    };
    var updateAddress = function (address) {
        setBookingData(function (prev) { return (__assign(__assign({}, prev), { address: address })); });
    };
    var updateTimeSlots = function (deliveryTimeSlot, pickupTimeSlot) {
        setBookingData(function (prev) { return (__assign(__assign({}, prev), { deliveryTimeSlot: deliveryTimeSlot, pickupTimeSlot: pickupTimeSlot || null })); });
    };
    var updateCustomer = function (customer) {
        setBookingData(function (prev) { return (__assign(__assign({}, prev), { customer: customer })); });
    };
    var updatePaymentMethod = function (method) {
        setBookingData(function (prev) { return (__assign(__assign({}, prev), { paymentMethod: method })); });
    };
    // Fonction pour déclencher le calcul de prix via l'API
    var calculatePrice = function () { return __awaiter(_this, void 0, void 0, function () {
        var response, error_1;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    if (!bookingData.service || !bookingData.address) {
                        return [2 /*return*/];
                    }
                    _a.label = 1;
                case 1:
                    _a.trys.push([1, 3, , 4]);
                    return [4 /*yield*/, apiRequest("POST", "/api/calculate-pricing", {
                            serviceId: bookingData.service.id,
                            customerAddress: "".concat(bookingData.address.street, ", ").concat(bookingData.address.postalCode, " ").concat(bookingData.address.city),
                            wasteTypes: bookingData.wasteTypes,
                            durationDays: bookingData.durationDays
                        })];
                case 2:
                    response = _a.sent();
                    setPriceData(response);
                    return [3 /*break*/, 4];
                case 3:
                    error_1 = _a.sent();
                    console.error("Erreur calcul prix:", error_1);
                    return [3 /*break*/, 4];
                case 4: return [2 /*return*/];
            }
        });
    }); };
    // Fonction pour obtenir les prix calculés
    var calculateTotalPrice = function () {
        var _a;
        if (!priceData) {
            return {
                basePrice: 0,
                durationPrice: 0,
                deliveryFee: 0,
                transportCost: 0,
                treatmentCosts: {},
                totalTreatmentCost: 0,
                maxTonnage: 0,
                totalHT: 0,
                vat: 0,
                totalTTC: 0,
            };
        }
        var basePrice = parseFloat(((_a = bookingData.service) === null || _a === void 0 ? void 0 : _a.basePrice) || '0');
        var transportCost = priceData.transportCost || 0;
        var totalTreatmentCost = priceData.totalTreatmentCost || 0;
        var totalHT = basePrice + transportCost + totalTreatmentCost;
        var vat = totalHT * 0.2;
        var totalTTC = totalHT + vat;
        return {
            basePrice: basePrice,
            durationPrice: 0,
            deliveryFee: 0,
            transportCost: transportCost,
            treatmentCosts: priceData.treatmentCosts || {},
            totalTreatmentCost: totalTreatmentCost,
            maxTonnage: priceData.maxTonnage || 0,
            totalHT: totalHT,
            vat: vat,
            totalTTC: totalTTC,
        };
    };
    var resetBooking = function () {
        setCurrentStep(1);
        setPriceData(null);
        setBookingData({
            service: null,
            durationDays: 1,
            wasteTypes: [],
            address: null,
            deliveryTimeSlot: null,
            pickupTimeSlot: null,
            customer: null,
            paymentMethod: "stripe",
        });
    };
    return {
        currentStep: currentStep,
        setCurrentStep: setCurrentStep,
        bookingData: bookingData,
        priceData: priceData,
        updateService: updateService,
        updateDuration: updateDuration,
        updateWasteTypes: updateWasteTypes,
        updateAddress: updateAddress,
        updateTimeSlots: updateTimeSlots,
        updateCustomer: updateCustomer,
        updatePaymentMethod: updatePaymentMethod,
        calculatePrice: calculatePrice,
        calculateTotalPrice: calculateTotalPrice,
        resetBooking: resetBooking,
    };
}
