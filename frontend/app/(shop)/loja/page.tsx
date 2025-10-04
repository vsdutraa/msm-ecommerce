import { ProductCard } from "@/components/product-card";
import { products } from "@/lib/(shop)/products";

export default function StorePage() {
  return (
    <div className="min-h-screen bg-background">
      <main className="container mx-auto px-4 py-12">
        <div className="mb-12 text-center">
          <h1 className="mb-4 text-4xl font-bold tracking-tight text-balance md:text-5xl">
            Produtos Personalizados
          </h1>
          <p className="mx-auto max-w-2xl text-lg text-muted-foreground text-pretty">
            Crie produtos únicos com seus próprios designs. Qualidade premium e
            entrega rápida.
          </p>
        </div>

        <div className="grid gap-8 sm:grid-cols-4 lg:gap-12">
          {products.map((product) => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>
      </main>
    </div>
  );
}
