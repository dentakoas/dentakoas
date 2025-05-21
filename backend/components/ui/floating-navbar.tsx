"use client"

import { useState } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { cn } from "@/lib/utils"
import Link from "next/link"
import { Smartphone } from "lucide-react"

export const FloatingNavbar = ({
  navItems,
  className,
}: {
  navItems: {
    name: string
    link: string
  }[]
  className?: string
}) => {
  const [active, setActive] = useState<string | null>(null)

  return (
    <AnimatePresence mode="wait">
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: -20 }}
        className={cn("fixed top-4 inset-x-0 max-w-2xl mx-auto z-50", className)}
      >
        <div className="backdrop-blur-sm bg-black/40 border border-purple-500/20 rounded-full flex items-center justify-between p-4">
          <Link href="/" className="flex gap-2 items-center text-xl font-bold text-white">
            <Smartphone className="h-6 w-6 text-purple-500" />
            <span className="bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-purple-500">
              Denta koas
            </span>
          </Link>
          <nav className="flex items-center gap-2">
            {navItems.map((item, index) => (
              <Link
                key={item.name}
                href={item.link}
                onMouseEnter={() => setActive(item.name)}
                onMouseLeave={() => setActive(null)}
                className={cn(
                  "px-4 py-2 rounded-full text-sm transition-colors relative",
                  active === item.name ? "text-white" : "text-neutral-300 hover:text-white",
                )}
              >
                <span className="relative z-10">{item.name}</span>
                {active === item.name && (
                  <motion.div
                    layoutId="pill"
                    className="absolute inset-0 bg-gradient-to-r from-blue-500/20 to-purple-500/20 rounded-full"
                    transition={{
                      type: "spring",
                      bounce: 0.3,
                      duration: 0.6,
                    }}
                  />
                )}
              </Link>
            ))}
          </nav>
        </div>
      </motion.div>
    </AnimatePresence>
  )
}
