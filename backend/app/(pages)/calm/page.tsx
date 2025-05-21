
"use client";

import { ArrowRight, CheckCircle, Download, MessageCircle, Shield, Users } from 'lucide-react';
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { FeatureCard } from '@/components/feature-card';
import { NavBar } from '@/components/navbar';
import { AnimatedSpotlight } from '@/components/animated-spotlight';
import { TeamMember } from '@/components/team';
import { Footer } from '@/components/footer';


const features = [
  {
    icon: <Users className="h-6 w-6" />,
    title: "Patient Matching",
    description: "Smart matching algorithm connects students with suitable patients"
  },
  {
    icon: <MessageCircle className="h-6 w-6" />,
    title: "Secure Messaging",
    description: "End-to-end encrypted communication between students and patients"
  },
  {
    icon: <Shield className="h-6 w-6" />,
    title: "Data Security",
    description: "Blockchain-based security for all personal and medical data"
  }
];

const team = [
  {
    name: "Dr. Andi",
    role: "Lead Dentist",
    image: "/placeholder.svg?height=200&width=200"
  },
  {
    name: "Dr. Budi",
    role: "Dental Specialist",
    image: "/placeholder.svg?height=200&width=200"
  },
  {
    name: "Dr. Citra",
    role: "Orthodontist",
    image: "/placeholder.svg?height=200&width=200"
  }
];

