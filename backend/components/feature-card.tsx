
import { Card, CardContent } from "@/components/ui/card";
import { ReactNode } from "react";

interface FeatureCardProps {
    icon: ReactNode;
    title: string;
    description: string;
}

export function FeatureCard({ icon, title, description }: FeatureCardProps) {
    return (
        <Card className="border-none shadow-sm hover:shadow transition-shadow duration-200 bg-white overflow-hidden group">
            <CardContent className="p-8 flex flex-col items-center text-center space-y-4">
                <div className="h-12 w-12 bg-blue-50 rounded-full flex items-center justify-center text-blue-600 group-hover:bg-blue-100 transition-colors">
                    {icon}
                </div>
                <h3 className="text-xl font-semibold text-gray-900">{title}</h3>
                <p className="text-gray-500">{description}</p>
            </CardContent>
        </Card>
    );
}