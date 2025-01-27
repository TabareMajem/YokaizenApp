import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final String iconSvgPath;
  final double width;
  final double? height;
  final double textSize;
  final Color colorSvg;
  final Color color;
  final Color colorText;
  final BoxBorder? border;
  final MainAxisAlignment mainAxisAlignment;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.iconSvgPath = '',
    this.width = double.infinity,
    this.height,
    this.textSize = 18,
    this.colorSvg = Colors.white,
    this.color = primaryColor,
    this.colorText = colorWhite,
    this.border,
    this.mainAxisAlignment =  MainAxisAlignment.center,
  }) : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: widget.border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: widget.color,
          borderRadius: BorderRadius.circular(50),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              widget.onPressed();
              setState(() {});
            },
            splashColor: headingOrange,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              height: (widget.height != null)
                  ? widget.height
                  : (widget.width > MediaQuery.of(context).size.width / 2)
                  ? 50
                  : 48,
              child: Row(
                mainAxisAlignment:widget.mainAxisAlignment,
                children: [
                  widget.iconSvgPath.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: SvgPicture.asset(
                            widget.iconSvgPath,
                            color: widget.colorSvg,
                            width: 25,
                            height: 25,
                          ),
                        )
                      : SizedBox(),
                  if(widget.iconSvgPath.isNotEmpty)
                    1.pw,
                  Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: widget.colorText,
                      fontSize: widget.textSize,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
