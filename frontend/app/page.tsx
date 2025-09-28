import { Navbar } from "@/components/navbar";
import { HeroSection } from "@/components/dashboard/sections/hero-section";
import { AboutSection } from "@/components/dashboard/sections/about-section";
import { CTASection } from "@/components/dashboard/sections/cta-section";

export default function Home() {
  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      <main>
        {/* <HeroSection /> */}
        <AboutSection />
        <CTASection />
      </main>
    </div>
  );
}
