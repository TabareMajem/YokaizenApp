import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yokai_quiz_app/screens/assistance/chat/chat_screen.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:yokai_quiz_app/util/const.dart';

class YokaiAssistanceScreen extends StatefulWidget {
  const YokaiAssistanceScreen({super.key});

  @override
  State<YokaiAssistanceScreen> createState() => _YokaiAssistanceScreenState();
}

class _YokaiAssistanceScreenState extends State<YokaiAssistanceScreen> {
  int? selectedYokais;
  List yokaiList = [
    "images/yokai1.jpg",
    "images/yakai2.jpg",
    "images/yokai3.jpg",
    "images/yokai4.jpg",
  ];
  int selectedIndex = 0;
  @override
  initState() {
    _checkForYokai();
    super.initState();
  }

  _checkForYokai() async {
    Future.delayed(const Duration(milliseconds: 250)).then((v) async {
      if (constants.appYokaiPath == null) {
        await showCommonModelBottomSheet(context: context);
        setState(() {});
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: SvgPicture.asset(
                'icons/arrowLeft.svg',
                height: 35,
                width: 35,
              ),
            ),
            1.pw,
            Text(
              "Yokai Companion".tr,
              style: AppTextStyle.normalBold16.copyWith(
                color: coral500,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            Get.to(
              () => const ChatWithYokaiScreen(),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: const Color(0xFFEF5A20),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              "Talk with Yokai".tr,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .03,
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * .2,
                child: constants.appYokaiPath == null
                    ? Image.asset(
                        constants.appYokaiPath ?? "images/yokai_assistance.png",
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(constants.appYokaiPath!),
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .03,
            ),
            Container(
              height: 55,
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * .04,
              ),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color.fromRGBO(255, 242, 237, 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  commonContainer(
                    index: 0,
                    onTap: () {
                      selectedIndex = 0;
                      setState(() {});
                    },
                    title: "Overview".tr,
                  ),
                  commonContainer(
                    index: 1,
                    onTap: () {
                      selectedIndex = 1;
                      setState(() {});
                    },
                    title: "SEL Progress".tr,
                  ),
                  commonContainer(
                    index: 2,
                    onTap: () {
                      selectedIndex = 2;
                      setState(() {});
                    },
                    title: "CBT Progress".tr,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget commonContainer({
    VoidCallback? onTap,
    int? index,
    String? title,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width * .28,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: index == selectedIndex
                ? const Color(0xFFEF5A20)
                : Colors.transparent),
        alignment: Alignment.center,
        child: Text(
          title!,
          style: GoogleFonts.montserrat(
            color: index == selectedIndex ? AppColors.white : AppColors.black,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  showCommonModelBottomSheet({
    BuildContext? context,
  }) {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context!,
        backgroundColor: Colors.white,
        builder: (BuildContext context1) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * .65,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              width: 140,
                              height: 6,
                              decoration: BoxDecoration(
                                // shape: BoxShape.circle,
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xffB9C4C9),
                              ),
                            ),
                          ],
                        ),
                        // Row()
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Select Your Prefer YOKAI".tr,
                                style: GoogleFonts.getFont(
                                  'Rubik',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  height: 1,
                                  color: const Color(0xFF444C5C),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 33,
                                  width: 33,
                                  decoration: const BoxDecoration(
                                    color: Color(0xffB9C4C9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.black),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            imageDesign(
                                imageUrl: yokaiList[0],
                                index: 0,
                                onTap: () {
                                  setState(() {
                                    selectedYokais = 0;
                                  });
                                }),
                            imageDesign(
                                imageUrl: yokaiList[1],
                                index: 1,
                                onTap: () {
                                  setState(() {
                                    selectedYokais = 1;
                                  });
                                }),
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            imageDesign(
                                imageUrl: yokaiList[2],
                                index: 2,
                                onTap: () {
                                  setState(() {
                                    selectedYokais = 2;
                                  });
                                }),
                            imageDesign(
                                imageUrl: yokaiList[3],
                                index: 3,
                                onTap: () {
                                  setState(() {
                                    selectedYokais = 3;
                                  });
                                }),
                          ],
                        )
                      ],
                    ),
                    Visibility(
                      visible: selectedYokais != null ? true : false,
                      child: GestureDetector(
                        onTap: () async {
                          final pref = await SharedPreferences.getInstance();
                          pref.setString(
                              'yokaiImage', yokaiList[selectedYokais!]);
                          constants.appYokaiPath = yokaiList[selectedYokais!];
                          setState(() {});
                          Get.back(result: 1);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 25),
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: primaryColor),
                          alignment: Alignment.center,
                          child: Text(
                            "Continue",
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget imageDesign({String? imageUrl, int? index, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          border: Border.all(
            width: 4,
            color: index == selectedYokais ? primaryColor : Colors.white,
          ),
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(imageUrl!),
          ),
        ),
      ),
    );
  }
}
