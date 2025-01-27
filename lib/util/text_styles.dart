library my_prj.globals;

import 'package:flutter/material.dart';

import 'colors.dart';

class textStyle {
  static final TextStyle title =
      TextStyle(color: colorDark, fontWeight: FontWeight.bold, fontSize: 34);

  static final TextStyle titleBold =
      TextStyle(color: colorDark, fontWeight: FontWeight.w900, fontSize: 24);

  ///heading

  static final TextStyle headingLight =
      TextStyle(color: colorDark, fontSize: 32, fontFamily: 'Montserrat');
  static final TextStyle heading =
      TextStyle(color: colorDark, fontSize: 32, fontFamily: 'Montserrat');
  static final TextStyle headingSemiBold =
      TextStyle(color: colorDark, fontSize: 32, fontFamily: 'Montserrat');
  static final TextStyle headingBold =
      TextStyle(color: colorDark, fontSize: 32, fontFamily: 'Montserrat');
  static final TextStyle headingExtraBold =
      TextStyle(color: colorDark, fontSize: 32, fontFamily: 'Montserrat');
  static final TextStyle navbarSelected = TextStyle(
    color: Color(0xFF124B67),
    fontSize: 10,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w700,
    // height: 0.06,
  );
  static final TextStyle navbarUnselected = TextStyle(
    color: primaryColor,
    fontSize: 10,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w500,
    // height: 0.06,
  );
  // static final TextStyle headingsemibold = TextStyle(
  //     color: colorDark,
  //     fontWeight: FontWeight.w700,
  //     fontSize: 32,
  //     fontFamily: 'poppinssemibold');

  // static final TextStyle headingLight = TextStyle(
  //     color: colorDark,
  //     // fontWeight: FontWeight.w700,
  //     fontSize: 22,
  //     fontFamily: 'poppinslight');

  ///subheading
  // static final TextStyle subHeading = TextStyle(
  //     color: colorSubHeadingText,
  //     fontWeight: FontWeight.normal,
  //     fontSize: 16);
  static final TextStyle subHeadingLight = TextStyle(
      color: colorSubHeadingText, fontSize: 16, fontFamily: 'Montserrat');

  static final TextStyle subHeading = TextStyle(
      color: colorSubHeadingText, fontSize: 16, fontFamily: 'Montserrat');

  static final TextStyle subHeadingColorDark = TextStyle(
      color: colorHeadingText, fontSize: 16, fontFamily: 'Montserrat');

  static final TextStyle subHeadingSemiBold = TextStyle(
      color: colorSubHeadingText, fontSize: 16, fontFamily: 'Montserrat');

  static final TextStyle subHeadingBold = TextStyle(
      color: colorSubHeadingText, fontSize: 16, fontFamily: 'Montserrat');

  static final TextStyle subHeadingExtraBold = TextStyle(
      color: colorSubHeadingText, fontSize: 16, fontFamily: 'Montserrat');

  // static final TextStyle subHeadingSemibold = TextStyle(
  //     color: colorSubHeadingText,
  //     fontFamily: 'poppinssemibold',
  //     fontWeight: FontWeight.normal,
  //     fontSize: 16);
  //
  // static final TextStyle subHeadingSemibold2 = TextStyle(
  //     color: colorSubHeadingText,
  //     fontFamily: 'poppinssemibold',
  //     fontWeight: FontWeight.normal,
  //     fontSize: 16);
  //
  // static final TextStyle subHeadingLigh = TextStyle(
  //     color: colorSubHeadingText,
  //     fontFamily: 'poppinslight',
  //     fontWeight: FontWeight.normal,
  //     fontSize: 16);

  // static final TextStyle subHeadingColorDark =
  //     subHeading.copyWith(color: colorHeadingText, fontWeight: FontWeight.bold);

  ///small text

  static final TextStyle smallTextLight = TextStyle(
      color: colorSubHeadingText, fontSize: 13, fontFamily: 'Montserrat');
  static final TextStyle smallText = TextStyle(
      color: colorSubHeadingText, fontSize: 13, fontFamily: 'Montserrat');
  static final TextStyle smallTextColorDark = TextStyle(
      color: colorSubHeadingText, fontSize: 13, fontFamily: 'Montserrat');
  static final TextStyle smallTextSemiBold = TextStyle(
      color: colorSubHeadingText, fontSize: 13, fontFamily: 'Montserrat');
  static final TextStyle smallTextBold = TextStyle(
      color: colorSubHeadingText, fontSize: 13, fontFamily: 'Montserrat');
  static final TextStyle smallTextExtraBold = TextStyle(
      color: colorSubHeadingText, fontSize: 13, fontFamily: 'Montserrat');

