export interface User {
  ID?: number;
  NOME?: string;
  EMAIL: string;
  SENHA: string;
  CPF?: string;
  TELEFONE?: string;
  DATA_NASCIMENTO?: string;
  ENDERECO?: string;
  CIDADE?: string;
  ESTADO?: string;
  CEP?: string;
  DATA_CADASTRO?: string;
  ATIVO?: boolean;
}

export interface LoginCredentials {
  email: string;
  senha: string;
}

export interface RegisterData {
  nome?: string;
  email: string;
  senha: string;
  cpf?: string;
  telefone?: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
}

export interface FormErrors {
  [key: string]: string;
}