const Index = () => {
  return (
    <div className="min-h-screen bg-white">
      <NavBar />

      {/* Hero Section */}
      <section className="relative overflow-hidden pt-20 md:pt-32 pb-16">
        <AnimatedSpotlight className="left-[40%]" />
        <div className="container px-4 md:px-6">
          <div className="grid gap-12 lg:grid-cols-2">
            <div className="flex flex-col justify-center space-y-8">
              <div className="space-y-4">
                <div className="inline-block rounded-full bg-blue-50 px-3 py-1 text-sm text-blue-800 font-medium">
                  DENTAL PLATFORM
                </div>
                <h1 className="text-4xl font-bold tracking-tight sm:text-5xl md:text-6xl lg:text-5xl xl:text-6xl text-gray-900">
                  DentalMatch
                </h1>
                <p className="text-xl md:text-2xl text-gray-500 max-w-md leading-relaxed">
                  Connecting dental students with patients through blockchain technology
                </p>
              </div>
              <div className="flex flex-col sm:flex-row gap-4">
                <Button size="lg" className="bg-black text-white hover:bg-gray-800">
                  Download App <ArrowRight className="ml-2 h-4 w-4" />
                </Button>
                {/* <Button size="lg" variant="outline" className="border-gray-200 text-gray-800 hover:bg-gray-50">
                  Learn More
                </Button> */}
              </div>
            </div>
            <div className="flex justify-center items-center">
              <div className="relative w-full max-w-md">
                <div className="absolute inset-0 bg-gradient-to-r from-blue-50 to-purple-50 rounded-2xl transform rotate-3"></div>
                <img
                  src="/placeholder.svg?height=600&width=400"
                  alt="DentalMatch App Preview"
                  className="relative z-10 rounded-2xl shadow-lg w-full object-cover"
                />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-16 border-t border-gray-100">
        <div className="container px-4 md:px-6">
          <div className="grid gap-8 md:grid-cols-3">
            <Card className="border-none shadow-sm bg-gray-50">
              <CardContent className="p-6 text-center">
                <p className="text-4xl font-bold text-blue-600">57.6%</p>
                <p className="text-gray-500 mt-2">Indonesians with dental issues</p>
              </CardContent>
            </Card>
            <Card className="border-none shadow-sm bg-gray-50">
              <CardContent className="p-6 text-center">
                <p className="text-4xl font-bold text-blue-600">10.2%</p>
                <p className="text-gray-500 mt-2">Receive professional treatment</p>
              </CardContent>
            </Card>
            <Card className="border-none shadow-sm bg-gray-50">
              <CardContent className="p-6 text-center">
                <p className="text-4xl font-bold text-blue-600">82.8%</p>
                <p className="text-gray-500 mt-2">Dental caries prevalence</p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-20 bg-gray-50">
        <div className="container px-4 md:px-6">
          <div className="text-center mb-16">
            <h2 className="text-3xl font-bold tracking-tight sm:text-4xl md:text-5xl text-gray-900">
              Key Features
            </h2>
            <p className="mt-4 text-xl text-gray-500 max-w-3xl mx-auto">
              DentalMatch provides innovative features powered by blockchain technology
            </p>
          </div>
          <div className="grid gap-8 md:grid-cols-3">
            {features.map((feature, index) => (
              <FeatureCard
                key={index}
                icon={feature.icon}
                title={feature.title}
                description={feature.description}
              />
            ))}
          </div>
        </div>
      </section>

      {/* Benefits Section */}
      <section id="benefits" className="py-20">
        <div className="container px-4 md:px-6">
          <div className="text-center mb-16">
            <h2 className="text-3xl font-bold tracking-tight sm:text-4xl md:text-5xl text-gray-900">
              Benefits
            </h2>
            <p className="mt-4 text-xl text-gray-500 max-w-3xl mx-auto">
              How DentalMatch benefits both students and patients
            </p>
          </div>
          <div className="grid gap-8 lg:grid-cols-2">
            <Card className="border-none shadow-sm">
              <CardContent className="p-8 space-y-4">
                <div className="inline-block rounded-full bg-blue-50 px-3 py-1 text-sm text-blue-800 font-medium">
                  For Dental Students
                </div>
                <h3 className="text-2xl font-bold tracking-tight text-gray-900">
                  Accelerate Your Clinical Practice
                </h3>
                <p className="text-gray-500">
                  DentalMatch helps you find patients that match your requirements
                </p>
                <ul className="space-y-3">
                  <li className="flex items-center gap-3">
                    <CheckCircle className="h-5 w-5 text-blue-600 flex-shrink-0" />
                    <span>Find patients matching your requirements</span>
                  </li>
                  <li className="flex items-center gap-3">
                    <CheckCircle className="h-5 w-5 text-blue-600 flex-shrink-0" />
                    <span>Manage treatment schedules efficiently</span>
                  </li>
                  <li className="flex items-center gap-3">
                    <CheckCircle className="h-5 w-5 text-blue-600 flex-shrink-0" />
                    <span>Organized case documentation</span>
                  </li>
                  <li className="flex items-center gap-3">
                    <CheckCircle className="h-5 w-5 text-blue-600 flex-shrink-0" />
                    <span>Complete your clinical practice on time</span>
                  </li>
                </ul>
              </CardContent>
            </Card>
            <Card className="border-none shadow-sm">
              <CardContent className="p-8 space-y-4">
                <div className="inline-block rounded-full bg-blue-50 px-3 py-1 text-sm text-blue-800 font-medium">
                  For Patients
                </div>
                <h3 className="text-2xl font-bold tracking-tight text-gray-900">
                  Affordable Dental Care
                </h3>
                <p className="text-gray-500">
                  Access quality dental care at more affordable rates
                </p>
                <ul className="space-y-3">
                  <li className="flex items-center gap-3">
                    <CheckCircle className="h-5 w-5 text-blue-600 flex-shrink-0" />
                    <span>Dental care at more affordable rates</span>
                  </li>
                  <li className="flex items-center gap-3">
                    <CheckCircle className="h-5 w-5 text-blue-600 flex-shrink-0" />
                    <span>Treated by students under experienced dentist supervision</span>
                  </li>
                  <li className="flex items-center gap-3">
                    <CheckCircle className="h-5 w-5 text-blue-600 flex-shrink-0" />
                    <span>Flexible treatment schedules</span>
                  </li>
                  <li className="flex items-center gap-3">
                    <CheckCircle className="h-5 w-5 text-blue-600 flex-shrink-0" />
                    <span>Contribute to dental education</span>
                  </li>
                </ul>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* About Section */}
      <section id="about" className="py-20 bg-gray-50">
        <div className="container px-4 md:px-6">
          <div className="text-center mb-16">
            <h2 className="text-3xl font-bold tracking-tight sm:text-4xl md:text-5xl text-gray-900">
              About DentalMatch
            </h2>
            <p className="mt-4 text-xl text-gray-500 max-w-3xl mx-auto">
              Connecting dental students at Jember University with patients who need affordable dental care
            </p>
          </div>
          <div className="max-w-4xl mx-auto">
            <Card className="border-none shadow-sm">
              <CardContent className="p-8 space-y-4">
                <p className="text-gray-600 leading-relaxed">
                  DentalMatch was born from the need to address two main problems: the difficulty dental students face in finding patients who match their requirements, and limited access to affordable dental care services.
                </p>
                <p className="text-gray-600 leading-relaxed">
                  According to data from the Indonesian Ministry of Health in 2018, around 57.6% of Indonesians experience dental and oral problems. Unfortunately, only 10.2% of them receive treatment from medical professionals.
                </p>
                <p className="text-gray-600 leading-relaxed">
                  With DentalMatch, we hope to bridge the needs of dental students and the community, so that both parties can benefit. Students can complete their clinical practice on time, while the community gains access to affordable dental care.
                </p>
              </CardContent>
            </Card>
          </div>
          <div className="mt-20">
            <h3 className="text-2xl font-bold text-center mb-10 text-gray-900">Our Team</h3>
            <div className="grid gap-8 md:grid-cols-3">
              {team.map((member, index) => (
                <TeamMember
                  key={index}
                  name={member.name}
                  role={member.role}
                  image={member.image}
                />
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Download Section */}
      <section id="download" className="py-20">
        <div className="container px-4 md:px-6">
          <div className="max-w-2xl mx-auto text-center space-y-8">
            <h2 className="text-3xl font-bold tracking-tight sm:text-4xl md:text-5xl text-gray-900">
              Download DentalMatch Now
            </h2>
            <p className="text-xl text-gray-500">
              Available for Android devices
            </p>
            <div className="flex justify-center">
              <Button size="lg" className="bg-blue-600 hover:bg-blue-700 text-white">
                Download from Google Play <Download className="ml-2 h-4 w-4" />
              </Button>
            </div>
            <p className="text-sm text-gray-500">
              Compatible with Android 6.0 (Marshmallow) and newer versions
            </p>
            <div className="relative h-64 w-full max-w-sm mx-auto">
              <div className="absolute inset-0 bg-gradient-to-r from-blue-50 to-purple-50 rounded-xl transform rotate-3"></div>
              <img
                src="/placeholder.svg?height=400&width=200"
                alt="DentalMatch App"
                className="relative z-10 h-full w-auto mx-auto rounded-xl shadow-lg object-cover"
              />
            </div>
          </div>
        </div>
      </section>

      <Footer />
    </div>
  );
};

export default Index;