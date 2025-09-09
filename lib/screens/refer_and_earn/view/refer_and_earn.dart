import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/Widgets/dashed_boarder_painter.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/refer_and_earn/controller/refer_and_earn.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

class ReferEarnPage extends StatefulWidget {
  const ReferEarnPage({super.key});

  @override
  State<ReferEarnPage> createState() => _ReferEarnPageState();
}

class _ReferEarnPageState extends State<ReferEarnPage> {
  @override
  void initState() {
    super.initState();
    isLoading(true);
    createAndRetrieveCode();
  }

  void createAndRetrieveCode() async {
    await ReferAndEarnController.createReferralCode().then((value) {
      isLoading(false);
    });
  }

  RxBool isLoading = false.obs;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Obx(() {
      return ProgressHUD(
        isLoading: isLoading.value,
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/about.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Row(
                              children: [
                                SvgPicture.asset('icons/arrowLeft.svg'),
                                const SizedBox(width: 8),
                                Text(
                                  "Refer & Earn".tr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: coral500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                  height: screenSize.height * 0.7,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Image.asset(
                            'images/appLogo_yokai.png',
                            height: 100,
                            width: 100,
                          ),
                          3.ph,
                          Text(
                            "Refer & Earn".tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: coral500,
                            ),
                          ),
                          1.ph,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            child: Text(
                              "Invite friends and get special perks and badges."
                                  .tr,
                              textAlign: TextAlign.center,
                              style: AppTextStyle.normalSemiBold10.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          3.ph,
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                      text: ReferAndEarnController
                                          .referralCode.value))
                                  .then((_) {
                                showSucessMessage(
                                    "Share to friends and earn".tr,
                                    colorSuccess);
                              });
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CustomPaint(
                                painter: DashedBorderPainter(),
                                child: Container(
                                  width: screenSize.width * 0.7,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            'Your referral code'.tr,
                                            style: AppTextStyle.normalSemiBold14
                                                .copyWith(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          Text(
                                            ReferAndEarnController
                                                .referralCode.value,
                                            style: AppTextStyle.normalSemiBold20
                                                .copyWith(
                                              color: coral500,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                            color: colorBlack),
                                      ),
                                      SizedBox(
                                        width: 50,
                                        child: Text(
                                          'Copy Code'.tr,
                                          style: AppTextStyle.normalSemiBold18
                                              .copyWith(
                                            color: coral500,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          4.ph,
                          Row(
                            children: [
                              SvgPicture.asset('icons/send.svg'),
                              const SizedBox(width: 8),
                              Text(
                                'Invite your friends to our app.'.tr,
                                style: AppTextStyle.normalBold12
                                    .copyWith(fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                          2.ph,
                          Row(
                            children: [
                              SvgPicture.asset('icons/notes2.svg'),
                              const SizedBox(width: 8),
                              Text(
                                'Your friend uses your referral code.'.tr,
                                style: AppTextStyle.normalBold12
                                    .copyWith(fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                          2.ph,
                          Row(
                            children: [
                              SvgPicture.asset('icons/gift.svg'),
                              const SizedBox(width: 8),
                              Text(
                                'You get special perks and badges.'.tr,
                                style: AppTextStyle.normalBold12
                                    .copyWith(fontWeight: FontWeight.w600),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
