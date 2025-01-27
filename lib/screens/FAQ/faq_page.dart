import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:get/get.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    SvgPicture.asset('icons/arrowLeft.svg'),
                    Text(
                      'FAQ\'s'.tr,
                      style:
                          AppTextStyle.normalBold20.copyWith(color: coral500),
                    ),
                  ],
                ),
              ),
              3.ph,
              Text(
                "1 What is Yokaizen?".tr,
                style: AppTextStyle.normalBold14,
              ),
              2.ph,
              Text(
                "Yokaizen is an innovative mental health platform designed to support Japanese youth through engaging manga, anime, and visual novel content enhanced by advanced artificial intelligence. Our AI-driven Yokai Companions provide personalized emotional support and guidance to help users navigate their mental well-being."
                    .tr,
                style: AppTextStyle.normalBold12
                    .copyWith(fontWeight: FontWeight.normal),
              ),
              3.ph,
              Text(
                "2. How does Yokaizen work?".tr,
                style: AppTextStyle.normalBold14,
              ),
              2.ph,
              Text(
                "Yokaizen combines culturally resonant storytelling with AI technology. Users interact with Yokai Companions through the app, which offer real-time emotional support based on Social-Emotional Learning (SEL) and Cognitive Behavioral Therapy (CBT) principles. Additionally, our Yokaizen Ring wearable device tracks your mood to provide proactive and tailored support."
                    .tr,
                style: AppTextStyle.normalBold12
                    .copyWith(fontWeight: FontWeight.normal),
              ),
              3.ph,
              Text(
                "3. What are Yokai Companions?".tr,
                style: AppTextStyle.normalBold14,
              ),
              2.ph,
              Text(
                "Yokai Companions are virtual entities inspired by traditional Japanese folklore. They serve as personalized assistants within the Yokaizen app, offering emotional support, guidance, and interactive activities to enhance your mental well-being."
                    .tr,
                style: AppTextStyle.normalBold12
                    .copyWith(fontWeight: FontWeight.normal),
              ),
              3.ph,
              Text(
                "4. What is the Yokaizen Ring?".tr,
                style: AppTextStyle.normalBold14,
              ),
              2.ph,
              Text(
                "The Yokaizen Ring is a wearable device that monitors your mood through biometric sensors. It integrates with the Yokaizen app to provide proactive support based on your emotional state, ensuring you receive timely assistance when needed."
                    .tr,
                style: AppTextStyle.normalBold12
                    .copyWith(fontWeight: FontWeight.normal),
              ),
              3.ph,
              Text(
                "5. Is Yokaizen available in languages other than Japanese?".tr,
                style: AppTextStyle.normalBold14,
              ),
              2.ph,
              Text(
                "Yes! While our primary focus is on the Japanese market, Yokaizen is built with a global mindset. We offer content in English to support youth worldwide, allowing our platform to reach an international audience."
                    .tr,
                style: AppTextStyle.normalBold12
                    .copyWith(fontWeight: FontWeight.normal),
              ),
              3.ph,
              Text(
                "6. How is my privacy protected on Yokaizen?".tr,
                style: AppTextStyle.normalBold14,
              ),
              2.ph,
              Text(
                "Your privacy is our top priority. Yokaizen employs advanced encryption and data protection measures to ensure that your personal information and interactions are secure. We adhere to all relevant privacy laws and regulations to safeguard your data."
                    .tr,
                style: AppTextStyle.normalBold12
                    .copyWith(fontWeight: FontWeight.normal),
              ),
              3.ph,
              Text(
                "7. How can I get started with Yokaizen?".tr,
                style: AppTextStyle.normalBold14,
              ),
              2.ph,
              Text(
                "Getting started is easy! Download the Yokaizen app from the App Store or Google Play, create an account, and begin your journey with your personalized Yokai Companion. You can also connect your Yokaizen Ring for enhanced mood tracking and support."
                    .tr,
                style: AppTextStyle.normalBold12
                    .copyWith(fontWeight: FontWeight.normal),
              ),
              3.ph,
              Text(
                "8. Is Yokaizen free to use?".tr,
                style: AppTextStyle.normalBold14,
              ),
              2.ph,
              Text(
                "Yokaizen offers a range of free features to support your mental well-being. We also provide premium content and advanced features through a subscription model to enhance your experience further."
                    .tr,
                style: AppTextStyle.normalBold12
                    .copyWith(fontWeight: FontWeight.normal),
              ),
              3.ph,
              Text(
                "9. How can I provide feedback or get support?".tr,
                style: AppTextStyle.normalBold14,
              ),
              2.ph,
              Text(
                "We value your feedback! You can reach out to our support team through the app or contact us directly at support@yokaizen.com. We are here to help you with any questions or concerns you may have."
                    .tr,
                style: AppTextStyle.normalBold12
                    .copyWith(fontWeight: FontWeight.normal),
              ),
              3.ph,
              Text(
                "10. How can creators collaborate with Yokaizen?".tr,
                style: AppTextStyle.normalBold14,
              ),
              2.ph,
              Text(
                "We welcome manga, anime, and visual novel creators to collaborate with us. By partnering with Yokaizen, you can showcase your content on our platform, contribute to mental health support, and benefit from our revenue-sharing model. For more information, please contact us at partnerships@yokaizen.com."
                    .tr,
                style: AppTextStyle.normalBold12
                    .copyWith(fontWeight: FontWeight.normal),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
//
// # include <stdio.h>

// void main () {
// int a=5 , int b=7 , int c=3
//   if (a>=b){
//     if (a>=c)
//     {
//       print ("a is greater");
//     }
//     else{
//       print ("c is grater");
//     }

//   }
//   if (b>=c)
//   {
//     print ("b is graeter");
//   }
//   else{
//     print ("c is grater");
//   }
// }