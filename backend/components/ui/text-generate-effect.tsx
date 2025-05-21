"use client"

import { useEffect, useState } from "react"
import { motion } from "framer-motion"
import { cn } from "@/lib/utils"

export const TextGenerateEffect = ({
  words,
  className,
}: {
  words: string
  className?: string
}) => {
  const [complete, setComplete] = useState(false)

  useEffect(() => {
    const timeout = setTimeout(() => {
      setComplete(true)
    }, 2000)
    return () => clearTimeout(timeout)
  }, [])

  const wordArray = words.split(" ")
  const variants = {
    visible: { opacity: 1, y: 0 },
    hidden: { opacity: 0, y: 20 },
  }

  return (
    <div className={cn("font-bold", className)}>
      <motion.div initial="hidden" animate="visible" transition={{ staggerChildren: 0.05 }}>
        {wordArray.map((word, idx) => (
          <motion.span
            key={`${word}-${idx}`}
            className="inline-block mr-1"
            variants={variants}
            transition={{ duration: 0.5 }}
          >
            {word}{" "}
          </motion.span>
        ))}
      </motion.div>
    </div>
  )
}
