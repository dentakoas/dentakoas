import { cn } from "@/lib/utils";
import { useEffect, useRef, useState } from "react";

interface AnimatedSpotlightProps {
    className?: string;
}

export function AnimatedSpotlight({ className }: AnimatedSpotlightProps) {
    const [position, setPosition] = useState({ x: 0, y: 0 });
    const [opacity, setOpacity] = useState(0);
    const [isVisible, setIsVisible] = useState(false);
    const ref = useRef<HTMLDivElement>(null);

    useEffect(() => {
        setIsVisible(true);

        const handleMouseMove = (e: MouseEvent) => {
            if (ref.current) {
                const rect = ref.current.getBoundingClientRect();
                setPosition({
                    x: e.clientX - rect.left,
                    y: e.clientY - rect.top
                });
            }
        };

        const handleMouseEnter = () => setOpacity(1);
        const handleMouseLeave = () => setOpacity(0);

        const element = ref.current;
        if (element) {
            element.addEventListener('mouseenter', handleMouseEnter);
            element.addEventListener('mouseleave', handleMouseLeave);
            element.addEventListener('mousemove', handleMouseMove);

            return () => {
                element.removeEventListener('mouseenter', handleMouseEnter);
                element.removeEventListener('mouseleave', handleMouseLeave);
                element.removeEventListener('mousemove', handleMouseMove);
            };
        }
    }, []);

    return (
        <div
            ref={ref}
            className={cn(
                "absolute top-0 left-0 w-full h-full overflow-hidden pointer-events-none",
                className
            )}
        >
            <div
                className="absolute bg-gradient-to-r from-blue-50 to-purple-50 rounded-full opacity-0 transition-opacity duration-300"
                style={{
                    left: `${position.x}px`,
                    top: `${position.y}px`,
                    width: "600px",
                    height: "600px",
                    transform: "translate(-50%, -50%)",
                    opacity: isVisible ? opacity * 0.6 : 0,
                }}
            />
        </div>
    );
}