"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { registerUser } from "@/lib/api";
import { toast } from "sonner";

interface RegisterFormProps extends React.ComponentProps<"form"> {}

export function RegisterForm({ className, ...props }: RegisterFormProps) {
  const router = useRouter();

  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    const res = await registerUser({
      email,
      senha,
    });

    setLoading(false);

    if (res.success) {
      toast("Conta criada com sucesso!");
      router.push("/login");
    } else {
      toast("Erro ao criar a conta");
      console.log(res.error);
    }
  };

  return (
    <div className={cn("max-w-sm mx-auto p-6", className)}>
      <form className="flex flex-col gap-6" onSubmit={handleSubmit} {...props}>
        <div className="flex flex-col items-center gap-2 text-center">
          <h1 className="text-2xl font-bold">Crie sua conta</h1>
          <p className="text-sm text-muted-foreground">
            Preencha os campos abaixo para se registrar no sistema
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
            {loading ? "Registrando..." : "Registrar"}
          </Button>
        </div>

        <div className="text-center text-sm">
          Já tem uma conta?{" "}
          <a href="/login" className="underline underline-offset-4">
            Faça login
          </a>
        </div>
      </form>
    </div>
  );
}
