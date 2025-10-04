import type { Product } from "@/lib/(shop)/types";

export const products: Product[] = [
  {
    id: "camisa",
    name: "Camisa Personalizada",
    price: 89.9,
    description: "Crie sua camisa única com design personalizado",
    image: "/white-t-shirt-mockup.jpg",
    sizes: ["P", "M", "G", "GG"],
    sizeChart: [
      { size: "P", width: "48cm", length: "68cm" },
      { size: "M", width: "52cm", length: "72cm" },
      { size: "G", width: "56cm", length: "76cm" },
      { size: "GG", width: "60cm", length: "80cm" },
    ],
  },
  {
    id: "banner",
    name: "Banner Personalizado",
    pricePerM2: 120.0,
    description: "Banner de alta qualidade para seu evento",
    image: "/banner-mockup-display.jpg",
    sizes: [],
    sizeChart: [],
  },
];

export function getProductById(id: string): Product | undefined {
  return products.find((product) => product.id === id);
}
