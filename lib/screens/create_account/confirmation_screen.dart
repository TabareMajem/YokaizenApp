// import 'package:yokai_quiz_app/screens/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yokai_quiz_app/Widgets/new_button.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/constants.dart';

import '../Authentication/login_screen.dart';
import '../navigation/view/navigation.dart';

class ConfirmationScreen extends StatefulWidget {
  final String title;
  final String message;
  final String email;
  final String buttonText;

  const ConfirmationScreen({
    Key? key,
    this.title = '',
    this.message = '',
    this.email = '',
    this.buttonText = '',
  }) : super(key: key);

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;
    double screenHeight = mediaQueryData.size.height;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth / 20),
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                  left: screenWidth / 3,
                  right: screenWidth / 3,
                  top: screenHeight / 12,
                ),
                child: SizedBox(
                  width: screenWidth / 2.6,
                  height: screenHeight / 9.1,
                  // decoration: const BoxDecoration(
                  //   image: DecorationImage(
                  //     image: AssetImage('images/appLogo_yokai.png'),
                  //   ),
                  // ),
                  child: Image.asset('images/appLogo_yokai.png'),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: screenHeight / 25),
                child: SvgPicture.asset('images/success_tick.svg'),
              ),
            ),
            SizedBox(height: screenHeight / 30),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: headingOrange,
                fontSize: 28,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                height: 0,
              ),
            ),
            if (widget.email.isNotEmpty) SizedBox(height: screenHeight / 30),
            if (widget.email.isNotEmpty)
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Reset Link Sent at ",
                      style: TextStyle(
                        color: Color(0xFF414749),
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: headingOrange,
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(
                      text: " this email",
                      style: TextStyle(
                        color: Color(0xFF414749),
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: screenHeight / 30),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF414749),
                fontSize: 15,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: constants.defaultPadding * 4.5),
            CustomButton(
              text: widget.buttonText,
              onPressed: () {
                if (widget.email.isEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return NavigationPage();
                      },
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return LoginScreen();
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
