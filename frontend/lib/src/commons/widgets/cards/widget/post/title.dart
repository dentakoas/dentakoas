import 'package:denta_koas/src/commons/widgets/text/title_text.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/enums.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TitleSection extends StatelessWidget {
  final String timePosted, title, description;

  const TitleSection({
    super.key,
    required this.timePosted,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(
            size: TSizes.iconXs,
            FontAwesomeIcons.circleDot,
            color: Colors.blue.shade400,
          ),
          const SizedBox(width: 4),
          Text(
            'Posted $timePosted',
            style: const TextStyle(color: TColors.textSecondary, fontSize: 12),
          ),
        ]),
        const SizedBox(height: TSizes.spaceBtwInputFields),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: TSizes.spaceBtwInputFields / 2),
        TitleText(
          title: description,
          maxLines: 3,
          textSizes: TextSizes.base,
          color: TColors.textSecondary,
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
