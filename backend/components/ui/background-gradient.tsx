import { cn } from "@/lib/utils"
import type React from "react"

export const BackgroundGradient = ({
  children,
  className,
  containerClassName,
  animate = true,
}: {
  children?: React.ReactNode
  className?: string
  containerClassName?: string
  animate?: boolean
}) => {
  const variants = {
    initial: {
      backgroundPosition: "0 50%",
    },
    animate: {
      backgroundPosition: ["0, 50%", "100% 50%", "0 50%"],
    },
  }
  return (
    <div className={cn("relative p-[4px] group", containerClassName)}>
      <div
        className={cn(
          "absolute inset-0 rounded-[22px] z-[1] opacity-60 group-hover:opacity-100 blur-xl transition duration-500",
          "bg-[radial-gradient(circle_at_top_left,hsl(250,_100%,_85%),transparent_25%),radial-gradient(circle_at_bottom_right,hsl(270,_100%,_85%),transparent_25%)]",
          className,
        )}
      />
      <div
        className={cn(
          "absolute inset-0 rounded-[22px] z-[1]",
          "bg-[radial-gradient(circle_at_top_left,hsl(250,_100%,_85%),transparent_25%),radial-gradient(circle_at_bottom_right,hsl(270,_100%,_85%),transparent_25%)]",
          className,
        )}
      />
      <div className="relative z-[2]">{children}</div>
    </div>
  )
}
