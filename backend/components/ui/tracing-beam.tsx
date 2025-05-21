"use client"

import type React from "react"
import { useEffect, useRef, useState } from "react"
import { motion, useTransform, useScroll, useSpring } from "framer-motion"
import { cn } from "@/lib/utils"

export const TracingBeam = ({
  children,
  className,
}: {
  children: React.ReactNode
  className?: string
}) => {
  const ref = useRef<HTMLDivElement>(null)
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start start", "end end"],
  })

  const contentRef = useRef<HTMLDivElement>(null)
  const [svgHeight, setSvgHeight] = useState(0)

  useEffect(() => {
    if (contentRef.current) {
      setSvgHeight(contentRef.current.offsetHeight)
    }
  }, [])

  const yRange = useTransform(scrollYProgress, [0, 1], [0, svgHeight])
  const smoothY = useSpring(yRange, { damping: 50, stiffness: 400 })

  return (
    <div ref={ref} className={cn("relative", className)}>
      <div className="absolute -left-4 md:-left-20 top-3">
        <motion.div
          style={{
            height: smoothY,
          }}
          className="relative h-full w-2 bg-gradient-to-b from-purple-500 to-transparent"
        />
        <motion.div
          style={{
            top: smoothY,
          }}
          className="sticky top-0 left-0 h-4 w-4 rounded-full border border-purple-500 bg-black shadow-lg shadow-purple-900/20"
        />
      </div>
      <div ref={contentRef}>{children}</div>
    </div>
  )
}
