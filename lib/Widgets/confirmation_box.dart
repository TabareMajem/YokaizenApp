import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yokai_quiz_app/util/const.dart';

import '../util/colors.dart';
import '../util/text_styles.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String cancelButtonText;
  final String confirmButtonText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final String customImageAsset;
  final bool displayIcon;
  final Color tileColor;
  const ConfirmationDialog(
      {required this.title,
      required this.content,
      required this.cancelButtonText,
      required this.confirmButtonText,
      required this.onCancel,
      required this.onConfirm,
      this.tileColor = textDark,
      this.customImageAsset = 'images/appLogo_yokai.png',
      this.displayIcon = false});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //  height: MediaQuery.of(context).size.height * 0.4,
      titlePadding: title.isEmpty ? EdgeInsets.zero : null,
      backgroundColor: colorWhite,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (displayIcon == true) Image.asset(customImageAsset, height: 80),
          Text(
            title,
            style: AppTextStyle.normalSemiBold16.copyWith(color: tileColor),
          ),
        ],
      ),
      content: content,
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: cancelButtonText == 'Delete' ? 10 : 12, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: Color(0x0C101828),
                  elevation: 2,
                ),
                child: Text(
                  confirmButtonText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: confirmButtonText.length > 14 ? 12 : 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    height: 0,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(
                      width: 1,
                      color: cancelButtonText == 'Delete'
                          ? headingOrange
                          : Color(0xFFA9B6B7)),
                  shadowColor: Color(0x0C101828),
                  elevation: 2,
                ),
                child: Container(
                  height: 40,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      cancelButtonText == 'Delete'
                          ? SvgPicture.asset('icons/delete_icon.svg')
                          : SizedBox(),
                      0.5.pw,
                      Text(
                        cancelButtonText,
                        style: TextStyle(
                          color: cancelButtonText == 'Delete'
                              ? headingOrange
                              : Color(0xFF495355),
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
