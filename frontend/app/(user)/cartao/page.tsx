"use client";

import type React from "react";
import { useState } from "react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { CreditCard } from "lucide-react";
import {
  formatCardNumber,
  formatExpirationDate,
} from "@/lib/(shop)/utils/format";

export default function CardPage() {
  const [cardNumber, setCardNumber] = useState("");
  const [cardholderName, setCardholderName] = useState("");
  const [expirationDate, setExpirationDate] = useState("");
  const [cvv, setCvv] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log("Card saved:", {
      cardNumber,
      cardholderName,
      expirationDate,
      cvv,
    });
    alert("Cartão salvo com sucesso!");
  };

  return (
    <div className="min-h-screen bg-background">
      <main className="container mx-auto px-4 py-12">
        <div className="mx-auto max-w-2xl">
          <div className="mb-8 text-center">
            <h1 className="mb-4 text-4xl font-bold tracking-tight">
              Adicionar Cartão
            </h1>
            <p className="text-lg text-muted-foreground">
              Salve seus dados de pagamento de forma segura
            </p>
          </div>

          <Card className="overflow-hidden">
            <CardHeader>
              <div className="flex items-center gap-3">
                <div className="flex h-12 w-12 items-center justify-center rounded-full bg-accent">
                  <CreditCard className="h-6 w-6 text-accent-foreground" />
                </div>
                <div>
                  <CardTitle>Informações do Cartão</CardTitle>
                  <CardDescription>
                    Seus dados estão protegidos e criptografados
                  </CardDescription>
                </div>
              </div>
            </CardHeader>

            <CardContent className="p-6">
              <form onSubmit={handleSubmit} className="space-y-6">
                {/* Card number */}
                <div className="space-y-2">
                  <Label htmlFor="card-number">Número do Cartão</Label>
                  <Input
                    id="card-number"
                    placeholder="1234 5678 9012 3456"
                    value={cardNumber}
                    onChange={(e) =>
                      setCardNumber(formatCardNumber(e.target.value))
                    }
                    maxLength={19}
                    required
                  />
                </div>

                {/* Cardholder name */}
                <div className="space-y-2">
                  <Label htmlFor="cardholder-name">Nome do Titular</Label>
                  <Input
                    id="cardholder-name"
                    placeholder="NOME COMO ESTÁ NO CARTÃO"
                    value={cardholderName}
                    onChange={(e) =>
                      setCardholderName(e.target.value.toUpperCase())
                    }
                    required
                  />
                </div>

                {/* Expiration date and CVV */}
                <div className="grid gap-4 sm:grid-cols-2">
                  <div className="space-y-2">
                    <Label htmlFor="expiration-date">Data de Validade</Label>
                    <Input
                      id="expiration-date"
                      placeholder="MM/AA"
                      value={expirationDate}
                      onChange={(e) =>
                        setExpirationDate(formatExpirationDate(e.target.value))
                      }
                      maxLength={5}
                      required
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="cvv">CVV</Label>
                    <Input
                      id="cvv"
                      placeholder="123"
                      type="password"
                      value={cvv}
                      onChange={(e) =>
                        setCvv(e.target.value.replace(/\D/g, "").slice(0, 4))
                      }
                      maxLength={4}
                      required
                    />
                  </div>
                </div>

                <p className="text-center text-sm text-muted-foreground">
                  Seus dados são protegidos com criptografia de ponta a ponta
                </p>

                {/* Save button */}
                <Button
                  type="submit"
                  size="lg"
                  className="w-full bg-accent text-accent-foreground hover:bg-accent/90"
                >
                  Salvar Cartão
                </Button>
              </form>
            </CardContent>
          </Card>
        </div>
      </main>
    </div>
  );
}
