import { Button } from "@/components/ui/button";

export function HeroSection() {
  return (
    <section className="bg-background py-20">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h1 className="text-4xl md:text-6xl font-bold text-foreground mb-6 text-balance">
          MalhaSantaMaria
        </h1>
        <p className="text-xl text-muted-foreground mb-8 max-w-2xl mx-auto text-pretty">
          Descubra nossa coleção exclusiva de roupas com qualidade e estilo
          únicos
        </p>
        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Button size="lg" className="text-lg px-8">
            Ver Coleção
          </Button>
          <Button
            variant="outline"
            size="lg"
            className="text-lg px-8 bg-transparent"
          >
            Sobre Nós
          </Button>
        </div>
      </div>
    </section>
  );
}
