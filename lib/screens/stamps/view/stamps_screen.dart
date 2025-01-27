import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yokai_quiz_app/screens/stamps/controller/stamp_controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:get/get.dart';

class StampScreen extends StatefulWidget {
  const StampScreen({super.key});

  @override
  State<StampScreen> createState() => _StampScreenState();
}

class _StampScreenState extends State<StampScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  SvgPicture.asset('icons/arrowLeft.svg'),
                  Text(
                    "Stamps".tr,
                    style: AppTextStyle.normalBold20.copyWith(color: coral500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "My Stamps".tr,
              style: AppTextStyle.normalSemiBold32.copyWith(color: coral500),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: StampController.stamps.length,
              itemBuilder: (context, index) {
                final stamp = StampController.stamps[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: FittedBox(
                    fit: BoxFit.none,
                    child: Image.asset(
                      stamp['image'],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
