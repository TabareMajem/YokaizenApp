import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:get/get.dart';

class ProgressBar extends StatelessWidget {
  final int totalValue;
  final int completedValue;
  final bool withIcon;
  final bool withText;

  const ProgressBar({
    super.key,
    required this.totalValue,
    required this.completedValue,
    this.withIcon = true,
    this.withText = true,
  });

  @override
  Widget build(BuildContext context) {
    double progressRatio = completedValue / totalValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Container(
                    height: 10,
                    width: MediaQuery.of(context).size.width * progressRatio,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Icon
            if (withIcon)
              SvgPicture.asset(
                'icons/rewards.svg',
                height: 24,
                width: 24,
              ),
          ],
        ),
        if (withText)
          Text(
              completedValue >= totalValue
                  ? 'Completed'.tr
                  : '$completedValue/$totalValue Completed',
              style: AppTextStyle.normalBold14.copyWith(
                color: Colors.black45,
                fontWeight: FontWeight.w400,
              )),
      ],
    );
  }
}
