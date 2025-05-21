"use client"

import { useEffect, useState } from "react"
import Particles, { initParticlesEngine } from "@tsparticles/react"
import type { ISourceOptions } from "@tsparticles/engine"
import { loadSlim } from "@tsparticles/slim"

type SparklesProps = {
  id?: string
  className?: string
  background?: string
  minSize?: number
  maxSize?: number
  speed?: number
  particleColor?: string
  particleDensity?: number
}

export const SparklesCore = (props: SparklesProps) => {
  const {
    id = "tsparticles",
    className = "",
    background = "transparent",
    minSize = 0.6,
    maxSize = 1.4,
    speed = 1,
    particleColor = "#FFFFFF",
    particleDensity = 10,
  } = props
  const [init, setInit] = useState(false)

  useEffect(() => {
    initParticlesEngine(async (engine) => {
      await loadSlim(engine)
    }).then(() => {
      setInit(true)
    })
  }, [])

  const particlesOptions: ISourceOptions = {
    background: {
      color: {
        value: background,
      },
    },
    fullScreen: {
      enable: false,
      zIndex: 1,
    },
    // Reduce FPS limit to save resources
    fpsLimit: 60,
    interactivity: {
      events: {
        onClick: {
          enable: false, // Disable click interactions to reduce calculations
        },
        onHover: {
          enable: true,
          mode: "repulse",
        },
      },
      modes: {
        repulse: {
          distance: 100, // Reduce repulse distance
          duration: 0.3, // Shorter duration
        },
      },
    },
    particles: {
      color: {
        value: particleColor,
      },
      links: {
        color: particleColor,
        distance: 150,
        enable: true,
        opacity: 0.4,
        width: 0.8, // Thinner lines for better performance
      },
      move: {
        direction: "none",
        enable: true,
        outModes: {
          default: "out", // Change from "bounce" to "out" for better performance
        },
        random: false,
        speed: speed * 0.8, // Slightly slower for better performance
        straight: false,
      },
      number: {
        density: {
          enable: true,
          width: particleDensity * 1.5, // Increase area per particle
        },
        value: 40, // Reduce number of particles from 80 to 40
      },
      opacity: {
        value: 0.4, // Slightly lower opacity
      },
      shape: {
        type: "circle",
      },
      size: {
        value: { min: minSize, max: maxSize },
      },
    },
    detectRetina: false, // Disable retina detection for better performance
  }

  if (init) {
    return <Particles id={id} className={className} options={particlesOptions} />
  }

  return <></>
}
