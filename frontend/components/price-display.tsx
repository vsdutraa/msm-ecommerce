import type { Product } from "@/lib/(shop)/types";
import { isShirt, isBanner } from "@/lib/(shop)/types";
import { formatCurrency } from "@/lib/(shop)/utils/format";

type PriceDisplayProps = {
  product: Product;
  totalPrice?: number;
};

export function PriceDisplay({ product, totalPrice }: PriceDisplayProps) {
  if (isBanner(product)) {
    return (
      <div>
        <p className="text-xl ">{formatCurrency(product.pricePerM2)}/m²</p>
        {totalPrice !== undefined && totalPrice > 0 && (
          <p className="mt-2 text-3xl font-bold">
            Total: {formatCurrency(totalPrice)}
          </p>
        )}
      </div>
    );
  }

  if (isShirt(product)) {
    return (
      <p className="text-3xl font-bold ">{formatCurrency(product.price)}</p>
    );
  }

  return null;
}
