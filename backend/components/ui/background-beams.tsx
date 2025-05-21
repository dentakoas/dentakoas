"use client"

import type React from "react"
import { useEffect, useRef, useState } from "react"

interface BackgroundBeamsProps extends React.HTMLProps<HTMLDivElement> {}

export const BackgroundBeams = ({ className = "", ...props }: BackgroundBeamsProps) => {
  const [mousePosition, setMousePosition] = useState<{ x: number; y: number }>({ x: 0, y: 0 })

  const ref = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const handleMouseMove = (event: MouseEvent) => {
      if (ref.current) {
        const rect = ref.current.getBoundingClientRect()
        setMousePosition({
          x: event.clientX - rect.left,
          y: event.clientY - rect.top,
        })
      }
    }

    const element = ref.current
    if (element) {
      element.addEventListener("mousemove", handleMouseMove)
    }

    return () => {
      if (element) {
        element.removeEventListener("mousemove", handleMouseMove)
      }
    }
  }, [])

  return (
    <div
      ref={ref}
      className={`h-full w-full overflow-hidden [--x:${mousePosition.x}px] [--y:${mousePosition.y}px] ${className}`}
      {...props}
    >
      <div
        className="pointer-events-none absolute inset-0 z-0 h-full w-full bg-[radial-gradient(circle_at_var(--x)_var(--y),rgba(120,_119,_198,_0.15)_0%,transparent_80%)]"
        style={{
          background: "radial-gradient(circle at var(--x) var(--y), rgba(120, 119, 198, 0.15) 0%, transparent 80%)",
        }}
      />
    </div>
  )
}
