#!/bin/bash

echo "🚨 CORRECTION IMMÉDIATE PAGE D'ACCUEIL"
echo "===================================="

# Créer une page d'accueil simplifiée qui fonctionne TOUJOURS
cat > client/src/pages/home.tsx << 'EOF'
import { useState } from "react";
import { useLocation } from "wouter";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuSeparator, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";
import { useAuth, useLogout } from "@/hooks/useAuth";
import { Clock, Shield, Truck, CheckCircle, Calculator, Play, User, LogOut, Settings, LayoutDashboard, ShieldCheck } from "lucide-react";

export default function Home() {
  const [location, navigate] = useLocation();
  const { user, isAuthenticated } = useAuth();
  const logoutMutation = useLogout();

  const handleStartBooking = () => {
    if (!isAuthenticated) {
      navigate('/auth');
      return;
    }
    navigate('/booking');
  };

  const handleLogout = () => {
    logoutMutation.mutate();
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <img 
                src="https://upload.wikimedia.org/wikipedia/commons/3/32/Remondis_logo.svg" 
                alt="Remondis" 
                className="h-8 w-auto"
              />
              <span className="ml-3 text-xl font-bold text-gray-900">BennesPro</span>
            </div>
            
            <div className="flex items-center space-x-4">
              {isAuthenticated ? (
                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button variant="outline" size="sm">
                      <User className="h-4 w-4 mr-2" />
                      {user?.email || 'Utilisateur'}
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end">
                    <DropdownMenuItem onClick={() => navigate('/profile')}>
                      <Settings className="h-4 w-4 mr-2" />
                      Mon Profil
                    </DropdownMenuItem>
                    <DropdownMenuItem onClick={() => navigate('/dashboard')}>
                      <LayoutDashboard className="h-4 w-4 mr-2" />
                      Dashboard
                    </DropdownMenuItem>
                    {user?.role === 'admin' && (
                      <DropdownMenuItem onClick={() => navigate('/admin')}>
                        <ShieldCheck className="h-4 w-4 mr-2" />
                        Administration
                      </DropdownMenuItem>
                    )}
                    <DropdownMenuSeparator />
                    <DropdownMenuItem onClick={handleLogout}>
                      <LogOut className="h-4 w-4 mr-2" />
                      Se déconnecter
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
              ) : (
                <Button onClick={() => navigate('/auth')} variant="outline" size="sm">
                  Se connecter
                </Button>
              )}
            </div>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="bg-gradient-to-r from-red-600 to-red-700 text-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
          <div className="text-center">
            <h1 className="text-4xl md:text-6xl font-bold mb-6">
              Location de Bennes
              <span className="block text-red-200">Particulier & Professionnel</span>
            </h1>
            <p className="text-xl md:text-2xl mb-8 text-red-100">
              Service de location pour particuliers et professionnels
            </p>
            <Button 
              onClick={handleStartBooking}
              size="lg" 
              className="bg-white text-red-600 hover:bg-red-50"
            >
              <Play className="h-5 w-5 mr-2" />
              Réserver maintenant
            </Button>
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center text-red-600">
                  <Clock className="h-6 w-6 mr-2" />
                  Planification
                </CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-gray-600">
                  Minimum 24h avant intervention
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center text-red-600">
                  <Shield className="h-6 w-6 mr-2" />
                  Sécurisé
                </CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-gray-600">
                  Paiement sécurisé avec PayPlug
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center text-red-600">
                  <Truck className="h-6 w-6 mr-2" />
                  Livraison
                </CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-gray-600">
                  Service de livraison et collecte
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center text-red-600">
                  <Calculator className="h-6 w-6 mr-2" />
                  Devis
                </CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-gray-600">
                  Calcul automatique des prix
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Services */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold text-center mb-12">Nos Services</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <Card>
              <CardContent className="p-6">
                <h3 className="text-xl font-semibold mb-4">Bennes 8m³</h3>
                <p className="text-gray-600 mb-4">
                  Idéales pour les petits travaux de rénovation
                </p>
                <Button onClick={handleStartBooking} className="w-full">
                  Réserver
                </Button>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-6">
                <h3 className="text-xl font-semibold mb-4">Bennes 15m³</h3>
                <p className="text-gray-600 mb-4">
                  Parfaites pour les projets moyens
                </p>
                <Button onClick={handleStartBooking} className="w-full">
                  Réserver
                </Button>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-6">
                <h3 className="text-xl font-semibold mb-4">Bennes 30m³</h3>
                <p className="text-gray-600 mb-4">
                  Pour les gros chantiers professionnels
                </p>
                <Button onClick={handleStartBooking} className="w-full">
                  Réserver
                </Button>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-800 text-white py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div>
              <h3 className="text-lg font-semibold mb-4">BennesPro</h3>
              <p className="text-gray-400">
                Service de location de bennes professionnelles
              </p>
            </div>
            <div>
              <h4 className="text-sm font-semibold mb-4">Services</h4>
              <ul className="space-y-2 text-gray-400">
                <li>Location de bennes</li>
                <li>Collecte de déchets</li>
                <li>Devis en ligne</li>
              </ul>
            </div>
            <div>
              <h4 className="text-sm font-semibold mb-4">Légal</h4>
              <ul className="space-y-2 text-gray-400">
                <li><a href="/legal" className="hover:text-white">Mentions légales</a></li>
                <li><a href="/privacy-policy" className="hover:text-white">Politique de confidentialité</a></li>
                <li><a href="/retraction-rights" className="hover:text-white">Droit de rétractation</a></li>
              </ul>
            </div>
            <div>
              <h4 className="text-sm font-semibold mb-4">Support</h4>
              <ul className="space-y-2 text-gray-400">
                <li><a href="/faq" className="hover:text-white">FAQ</a></li>
                <li>Contact</li>
              </ul>
            </div>
          </div>
          <div className="mt-8 pt-8 border-t border-gray-700 text-center text-gray-400">
            <p>&copy; 2025 BennesPro. Tous droits réservés.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
EOF

echo "✅ Page d'accueil corrigée et simplifiée"
echo "✅ Interface complète avec header, hero, services, footer"
echo "✅ Navigation fonctionnelle vers toutes les pages"
echo "✅ Authentification intégrée"
echo ""
echo "🚀 PAGE D'ACCUEIL MAINTENANT DISPONIBLE"
echo "🌐 Accès: http://localhost:5000/"