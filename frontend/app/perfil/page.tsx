"use client";

import { useEffect, useState } from "react";
import { useAuth } from "@/hooks/useAuth";
import { getUserData } from "@/lib/api";
import { User } from "@/types";

export default function ProfilePage() {
  const { authData } = useAuth();

  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    if (!authData.usuId) return;

    async function fetchUser() {
      const res = await getUserData(authData.usuId ?? undefined);
      if (res.success) setUser(res.data);
    }

    fetchUser();
  }, [authData.usuId]);

  if (!user) return <div>Carregando...</div>;

  return (
    <div>
      <h1>Perfil do Usuário</h1>
      <p>Nome: {user.NOME}</p>
      <p>Email: {user.EMAIL}</p>
      <p>Telefone: {user.TELEFONE}</p>
      <p>CPF: {user.CPF}</p>
      <p>Data de nascimento: {user.DATA_NASCIMENTO}</p>
      <p>Ativo: {user.ATIVO ? "Sim" : "Não"}</p>
    </div>
  );
}
