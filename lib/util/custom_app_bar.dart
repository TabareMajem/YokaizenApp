import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

import 'colors.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    required this.isBackButton,
    required this.isColor,
    required this.onButtonPressed,
    this.colors,
  });

  final String title;
  final bool isBackButton;
  final bool isColor;
  final Color? colors;
  final VoidCallback onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: this.isColor ? this.colors : null,
      child: Column(
        children: [
          const SizedBox(height: 20,),
          GestureDetector(
            onTap: onButtonPressed,
            child: Row(
              children: [
                isBackButton ? SvgPicture.asset(
                  'icons/arrowLeft.svg',
                  height: 35,
                  width: 35,
                ) : Container(),
                Text(
                  "  ${title.toString()}".tr,
                  style: AppTextStyle.normalBold16.copyWith(
                      color: coral500,
                    fontWeight: FontWeight.w700
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