  // static final TextStyle smallTextColorDark = TextStyle(
  //     color: colorSubHeadingText, fontWeight: FontWeight.bold, fontSize: 13);
  //
  // static final TextStyle smallTextSemiBoldDark = TextStyle(
  //     color: colorSubHeadingText,
  //     fontFamily: 'poppinssemibold',
  //     fontWeight: FontWeight.w500,
  //     fontSize: 13);
  //
  // static final TextStyle smallText = TextStyle(
  //     color: colorSubHeadingText,
  //     fontWeight: FontWeight.normal,
  //     fontSize: 13);
  //
  // static final TextStyle smallTextSemiBold = TextStyle(
  //     color: colorSubHeadingText,
  //     fontFamily: 'poppinssemibold',
  //     fontWeight: FontWeight.w300,
  //     fontSize: 13);
  //
  // static final TextStyle smallTextLight = TextStyle(
  //     color: colorSubHeadingText,
  //     fontFamily: 'poppinslight',
  //     fontWeight: FontWeight.normal,
  //     fontSize: 13);

  static final TextStyle button = TextStyle(
      color: primaryColor,
      fontWeight: FontWeight.w600,
      fontSize: 18,
      fontFamily: 'Montserrat');
  static final TextStyle labelStyle = TextStyle(
    color: labelColor,
    fontSize: 15,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w500,
  );
  static final TextStyle subButton = TextStyle(
      color: Colors.white, fontWeight: FontWeight.normal, fontSize: 14);
}

class AppTextStyle {
  AppTextStyle._();
  static const TextStyle normalblack = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: examtextcolor,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalSemiBold8 = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalRegular8 = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalRegular9 = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );

  static const TextStyle normalRegular10 = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalRegular11 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle questionAnswer = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textDark,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalSemiBold10 = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );

  static const TextStyle normalSemiBold11 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );

  static const TextStyle normalRegular12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: ironColor,
    fontFamily: 'Montserrat',
  );

  static const TextStyle normalSemiBold12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textDark,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalSemiBold32 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );

  static const TextStyle normalRegular13 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );

  static const TextStyle normalSemiBold13 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );

  static const TextStyle regularBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );

  static const TextStyle normalRegular14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
//2B3F4E
  static const TextStyle normalRegular15 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalRegular18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalRegular20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalRegular22 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalRegular24 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalRegular26 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );

  static const TextStyle italicRegular15 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );

  static const TextStyle normalSemiBold15 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );

  static const TextStyle normalRegular16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );

  static const TextStyle normalSemiBold16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );

  static const TextStyle normalWhiteSemiBold16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalBold14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalBold12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalBold10 = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalBold20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalBold16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalBold22 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalSemiBold17 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalRegular17 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalRegular34 = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalSemiBold18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle BigWord = TextStyle(
    fontFamily: "Montserrat",
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textDark,
  );
  static const TextStyle mediamcheeta = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: textDark,
    fontFamily: 'Montserrat',
  );
  static const TextStyle profileText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF344054),
    fontFamily: 'Montserrat',
  );

  static const TextStyle normalBold18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalBoldOrange18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: headingOrange,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalSemiBold20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );

  static const TextStyle normalSemiBold22 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalSemiBold24 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalSemiBold26 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalBold26 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalBold28 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalBold34 = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalBold40 = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalBold24 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalSemiBold14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ironColor,
    fontFamily: 'Montserrat',
  );
  static const TextStyle chatTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xff345C72),
    fontFamily: 'Montserrat',
  );
  static const TextStyle chatSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xff7F9091),
    fontFamily: 'Montserrat',
  );
  //7F9091
  static const TextStyle normalSemi14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ironColor,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalSemi12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: ironColor,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalSemiBold30 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalRegular30 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );
  static const TextStyle normalRegular38 = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w900,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );

  static const TextStyle normalRegular40 = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    fontFamily: 'Montserrat',
  );

  static const TextStyle normalRegular44 = TextStyle(
    fontSize: 44,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
}
