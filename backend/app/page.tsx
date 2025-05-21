'use client'

import { ArrowRight, CheckCircle, Download, MessageCircle, Shield, Smartphone, Users } from 'lucide-react'
import Image from "next/image"
import Link from "next/link"
import { useEffect, useState } from "react"

import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { BackgroundBeams } from "@/components/ui/background-beams"
import { BackgroundGradient } from "@/components/ui/background-gradient"
import { SparklesCore } from "@/components/ui/sparkles"
import { TextGenerateEffect } from "@/components/ui/text-generate-effect"
import { TracingBeam } from "@/components/ui/tracing-beam"
import { FloatingNavbar } from "@/components/ui/floating-navbar"
import { HoverBorderGradient } from "@/components/ui/hover-border-gradient"
import { AnimatedTooltip } from "@/components/ui/animated-tooltip"

const navItems = [
  {
    name: "Features",
    link: "#features",
  },
  {
    name: "Benefits",
    link: "#benefits",
  },
  {
    name: "About",
    link: "#about",
  },
  {
    name: "Download",
    link: "#download",
  },
]

const team = [
  {
    id: 1,
    name: "Dr. Andi",
    designation: "Lead Dentist",
    image: "/placeholder.svg?height=200&width=200",
  },
  {
    id: 2,
    name: "Dr. Budi",
    designation: "Dental Specialist",
    image: "/placeholder.svg?height=200&width=200",
  },
  {
    id: 3,
    name: "Dr. Citra",
    designation: "Orthodontist",
    image: "/placeholder.svg?height=200&width=200",
  },
]

