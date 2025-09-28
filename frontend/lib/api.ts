// lib/api.ts
import { LoginCredentials, RegisterData, ApiResponse, User } from "@/types";

const API_BASE_URL = "http://localhost:7033/v1";

let authToken: string | null = null;
let authUsuId: string | null = null;

// setAuthData: define token e UsuID
export function setAuthData(data: {
  token: string | null;
  usuId: string | null;
}) {
  authToken = data.token;
  authUsuId = data.usuId;
}

// getAuthData: retorna token e UsuID
export function getAuthData(): { token: string | null; usuId: string | null } {
  return { token: authToken, usuId: authUsuId };
}

// getters separados se precisar
export function getAuthToken(): string | null {
  return authToken;
}
export function getAuthUsuId(): string | null {
  return authUsuId;
}

// Login: obtém token do backend
export async function login({
  email,
  senha,
}: LoginCredentials): Promise<ApiResponse<string>> {
  try {
    const res = await fetch(`${API_BASE_URL}/GetTokenAccess`, {
      method: "GET",
      headers: {
        "x-login": email,
        "x-password": senha,
        "x-Ambiente": "2FA",
        "x-Versao": "1.0.0",
      },
    });
    const data = await res.json();
    console.log(data);

    if (res.ok && data.token) {
      setAuthData({
        token: data.token,
        usuId: data.retorno[0].outUsuId,
      });
      return { success: true, data: data.token };
    }
    return { success: false, error: data.message || "Erro ao obter token" };
  } catch (err) {
    return { success: false, error: String(err) };
  }
}

// Logout: limpa token
export function logout() {
  setAuthData({ token: null, usuId: null });
}

// Função utilitária para requisições autenticadas
export async function fetchAuth(
  url: string,
  options: RequestInit = {}
): Promise<any> {
  const token = getAuthToken();
  if (!token) throw new Error("Usuário não autenticado");

  const res = await fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      Authorization: `Bearer ${token}`,
    },
  });

  const data = await res.json();
  if (!res.ok) throw new Error(data.message || "Erro na requisição");
  return data;
}

// Exemplo: registrar usuário
export async function registerUser(
  user: RegisterData
): Promise<ApiResponse<User>> {
  try {
    const res = await fetch(`${API_BASE_URL}/PostGravaUsuarios`, {
      method: "POST",
      headers: {
        "x-login": user.email,
        "x-password": user.senha,
        "x-Tipo": "C", // Cliente
      },
    });
    const data = await res.json();
    console.log(data);

    return {
      success: res.ok,
      data: data,
      error: res.ok ? undefined : data.message,
    };
  } catch (err) {
    return { success: false, error: String(err) };
  }
}

export async function getUserData(
  usuId?: string | number
): Promise<ApiResponse<any>> {
  try {
    const token = getAuthToken();
    if (!token) throw new Error("Usuário não autenticado");

    const headers: Record<string, string> = {
      Authorization: `Bearer ${token}`,
    };

    if (usuId !== undefined) {
      headers["x-UsuID"] = String(usuId);
    }

    const res = await fetch(`${API_BASE_URL}/GetUsuarios`, {
      method: "GET",
      headers,
    });

    const data = await res.json();

    return { success: res.ok, data, error: res.ok ? undefined : data.message };
  } catch (err) {
    return { success: false, error: String(err) };
  }
}
