import { Button } from "@/components/ui/button";

export function CTASection() {
  return (
    <section className="bg-primary py-20">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h2 className="text-3xl md:text-4xl font-bold text-primary-foreground mb-6">
          Pronto para renovar seu guarda-roupa?
        </h2>
        <p className="text-xl text-primary-foreground/90 mb-8 max-w-2xl mx-auto">
          Explore nossa coleção completa e encontre as peças perfeitas para o
          seu estilo
        </p>
        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Button size="lg" variant="secondary" className="text-lg px-8">
            Ver Todos os Produtos
          </Button>
          <Button
            size="lg"
            variant="outline"
            className="text-lg px-8 border-primary-foreground text-primary-foreground hover:bg-primary-foreground hover:text-primary bg-transparent"
          >
            Fale Conosco
          </Button>
        </div>
      </div>
    </section>
  );
}
