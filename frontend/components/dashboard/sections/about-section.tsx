export function AboutSection() {
  return (
    <section className="bg-background py-20">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          <div>
            <h2 className="text-3xl md:text-4xl font-bold text-foreground mb-6">
              Nossa História
            </h2>
            <p className="text-lg text-muted-foreground mb-6 leading-relaxed">
              Lorem ipsum dolor sit amet, consectetur adipisicing elit.
              Voluptatem natus sequi dolores totam ex labore dicta! Est mollitia
              fugit placeat quam facilis alias amet vitae! Quae excepturi ipsam
              eum ea.
            </p>
            <p className="text-lg text-muted-foreground leading-relaxed">
              Lorem ipsum dolor sit amet consectetur adipisicing elit. Amet quia
              aut dolorum cupiditate, totam repudiandae fugiat tempore! Commodi
              ducimus autem obcaecati dignissimos enim, ad laborum quas repellat
              necessitatibus odio id!
            </p>
          </div>
          <div className="aspect-square overflow-hidden rounded-lg">
            <img
              src="/loja-de-roupas-moderna.jpg"
              alt="Nossa loja"
              className="w-full h-full object-cover"
            />
          </div>
        </div>
      </div>
    </section>
  );
}
