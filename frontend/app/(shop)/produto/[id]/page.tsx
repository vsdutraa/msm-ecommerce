"use client";

import type React from "react";
import { useState, useEffect } from "react";
import { useParams } from "next/navigation";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { PriceDisplay } from "@/components/price-display";
import { Upload } from "lucide-react";
import { getProductById } from "@/lib/(shop)/products";
import { isShirt, isBanner } from "@/lib/(shop)/types";
import { calculateBannerPrice } from "@/lib/(shop)/utils/format";

export default function ProductPage() {
  const params = useParams();
  const product = getProductById(params.id as string);

  const [selectedSize, setSelectedSize] = useState("");
  const [uploadedImage, setUploadedImage] = useState<File | null>(null);
  const [bannerWidth, setBannerWidth] = useState("");
  const [bannerHeight, setBannerHeight] = useState("");
  const [totalPrice, setTotalPrice] = useState(0);

  useEffect(() => {
    if (!product || !isBanner(product)) return;

    const width = Number.parseFloat(bannerWidth);
    const height = Number.parseFloat(bannerHeight);

    if (width > 0 && height > 0) {
      setTotalPrice(calculateBannerPrice(width, height, product.pricePerM2));
    }
  }, [bannerWidth, bannerHeight, product]);

  useEffect(() => {
    if (product && isShirt(product)) {
      setTotalPrice(product.price);
    }
  }, [product]);

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files?.[0]) {
      setUploadedImage(e.target.files[0]);
    }
  };

  const isFormValid = () => {
    if (!uploadedImage || !product) return false;
    if (isShirt(product)) return !!selectedSize;
    if (isBanner(product)) return !!bannerWidth && !!bannerHeight;
    return false;
  };

  if (!product) {
    return <div>Produto não encontrado</div>;
  }

  return (
    <div className="min-h-screen bg-background">
      <main className="container mx-auto px-4 py-12">
        <div className="grid gap-12 lg:grid-cols-2">
          {/* Product image */}
          <div className="space-y-4">
            <Card className="overflow-hidden">
              <CardContent className="p-0">
                <div className="aspect-square ">
                  <img
                    src={product.image || "/placeholder.svg"}
                    alt={product.name}
                    className="h-full w-full object-cover"
                  />
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Product details and customization */}
          <div className="space-y-8">
            <div>
              <h1 className="mb-4 text-4xl font-bold tracking-tight">
                {product.name}
              </h1>
              <PriceDisplay product={product} totalPrice={totalPrice} />
            </div>

            {/* Image upload */}
            <div className="space-y-3">
              <Label htmlFor="image-upload" className="text-base font-semibold">
                Sua Imagem Personalizada
              </Label>
              <div className="flex items-center gap-4">
                <Input
                  id="image-upload"
                  type="file"
                  accept="image/*"
                  onChange={handleImageChange}
                  className="hidden"
                />
                <Button
                  variant="outline"
                  className="w-full bg-transparent"
                  onClick={() =>
                    document.getElementById("image-upload")?.click()
                  }
                >
                  <Upload className="mr-2 h-4 w-4" />
                  {uploadedImage
                    ? uploadedImage.name
                    : "Fazer upload da imagem"}
                </Button>
              </div>
              <p className="text-sm text-muted-foreground">
                Formatos aceitos: JPG, PNG, SVG (máx. 10MB)
              </p>
            </div>

            {isBanner(product) ? (
              <div className="space-y-4">
                <div className="space-y-3">
                  <Label htmlFor="width" className="text-base font-semibold">
                    Largura (cm)
                  </Label>
                  <Input
                    id="width"
                    type="number"
                    placeholder="Ex: 100"
                    value={bannerWidth}
                    onChange={(e) => setBannerWidth(e.target.value)}
                    min="1"
                  />
                </div>
                <div className="space-y-3">
                  <Label htmlFor="height" className="text-base font-semibold">
                    Altura (cm)
                  </Label>
                  <Input
                    id="height"
                    type="number"
                    placeholder="Ex: 150"
                    value={bannerHeight}
                    onChange={(e) => setBannerHeight(e.target.value)}
                    min="1"
                  />
                </div>
              </div>
            ) : isShirt(product) ? (
              <>
                <div className="space-y-3">
                  <Label htmlFor="size" className="text-base font-semibold">
                    Selecione o Tamanho
                  </Label>
                  <Select value={selectedSize} onValueChange={setSelectedSize}>
                    <SelectTrigger id="size">
                      <SelectValue placeholder="Escolha um tamanho" />
                    </SelectTrigger>
                    <SelectContent>
                      {product.sizes.map((size) => (
                        <SelectItem key={size} value={size}>
                          {size}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                {/* Size chart */}
                {product.sizeChart.length > 0 && (
                  <div className="space-y-3">
                    <h3 className="text-base font-semibold">
                      Tabela de Tamanhos
                    </h3>
                    <Card>
                      <CardContent className="p-0">
                        <Table>
                          <TableHeader>
                            <TableRow>
                              <TableHead className="pl-4">Tamanho</TableHead>
                              <TableHead>Largura</TableHead>
                              <TableHead>Comprimento</TableHead>
                            </TableRow>
                          </TableHeader>
                          <TableBody>
                            {product.sizeChart.map((item) => (
                              <TableRow key={item.size}>
                                <TableCell className="pl-4 font-medium">
                                  {item.size}
                                </TableCell>
                                <TableCell>{item.width}</TableCell>
                                <TableCell>{item.length}</TableCell>
                              </TableRow>
                            ))}
                          </TableBody>
                        </Table>
                      </CardContent>
                    </Card>
                  </div>
                )}
              </>
            ) : null}

            {/* Add to cart button */}
            <Button
              size="lg"
              className="w-full bg-accent text-accent-foreground hover:bg-accent/90"
              disabled={!isFormValid()}
            >
              Adicionar ao Carrinho
            </Button>
          </div>
        </div>
      </main>
    </div>
  );
}
