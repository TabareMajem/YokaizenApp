import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yokai_quiz_app/util/colors.dart';

class SecondCustomButton extends StatefulWidget {
  final String text;
  // final VoidCallback onPressed;
  void Function()? onPressed;
  final String iconSvgPath;
  final double width;
  final double? height;
  final double textSize;
  final Color color;

  SecondCustomButton({
    Key? key,
    required this.text,
    // required this.onPressed,
    required this.onPressed,
    this.iconSvgPath = '',
    this.width = double.infinity,
    this.height,
    this.textSize = 18,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  _SecondCustomButtonState createState() => _SecondCustomButtonState();
}

class _SecondCustomButtonState extends State<SecondCustomButton> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          color: indigo700,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: indigo700),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: primaryColor,
          borderRadius: BorderRadius.circular(50),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onPressed,
            // onTap: () {
            //   widget.onPressed();
            //   setState(() {});
            // },
            splashColor: headingOrange,
            borderRadius: BorderRadius.circular(40),
            child: Container(
              height: (widget.height != null)
                  ? widget.height
                  : (widget.width > MediaQuery.of(context).size.width / 2)
                      ? 50
                      : 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.textSize,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.18,
                    ),
                  ),
                  widget.iconSvgPath.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: SvgPicture.asset(
                            widget.iconSvgPath,
                            color: widget.color,
                            width: 25,
                            height: 25,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
