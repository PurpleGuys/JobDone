import React from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { LoginUser, InsertUser, User, ChangePassword, UpdateUser } from "@shared/schema";

export function useAuth() {
  const [user, setUser] = React.useState<User | undefined>(undefined);
  const [isAuthenticated, setIsAuthenticated] = React.useState(false);
  
  React.useEffect(() => {
    const checkAuth = async () => {
      try {
        const token = localStorage.getItem("auth_token");
        if (!token) {
          setIsAuthenticated(false);
          setUser(undefined);
          return;
        }

        const response = await fetch("/api/auth/me", {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });

        if (response.ok) {
          const userData = await response.json();
          setUser(userData);
          setIsAuthenticated(true);
        } else {
          localStorage.removeItem("auth_token");
          localStorage.removeItem("session_token");
          setIsAuthenticated(false);
          setUser(undefined);
        }
      } catch (error) {
        console.warn("Auth check failed:", error);
        setIsAuthenticated(false);
        setUser(undefined);
      }
    };

    checkAuth();
  }, []);

  return {
    user,
    isLoading: false, // TOUJOURS false - jamais de blocage
    isAuthenticated,
    error: null,
  };
}

export function useLogin() {
  const queryClient = useQueryClient();
  const { toast } = useToast();

  return useMutation({
    mutationFn: async (data: LoginUser) => {
      const response = await apiRequest("/api/auth/login", "POST", data);
      return response;
    },
    onSuccess: (data) => {
      if (data.token) {
        localStorage.setItem("auth_token", data.token);
      }
      if (data.sessionToken) {
        localStorage.setItem("session_token", data.sessionToken);
      }
      
      queryClient.invalidateQueries({ queryKey: ["/api/auth/me"] });
      
      toast({
        title: "Connexion réussie",
        description: data.message || "Bienvenue !",
      });
    },
    onError: (error: any) => {
      toast({
        title: "Erreur de connexion",
        description: error.message || "Échec de la connexion",
        variant: "destructive",
      });
    },
  });
}

export function useRegister() {
  const { toast } = useToast();

  return useMutation({
    mutationFn: async (data: InsertUser) => {
      const response = await apiRequest("/api/auth/register", "POST", data);
      return response;
    },
    onSuccess: (data) => {
      toast({
        title: "Inscription réussie",
        description: data.message || "Votre compte a été créé avec succès",
      });
    },
    onError: (error: any) => {
      toast({
        title: "Erreur d'inscription",
        description: error.message || "Échec de la création du compte",
        variant: "destructive",
      });
    },
  });
}

export function useLogout() {
  const queryClient = useQueryClient();
  const { toast } = useToast();

  return useMutation({
    mutationFn: async () => {
      const sessionToken = localStorage.getItem("session_token");
      const headers: Record<string, string> = {};
      
      if (sessionToken) {
        headers["x-session-token"] = sessionToken;
      }
      
      const response = await apiRequest("/api/auth/logout", "POST", {});
      return response;
    },
    onSuccess: () => {
      localStorage.removeItem("auth_token");
      localStorage.removeItem("session_token");
      queryClient.clear();
      
      toast({
        title: "Déconnexion réussie",
        description: "À bientôt !",
      });
    },
    onError: (error: any) => {
      localStorage.removeItem("auth_token");
      localStorage.removeItem("session_token");
      queryClient.clear();
      
      toast({
        title: "Déconnexion",
        description: "Vous avez été déconnecté",
      });
    },
  });
}

export function useUpdateProfile() {
  const queryClient = useQueryClient();
  const { toast } = useToast();

  return useMutation({
    mutationFn: async (data: UpdateUser) => {
      const response = await apiRequest("/api/auth/profile", "PATCH", data);
      return response;
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["/api/auth/me"] });
      
      toast({
        title: "Profil mis à jour",
        description: data.message || "Votre profil a été mis à jour avec succès",
      });
    },
    onError: (error: any) => {
      toast({
        title: "Erreur de mise à jour",
        description: error.message || "Échec de la mise à jour du profil",
        variant: "destructive",
      });
    },
  });
}

export function useChangePassword() {
  const { toast } = useToast();

  return useMutation({
    mutationFn: async (data: ChangePassword) => {
      const response = await apiRequest("/api/auth/change-password", "POST", data);
      return response;
    },
    onSuccess: (data) => {
      toast({
        title: "Mot de passe modifié",
        description: data.message || "Votre mot de passe a été modifié avec succès",
      });
    },
    onError: (error: any) => {
      toast({
        title: "Erreur de modification",
        description: error.message || "Échec de la modification du mot de passe",
        variant: "destructive",
      });
    },
  });
}