import 'package:cached_network_image/cached_network_image.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class RoundedImage extends StatelessWidget {
  const RoundedImage({
    super.key,
    this.padding,
    this.border,
    this.onPressed,
    this.width,
    this.height,
    required this.imageUrl,
    this.applyImageRadius = true,
    this.backgroundColor = TColors.light,
    this.fit = BoxFit.contain,
    this.isNetworkImage = false,
    this.borderRadius = TSizes.md,
  });

  final double? width, height;
  final String imageUrl;
  final bool applyImageRadius;
  final BoxBorder? border;
  final Color backgroundColor;
  final BoxFit? fit;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final VoidCallback? onPressed;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          border: border,
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: applyImageRadius
              ? BorderRadius.circular(borderRadius)
              : BorderRadius.zero,
          child: isNetworkImage
              ? _buildNetworkImage()
              : Image.asset(
                  imageUrl,
                  fit: fit,
                  errorBuilder: (context, error, stackTrace) {
                    // Return a fallback image if the asset image fails to load
                    return Image.asset(
                      TImages.defaultImage,
                      fit: fit,
                    );
                  },
                ),
        ),
      ),
    );
  }

  // ADDED: Improved network image loading with better error handling
  Widget _buildNetworkImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        // Log the error for debugging
        debugPrint("Image loading error: $error, URL: $url");
        // Return a fallback image when network image fails
        return Image.asset(
          TImages.defaultImage,
          fit: fit,
        );
      },
    );
  }
}
