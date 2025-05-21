"use client"

import { cn } from "@/lib/utils"
import type React from "react"
import { useState } from "react"

export const HoverBorderGradient = ({
  children,
  containerClassName,
  className,
  as: Tag = "div",
  ...props
}: {
  children: React.ReactNode
  containerClassName?: string
  className?: string
  as?: React.ElementType
  [key: string]: any
}) => {
  const [hovered, setHovered] = useState(false)

  return (
    <Tag
      className={cn("bg-black p-[1px] overflow-hidden rounded-[22px] relative", containerClassName)}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      {...props}
    >
      <div
        className={cn(
          "absolute inset-0 rounded-[22px]",
          "bg-[radial-gradient(circle_at_top_left,hsl(250,_100%,_85%),transparent_25%),radial-gradient(circle_at_bottom_right,hsl(270,_100%,_85%),transparent_25%)]",
          "opacity-0 transition-opacity duration-500",
          hovered && "opacity-100",
        )}
      />
      <div className={cn("relative", className)}>{children}</div>
    </Tag>
  )
}
