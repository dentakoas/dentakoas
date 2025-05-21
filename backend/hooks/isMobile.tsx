'use client'

import { useState, useEffect } from 'react';

/**
 * Hook to detect if the current device is a mobile device
 * @param {number} breakpoint - The width threshold to consider a device as mobile (default: 768px)
 * @returns {boolean} - True if the device is mobile, false otherwise
 */
export function useIsMobile(breakpoint: number = 768): boolean {
    const [isMobile, setIsMobile] = useState<boolean>(false);

    useEffect(() => {
        // Function to check if device is mobile based on user agent
        const checkUserAgent = (): boolean => {
            const userAgent =
                typeof window !== 'undefined' ? window.navigator.userAgent.toLowerCase() : '';

            const mobileRegex = /android|webos|iphone|ipad|ipod|blackberry|iemobile|opera mini|mobile|tablet/i;
            return mobileRegex.test(userAgent);
        };

        // Function to check if device is mobile based on screen width
        const checkScreenWidth = (): boolean => {
            return typeof window !== 'undefined' && window.innerWidth < breakpoint;
        };

        // Function to update state based on both checks
        const updateMobileState = () => {
            const isMobileByUserAgent = checkUserAgent();
            const isMobileByScreenWidth = checkScreenWidth();

            // Consider mobile if either check passes
            setIsMobile(isMobileByUserAgent || isMobileByScreenWidth);
        };

        // Initial check
        updateMobileState();

        // Listen for window resize events
        const handleResize = () => {
            updateMobileState();
        };

        // Add event listener
        if (typeof window !== 'undefined') {
            window.addEventListener('resize', handleResize);
        }

        // Clean up
        return () => {
            if (typeof window !== 'undefined') {
                window.removeEventListener('resize', handleResize);
            }
        };
    }, [breakpoint]); // Re-run effect if breakpoint changes

    return isMobile;
}

export default useIsMobile;
