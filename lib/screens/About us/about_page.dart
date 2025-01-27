import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:get/get.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
          ),
          Container(
            height: 500,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/about.png'),
                fit: BoxFit.cover,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
                            "About us".tr,
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
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
                      "At Yokaizen, we merge manga, anime, and AI to create engaging mental health support for youth. Our AI-driven Yokai Companions, provide personalized guidance built on SEL and CBT principles. With the Yokaizen Ring, we deliver proactive, mood-based care anytime you need it. Our mission is to break the stigma around mental health by combining cultural storytelling with advanced technology, empowering the next generation to thrive. Join us and transform mental health support into a meaningful, stigma-free experience."
                          .tr,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.normalSemiBold12.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    3.ph,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset('icons/email2.svg'),
                        const SizedBox(width: 5),
                        Text(
                          'Email'.tr,
                          style: AppTextStyle.normalBold12
                              .copyWith(color: indigo700),
                        ),
                      ],
                    ),
                    2.ph,
                    Text(
                      'yokai@yokaizen.com',
                      style: AppTextStyle.normalSemiBold12.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Expanded(
                    //   child: Container(),
                    // ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: lightgrey, width: 1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Enjoying the app?'.tr,
                            style:
                                const TextStyle(color: coral500, fontSize: 16),
                          ),
                          Text(
                            'Would you mind rating us?'.tr,
                            style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.normal,
                                fontSize: 12),
                          ),
                          1.5.ph,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0), // Space between stars
                                child: SvgPicture.asset('icons/star.svg'),
                              );
                            }),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
