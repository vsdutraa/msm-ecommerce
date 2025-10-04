export type ShirtProduct = {
  id: string;
  name: string;
  price: number;
  image: string;
  description?: string;
  sizes: string[];
  sizeChart: Array<{
    size: string;
    width: string;
    length: string;
  }>;
};

export type BannerProduct = {
  id: string;
  name: string;
  pricePerM2: number;
  image: string;
  description?: string;
  sizes: string[];
  sizeChart: Array<{
    size: string;
    width: string;
    length: string;
  }>;
};

export type Product = ShirtProduct | BannerProduct;

export function isShirt(product: Product): product is ShirtProduct {
  return "price" in product;
}

export function isBanner(product: Product): product is BannerProduct {
  return "pricePerM2" in product;
}
