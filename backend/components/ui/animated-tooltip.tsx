"use client"

import { useState } from "react"
import { motion } from "framer-motion"
import Image from "next/image"

export const AnimatedTooltip = ({
  items,
}: {
  items: {
    id: number
    name: string
    designation: string
    image: string
  }[]
}) => {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null)

  return (
    <div className="flex flex-row items-center justify-center gap-4">
      {items.map((item, idx) => (
        <div
          key={item.id}
          className="relative group"
          onMouseEnter={() => setHoveredIndex(idx)}
          onMouseLeave={() => setHoveredIndex(null)}
        >
          <div className="relative h-16 w-16 md:h-20 md:w-20 rounded-full overflow-hidden border-2 border-purple-500/50 group-hover:border-purple-500 transition-colors">
            <Image src={item.image || "/placeholder.svg"} alt={item.name} fill className="object-cover" />
          </div>
          {hoveredIndex === idx && (
            <motion.div
              initial={{ opacity: 0, y: 20, scale: 0.6 }}
              animate={{
                opacity: 1,
                y: 0,
                scale: 1,
                transition: {
                  type: "spring",
                  stiffness: 260,
                  damping: 10,
                },
              }}
              exit={{ opacity: 0, y: 20, scale: 0.6 }}
              className="absolute -top-16 left-1/2 -translate-x-1/2 flex flex-col items-center justify-center z-50"
            >
              <div className="px-4 py-2 bg-black/80 backdrop-blur-sm border border-purple-500/20 rounded-xl text-center">
                <div className="text-sm font-bold text-white">{item.name}</div>
                <div className="text-xs text-purple-300">{item.designation}</div>
              </div>
              <div className="h-3 w-3 bg-black/80 rotate-45 translate-y-[-6px] border-r border-b border-purple-500/20" />
            </motion.div>
          )}
        </div>
      ))}
    </div>
  )
}
