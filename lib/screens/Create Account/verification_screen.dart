import 'dart:async';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:yokai_quiz_app/Widgets/new_button.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/Create Account/confirmation_screen.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

// import '../Authentication/firebase_auth.dart';

class OtpPage extends StatefulWidget {
  String phoneNumber;
  bool isUpdate;
  String verificationid;
  String IDS;

  OtpPage(this.phoneNumber, this.isUpdate, this.verificationid, this.IDS);

  @override
  _OtpPageState createState() => _OtpPageState(phoneNumber);
}

class _OtpPageState extends State<OtpPage> {
  // late User user;
  var roomImage = [];
  int randomNumber = 0;
  TextEditingController otpController = TextEditingController();

  String currentText = "";
  final formKey = GlobalKey<FormState>();
  String phoneNumber = "";

  _OtpPageState(this.phoneNumber);

  late Timer _timer;
  int _start = 120;
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _isResendEnabled = true;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void _restartTimer() {
    setState(() {
      _start = 120;
      _isResendEnabled = false;
    });
    _startTimer();
  }

  String _formatTime(int time) {
    int minutes = time ~/ 60;
    int seconds = time % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;
    double screenHeight = mediaQueryData.size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth / 20),
          child: Column(
            children: [
              Center(
                  child: Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth / 3.5,
                          right: screenWidth / 3.5,
                          top: screenHeight / 13),
                      child: SizedBox(
                        // width: 150,
                        width: screenWidth / 1.6,
                        // height: 95,
                        height: screenHeight / 8.1,
                        // decoration: const BoxDecoration(
                        //     image: DecorationImage(
                        //   image: AssetImage('images/applogo_yokai.svg'),
                        // )),
                        child: SvgPicture.asset('images/applogo_yokai.svg'),
                      ))),
              SizedBox(height: screenHeight / 30),
              Center(
                  child: Text(
                'Verification',
                textAlign: TextAlign.center,
                style: AppTextStyle.normalBold22.copyWith(color: headingOrange),
              )),
              2.ph,
              const Padding(
                padding: EdgeInsets.only(top: 22, left: 18, right: 18),
                child: Text(
                  "Enter the OTP sent on your phone number.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey),
                ),
              ),
              SizedBox(
                height: screenHeight / 25,
              ),
              Form(
                key: formKey,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 11.0, horizontal: 18),
                    child: Column(
                      children: [
                        PinCodeTextField(
                          appContext: context,
                          pastedTextStyle: const TextStyle(
                            color: Color(0xffEAECF0),
                            fontWeight: FontWeight.bold,
                          ),
                          length: 6,
                          obscureText: false,
                          blinkWhenObscuring: true,
                          animationType: AnimationType.fade,
                          validator: (v) {
                            if (v!.length < 6) {
                              return "Enter correct OTP";
                            } else {
                              return null;
                            }
                          },
                          pinTheme: PinTheme(
                              activeColor: const Color(0xffEAECF0),
                              inactiveColor: const Color(0xffEAECF0),
                              inactiveFillColor: const Color(0xffEAECF0),
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(5),
                              fieldHeight: 45,
                              fieldWidth: 45,
                              activeFillColor: const Color(0xffEAECF0),
                              selectedFillColor: const Color(0xffEAECF0),
                              selectedColor: const Color(0xff5A9DB6)),
                          cursorColor: Colors.black,
                          animationDuration: const Duration(milliseconds: 300),
                          enableActiveFill: true,
                          // errorAnimationController: errorController,
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          boxShadows: const [
                            BoxShadow(
                              offset: Offset(0, 1),
                              color: Colors.black12,
                              blurRadius: 10,
                            )
                          ],
                          onCompleted: (v) {},
                          onChanged: (value) {
                            customPrint(value);
                            setState(() {
                              currentText = value;
                            });
                          },
                          beforeTextPaste: (text) {
                            customPrint("Allowing to paste $text");
                            return true;
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(_start),
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                color: Color(0xff9DA4B2),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              // onTap: _isResendEnabled
                              //     ? () {
                              //         customPrint("Resend OTP${phoneNumber}");
                              //         AuthService.verifyPhoneNumber(
                              //             phoneNumber, context);
                              //         showSucessMessage(context, "OTP Request Send",);
                              //         _restartTimer(); // Restart the timer when the button is tapped
                              //       }
                              //     : null,
                              child: Text(
                                ' Resend OTP',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: _isResendEnabled
                                      ? headingOrange
                                      : Colors.grey,
                                  // Adjust color based on enabled/disabled state
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: constants.defaultPadding * 3.5,
                        ),
                        CustomButton(
                          text: "Verify",
                          onPressed: () async {
                            nextPage(
                              ConfirmationScreen(
                                title: 'Account Created!',
                                message:
                                    'We’ve sent you an email to confirm the details of your account.',
                                buttonText: 'Start Reading',
                              ),
                            );
                            // if (GlobalApi.WhichScreen == 0) {
                            //   PhoneAuthCredential credential =
                            //       PhoneAuthProvider.credential(
                            //     verificationId: widget.verificationid,
                            //     smsCode: otpController.text,
                            //   );
                            //   await FirebaseAuth.instance
                            //       .signInWithCredential(credential)
                            //       .then((value) => nextPage(PasswordResetScreen(
                            //             studentid: widget.IDS,
                            //           )));
                            // } else if (GlobalApi.WhichScreen == 1) {
                            //   try {
                            //     PhoneAuthCredential credential =
                            //         PhoneAuthProvider.credential(
                            //       verificationId: widget.verificationid,
                            //       smsCode: otpController.text,
                            //     );
                            //     await FirebaseAuth.instance
                            //         .signInWithCredential(credential)
                            //         .then(
                            //           (value) => widget.isUpdate
                            //               ? nextPage(
                            //                   ConfirmationScreen(
                            //                     title: 'Phone No. Updated',
                            //                     message:
                            //                         'You will receive future updates,\nmessages and OTPs on this\nnumber: +255 324239534234',
                            //                     buttonText: 'Okay',
                            //                   ),
                            //                 )
                            //               : nextPage(
                            //                   ConfirmationScreen(
                            //                     title: 'Account Created!',
                            //                     message:
                            //                         'We’ve sent you an email to confirm the details of your account.',
                            //                     buttonText: 'Start Learning',
                            //                   ),
                            //                 ),
                            //         );
                            //   } catch (ex) {
                            //     // log(ex.toString() as num);
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //       SnackBar(
                            //         content:
                            //             Text('Please enter the correct OTP'),
                            //       ),
                            //     );
                            //   }
                            // }
                          },
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
