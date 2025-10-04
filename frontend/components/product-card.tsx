import Link from "next/link";
import { Card, CardContent } from "@/components/ui/card";
import type { Product } from "@/lib/(shop)/types";
import { isShirt, isBanner } from "@/lib/(shop)/types";
import { formatCurrency } from "@/lib/(shop)/utils/format";

type ProductCardProps = {
  product: Product;
};

export function ProductCard({ product }: ProductCardProps) {
  return (
    <Link href={`/produto/${product.id}`}>
      <Card className="overflow-hidden transition-shadow hover:shadow-lg cursor-pointer">
        <CardContent className="p-0">
          <div className="aspect-square overflow-hidden ">
            <img
              src={product.image || "/placeholder.svg"}
              alt={product.name}
              className="h-full w-full object-cover transition-transform hover:scale-105"
            />
          </div>

          <div className="p-6">
            <h2 className="mb-2 text-2xl font-semibold tracking-tight">
              {product.name}
            </h2>
            {product.description && (
              <p className="mb-4 text-muted-foreground">
                {product.description}
              </p>
            )}
            <p className="text-3xl font-bold">
              {isShirt(product) && formatCurrency(product.price)}
              {isBanner(product) && (
                <>
                  {formatCurrency(product.pricePerM2)}
                  <span className="text-lg font-normal text-muted-foreground">
                    /m²
                  </span>
                </>
              )}
            </p>
          </div>
        </CardContent>
      </Card>
    </Link>
  );
}
