export function formatCardNumber(value: string): string {
  const numbersOnly = value.replace(/\D/g, "");
  const formatted = numbersOnly.replace(/(\d{4})(?=\d)/g, "$1 ");
  return formatted.slice(0, 19);
}

export function formatExpirationDate(value: string): string {
  const numbersOnly = value.replace(/\D/g, "");
  if (numbersOnly.length >= 2) {
    return numbersOnly.slice(0, 2) + "/" + numbersOnly.slice(2, 4);
  }
  return numbersOnly;
}

export function formatCurrency(value: number): string {
  return `R$ ${value.toFixed(2)}`;
}

export function calculateBannerPrice(
  widthCm: number,
  heightCm: number,
  pricePerM2: number
): number {
  const widthInMeters = widthCm / 100;
  const heightInMeters = heightCm / 100;
  const area = widthInMeters * heightInMeters;
  return area * pricePerM2;
}
