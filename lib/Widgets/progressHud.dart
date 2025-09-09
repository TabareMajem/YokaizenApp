import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../util/colors.dart';
import '../util/text_styles.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import 'package:get/get.dart';

class ProgressHUD extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final double opacity;
  final Color color;

  ProgressHUD({
    required this.child,
    required this.isLoading,
    this.opacity = 0.5,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = List<Widget>.empty(growable: true);
    widgetList.add(child);
    if (isLoading) {
      final modal = Stack(
        children: [
          Opacity(
            opacity: opacity,
            child: ModalBarrier(dismissible: false, color: color),
          ),
          Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: constants.borderRadius,
                side: const BorderSide(width: 0.2, color: colorSubHeadingText),
              ),
              child: Padding(
                padding: const EdgeInsets.all(constants.defaultPadding * 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                        child: const CircularProgressIndicator(),
                      height: 20,
                      width: 20,
                    ),
                    const SizedBox(
                      width: constants.defaultPadding,
                    ),
                    Text(
                      "Please wait...".tr,
                      style: AppTextStyle.normalBold14
                          .copyWith(color: colorHeadingText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
      widgetList.add(modal);
    }
    return Stack(
      children: widgetList,
    );
  }
}