export default function Home() {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  if (!mounted) {
    return null
  }

  return (
    <div className="flex min-h-screen flex-col bg-black text-white">
      {/* Navigation */}
      <FloatingNavbar navItems={navItems} />

      {/* Hero Section */}
      <section className="relative flex min-h-screen flex-col items-center justify-center overflow-hidden py-20">
        <BackgroundBeams className="opacity-20" />
        <div className="container mx-auto relative z-10 px-4 md:px-6 max-w-6xl">
          <div className="grid gap-6 lg:grid-cols-2 lg:gap-12 xl:grid-cols-2 items-center">
            <div className="flex flex-col justify-center space-y-4">
              <div className="space-y-2">
                <div className="inline-block rounded-lg bg-gradient-to-r from-purple-500 to-blue-500 px-3 py-1 text-sm">
                  REVOLUTIONARY DENTAL PLATFORM
                </div>
                <h1 className="text-4xl font-bold tracking-tighter sm:text-5xl md:text-6xl/none bg-clip-text text-transparent bg-gradient-to-r from-blue-400 via-purple-500 to-indigo-600">
                  Denta koas
                </h1>
                <div className="h-20">
                  <TextGenerateEffect
                    words="Connecting dental students with patients through blockchain technology"
                    className="max-w-[600px] text-xl text-gray-300"
                  />
                </div>
              </div>
              <div className="flex flex-col gap-2 min-[400px]:flex-row">
                <HoverBorderGradient className="w-full sm:w-auto">
                  <Button size="lg" className="w-full bg-black border border-purple-500/20 hover:bg-black/90">
                    Download App <ArrowRight className="ml-2 h-4 w-4" />
                  </Button>
                </HoverBorderGradient>
                {/* <Button size="lg" variant="outline" className="border-purple-500/20 text-white hover:bg-black/20">
                  Learn More
                </Button> */}
              </div>
            </div>
            <div className="flex items-center justify-center">
              <BackgroundGradient className="rounded-[22px] p-1 bg-black">
                <div className="relative h-[450px] w-[300px] overflow-hidden rounded-[20px] bg-black">
                  <Image
                    src="/placeholder.svg?height=900&width=600"
                    alt="Denta koas App Preview"
                    className="object-cover"
                    fill
                    priority
                  />
                </div>
              </BackgroundGradient>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="w-full py-12 md:py-24 lg:py-32 bg-black border-t border-purple-500/20">
        <div className="container mx-auto px-4 md:px-6 max-w-6xl">
          <div className="grid gap-6 text-center md:grid-cols-3 lg:gap-12">
            <Card className="bg-black/50 border-purple-500/20">
              <CardContent className="p-6 space-y-2">
                <h2 className="text-4xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-purple-500">57.6%</h2>
                <p className="text-gray-400">Indonesians with dental issues</p>
              </CardContent>
            </Card>
            <Card className="bg-black/50 border-purple-500/20">
              <CardContent className="p-6 space-y-2">
                <h2 className="text-4xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-purple-500">10.2%</h2>
                <p className="text-gray-400">Receive professional treatment</p>
              </CardContent>
            </Card>
            <Card className="bg-black/50 border-purple-500/20">
              <CardContent className="p-6 space-y-2">
                <h2 className="text-4xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-purple-500">82.8%</h2>
                <p className="text-gray-400">Dental caries prevalence</p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="relative w-full py-12 md:py-24 lg:py-32 overflow-hidden">
        <div className="absolute inset-0 w-full h-full">
          <SparklesCore
            id="tsparticlesfull"
            background="transparent"
            minSize={0.6}
            maxSize={1.4}
            particleDensity={100}
            className="w-full h-full"
            particleColor="#8B5CF6"
          />
        </div>
        <div className="container mx-auto relative z-10 px-4 md:px-6 max-w-6xl">
          <div className="flex flex-col items-center justify-center space-y-4 text-center">
            <div className="space-y-2">
              <h2 className="text-3xl font-bold tracking-tighter sm:text-4xl md:text-5xl bg-clip-text text-transparent bg-gradient-to-r from-blue-400 via-purple-500 to-indigo-600">
                Key Features
              </h2>
              <p className="max-w-[900px] text-gray-400 md:text-xl/relaxed lg:text-base/relaxed xl:text-xl/relaxed">
                Denta koas provides innovative features powered by blockchain technology
              </p>
            </div>
          </div>
          <div className="mx-auto grid max-w-5xl grid-cols-1 gap-6 py-12 md:grid-cols-2 lg:grid-cols-3">
            <BackgroundGradient className="rounded-[22px] p-1 bg-black">
              <Card className="flex h-full flex-col items-center space-y-2 rounded-[20px] border-purple-500/20 bg-black p-6">
                <div className="rounded-full bg-gradient-to-r from-blue-500 to-purple-500 p-3">
                  <Users className="h-6 w-6 text-white" />
                </div>
                <h3 className="text-xl font-bold">Patient Matching</h3>
                <p className="text-center text-gray-400">
                  Smart matching algorithm connects students with suitable patients
                </p>
              </Card>
            </BackgroundGradient>
            <BackgroundGradient className="rounded-[22px] p-1 bg-black">
              <Card className="flex h-full flex-col items-center space-y-2 rounded-[20px] border-purple-500/20 bg-black p-6">
                <div className="rounded-full bg-gradient-to-r from-blue-500 to-purple-500 p-3">
                  <MessageCircle className="h-6 w-6 text-white" />
                </div>
                <h3 className="text-xl font-bold">Secure Messaging</h3>
                <p className="text-center text-gray-400">
                  End-to-end encrypted communication between students and patients
                </p>
              </Card>
            </BackgroundGradient>
            <BackgroundGradient className="rounded-[22px] p-1 bg-black">
              <Card className="flex h-full flex-col items-center space-y-2 rounded-[20px] border-purple-500/20 bg-black p-6">
                <div className="rounded-full bg-gradient-to-r from-blue-500 to-purple-500 p-3">
                  <Shield className="h-6 w-6 text-white" />
                </div>
                <h3 className="text-xl font-bold">Data Security</h3>
                <p className="text-center text-gray-400">
                  Blockchain-based security for all personal and medical data
                </p>
              </Card>
            </BackgroundGradient>
          </div>
        </div>
      </section>

      {/* Benefits Section */}
      <TracingBeam className="px-6">
        <section id="benefits" className="w-full py-12 md:py-24 lg:py-32">
          <div className="container mx-auto px-4 md:px-6 max-w-6xl">
            <div className="grid gap-10 lg:grid-cols-2 lg:gap-12">
              <Card className="bg-black/50 border-purple-500/20">
                <CardContent className="p-6 space-y-4">
                  <div className="inline-block rounded-lg bg-gradient-to-r from-blue-500 to-purple-500 px-3 py-1 text-sm">
                    For Dental Students
                  </div>
                  <h2 className="text-3xl font-bold tracking-tighter sm:text-4xl md:text-5xl bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-purple-500">
                    Accelerate Your Clinical Practice
                  </h2>
                  <p className="max-w-[600px] text-gray-400 md:text-xl/relaxed lg:text-base/relaxed xl:text-xl/relaxed">
                    Denta koas helps you find patients that match your requirements
                  </p>
                  <ul className="grid gap-2">
                    <li className="flex items-center gap-2">
                      <CheckCircle className="h-5 w-5 text-purple-500" />
                      <span className='text-gray-400'>Find patients matching your requirements</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle className="h-5 w-5 text-purple-500" />
                      <span className='text-gray-400'>Manage treatment schedules efficiently</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle className="h-5 w-5 text-purple-500" />
                      <span className='text-gray-400'>Organized case documentation</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle className="h-5 w-5 text-purple-500" />
                      <span className='text-gray-400'>Complete your clinical practice on time</span>
                    </li>
                  </ul>
                </CardContent>
              </Card>
              <Card className="bg-black/50 border-purple-500/20">
                <CardContent className="p-6 space-y-4">
                  <div className="inline-block rounded-lg bg-gradient-to-r from-blue-500 to-purple-500 px-3 py-1 text-sm">
                    For Patients
                  </div>
                  <h2 className="text-3xl font-bold tracking-tighter sm:text-4xl md:text-5xl bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-purple-500">
                    Affordable Dental Care
                  </h2>
                  <p className="max-w-[600px] text-gray-400 md:text-xl/relaxed lg:text-base/relaxed xl:text-xl/relaxed">
                    Access quality dental care at more affordable rates
                  </p>
                  <ul className="grid gap-2">
                    <li className="flex items-center gap-2">
                      <CheckCircle className="h-5 w-5 text-purple-500" />
                      <span className='text-gray-400'>Dental care at more affordable rates</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle className="h-5 w-5 text-purple-500" />
                      <span className='text-gray-400'>Treated by students under experienced dentist supervision</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle className="h-5 w-5 text-purple-500" />
                      <span className='text-gray-400'>Flexible treatment schedules</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle className="h-5 w-5 text-purple-500" />
                      <span className='text-gray-400'>Contribute to dental education</span>
                    </li>
                  </ul>
                </CardContent>
              </Card>
            </div>
          </div>
        </section>

        {/* About Section */}
        <section id="about" className="w-full py-12 md:py-24 lg:py-32">
          <div className="container mx-auto px-4 md:px-6 max-w-6xl">
            <div className="flex flex-col items-center justify-center space-y-4 text-center">
              <div className="space-y-2">
                <h2 className="text-3xl font-bold tracking-tighter sm:text-4xl md:text-5xl bg-clip-text text-transparent bg-gradient-to-r from-blue-400 via-purple-500 to-indigo-600">
                  About Denta koas
                </h2>
                <p className="max-w-[900px] text-gray-400 md:text-xl/relaxed lg:text-base/relaxed xl:text-xl/relaxed">
                  Connecting dental students at Jember University with patients who need affordable dental care
                </p>
              </div>
              <Card className="mx-auto max-w-3xl bg-black/50 border-purple-500/20">
                <CardContent className="p-6 space-y-4 text-left">
                  <p className="text-gray-400">
                    Denta koas was born from the need to address two main problems: the difficulty dental students face in finding patients who match their requirements, and limited access to affordable dental care services.
                  </p>
                  <p className="text-gray-400">
                    According to data from the Indonesian Ministry of Health in 2018, around 57.6% of Indonesians experience dental and oral problems. Unfortunately, only 10.2% of them receive treatment from medical professionals.
                  </p>
                  <p className="text-gray-400">
                    With Denta koas, we hope to bridge the needs of dental students and the community, so that both parties can benefit. Students can complete their clinical practice on time, while the community gains access to affordable dental care.
                  </p>
                </CardContent>
              </Card>
              <div className="flex flex-wrap justify-center gap-8 py-10">
                <AnimatedTooltip items={team} />
              </div>
            </div>
          </div>
        </section>
      </TracingBeam>

      {/* Download Section */}
      <section id="download" className="relative w-full py-12 md:py-24 lg:py-32 overflow-hidden">
        <div className="absolute inset-0 w-full h-full bg-gradient-to-b from-black via-purple-900/20 to-black" />
        <div className="container mx-auto relative z-10 px-4 md:px-6 max-w-6xl">
          <div className="flex flex-col items-center justify-center space-y-4 text-center">
            <div className="space-y-2">
              <h2 className="text-3xl font-bold tracking-tighter sm:text-4xl md:text-5xl bg-clip-text text-transparent bg-gradient-to-r from-blue-400 via-purple-500 to-indigo-600">
                Download Denta koas Now
              </h2>
              <p className="max-w-[900px] text-gray-400 md:text-xl/relaxed lg:text-base/relaxed xl:text-xl/relaxed">
                Available for Android devices
              </p>
            </div>
            <div className="mx-auto w-full max-w-sm space-y-2">
              <BackgroundGradient className="rounded-[22px] p-1 bg-black">
                <Button size="lg" className="w-full bg-black hover:bg-black/90">
                  Download from Google Play <Download className="ml-2 h-4 w-4" />
                </Button>
              </BackgroundGradient>
              <p className="text-xs text-gray-400">
                Compatible with Android 6.0 (Marshmallow) and newer versions
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="flex flex-col gap-2 sm:flex-row py-6 w-full shrink-0 items-center px-4 md:px-6 border-t border-purple-500/20">
        <div className="container mx-auto max-w-6xl flex flex-col sm:flex-row items-center justify-between">
          <p className="text-xs text-gray-400">© 2024 Denta koas. All rights reserved.</p>
          <nav className="sm:ml-auto flex gap-4 sm:gap-6">
            <Link className="text-xs hover:text-purple-400 transition-colors" href="#">
              Privacy Policy
            </Link>
            <Link className="text-xs hover:text-purple-400 transition-colors" href="#">
              Terms & Conditions
            </Link>
          </nav>
        </div>
      </footer>
    </div>
  )
}