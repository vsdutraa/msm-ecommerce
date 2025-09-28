"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useAuth } from "@/hooks/useAuth";
import { toast } from "sonner";

interface LoginFormProps extends React.ComponentProps<"form"> {}

export function LoginForm({ className, ...props }: LoginFormProps) {
  const router = useRouter();

  const { login, loading } = useAuth();

  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const ok = await login({ email, senha });
    if (ok) {
      toast("Você entrou na sua conta com sucesso!");
      router.push("/perfil");
    } else {
      toast("Verifique seu e-mail e senha e tente novamente.");
    }
  };

  return (
    <div className={cn("max-w-sm mx-auto p-6", className)}>
      <form className="flex flex-col gap-6" onSubmit={handleSubmit} {...props}>
        <div className="flex flex-col items-center gap-2 text-center">
          <h1 className="text-2xl font-bold">Acesse sua conta</h1>
          <p className="text-sm text-muted-foreground">
            Informe seu e-mail e senha para entrar no sistema
          </p>
        </div>

        <div className="grid gap-6">
          <div className="grid gap-3">
            <Label htmlFor="email">E-mail</Label>
            <Input
              id="email"
              type="email"
              placeholder="exemplo@dominio.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>

          <div className="grid gap-3">
            <Label htmlFor="password">Senha</Label>
            <Input
              id="password"
              type="password"
              placeholder="Sua senha"
              value={senha}
              onChange={(e) => setSenha(e.target.value)}
              required
            />
          </div>

          <Button type="submit" className="w-full" disabled={loading}>
            {loading ? "Entrando..." : "Entrar"}
          </Button>
        </div>

        <div className="text-center text-sm">
          Não tem uma conta?{" "}
          <a href="/register" className="underline underline-offset-4">
            Crie sua conta
          </a>
        </div>
      </form>
    </div>
  );
}
