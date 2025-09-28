"use client";

import { useState, useEffect, useCallback } from "react";
import * as api from "@/lib/api";

interface LoginCredentials {
  email: string;
  senha: string;
}

interface AuthData {
  token: string | null;
  usuId: string | null;
}

export function useAuth() {
  const [loading, setLoading] = useState(false);
  const [authData, setAuthData] = useState<AuthData>({
    token: null,
    usuId: null,
  });

  // Inicializa token + usuId do localStorage
  useEffect(() => {
    const stored = localStorage.getItem("authData");
    if (stored) {
      const parsed: AuthData = JSON.parse(stored);
      api.setAuthData(parsed);
      setAuthData(parsed);
    }
  }, []);

  const login = useCallback(async ({ email, senha }: LoginCredentials) => {
    setLoading(true);
    try {
      const result = await api.login({ email, senha });
      if (result.success && result.data) {
        // result.data agora é apenas o token, pegamos usuId do retorno interno do login
        const token = result.data;
        const usuId = api.getAuthUsuId(); // já foi setado dentro do login com setAuthData
        const data: AuthData = { token, usuId };
        localStorage.setItem("authData", JSON.stringify(data));
        setAuthData(data);
        return true;
      } else {
        return false;
      }
    } catch (err) {
      console.error(err);
      return false;
    } finally {
      setLoading(false);
    }
  }, []);

  const logout = useCallback(() => {
    api.logout();
    localStorage.removeItem("authData");
    setAuthData({ token: null, usuId: null });
  }, []);

  const isAuthenticated = !!authData.token;

  return { login, logout, loading, isAuthenticated, authData };
}
