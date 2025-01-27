import 'package:flutter/material.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

class CustomInfoField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType inputType;
  final bool obscureText;
  final bool enable;
  final prefixIcon;
  final sufixIcon;
  final String obscuringCharacter;

  CustomInfoField({
    Key? key,
    required this.label,
    required this.controller,
    this.hint = '',
    this.inputType = TextInputType.text,
    this.obscureText = false,
    this.enable = true,
    this.prefixIcon,
    this.sufixIcon,
    this.obscuringCharacter = ".",
  }) : super(key: key);

  @override
  _CustomInfoFieldState createState() => _CustomInfoFieldState();
}

class _CustomInfoFieldState extends State<CustomInfoField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth > 600 ? 24 : 14;
    double fontSize = screenWidth > 600 ? 18 : 16;
    double hintFontSize = screenWidth > 600 ? 18 : 16;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: textStyle.labelStyle,
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: _focusNode.hasFocus
                      ? Color(0xFF1791C8)
                      : Color(0xFFE4E8E9),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              shadows: [
                if (_isFocused)
                  const BoxShadow(
                    color: Color(0xFFC6E6FF),
                    blurRadius: 0,
                    offset: Offset(0, 0),
                    spreadRadius: 3,
                  )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 24,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: TextField(
                            focusNode: _focusNode,
                            enabled: widget.enable,
                            controller: widget.controller,
                            keyboardType: widget.inputType,
                            obscureText: widget.obscureText,
                            obscuringCharacter: '●',
                            // style: TextStyle(fontSize: 20),
                            decoration: InputDecoration(
                              suffixIcon: widget.sufixIcon,
                              prefixIcon: widget.prefixIcon,
                              hintText: widget.hint,
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Color(0xFF556365),
                                fontSize: hintFontSize,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: widget.obscureText == true ? 7 : 10,
                                  horizontal: 10),
                              alignLabelWithHint: true,
                            ),
                            style: TextStyle(
                              color: Color(0xFF556365),
                              fontSize:
                                  (widget.obscureText == true) ? 30 : fontSize,
                              fontFamily: 'Montserrat',
                              // fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
