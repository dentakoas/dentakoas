import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    this.textColor,
    this.textBtnColor,
    this.showActionButton = true,
    this.isSuffixIcon = false,
    this.suffixIcon,
    required this.title,
    this.buttonTitle = 'View all',
    this.onPressed,
    this.color = Colors.black,
  });

  final Color? textColor, textBtnColor;
  final bool showActionButton;
  final bool isSuffixIcon;
  final IconData? suffixIcon;
  final Color color;
  final String title, buttonTitle;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .apply(color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ], 
        ),
        if (showActionButton)
          isSuffixIcon
              ? IconButton(
                  onPressed: onPressed,
                  icon: Icon(suffixIcon),
                  color: color,
                )
              : TextButton(
                  onPressed: onPressed,
                  style: TextButton.styleFrom(
                    foregroundColor: textBtnColor ?? TColors.primary,
                    overlayColor: TColors.primary.withAlpha(50),
                  ),
                  child: Text(buttonTitle),
                ),
      ],
    );
  }
}
