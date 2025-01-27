import 'package:flutter/material.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

import '../util/colors.dart';

class MyDropDown extends StatefulWidget {
  const MyDropDown({
    Key? key,
    required this.onChange,
    this.defaultValue,
    required this.array,
    this.margin,
    this.hintText,
    this.icon,
    this.enable = true,
    this.borderWidth = 2.0,
  }) : super(key: key);

  final Function(String?) onChange;
  final String? defaultValue;
  final List<String> array;
  final margin;
  final icon;
  final bool enable;
  final String? hintText;
  final double borderWidth;

  @override
  _MyDropDownState createState() => _MyDropDownState();
}

class _MyDropDownState extends State<MyDropDown> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.white,
        margin: widget.margin ?? const EdgeInsets.only(),
        semanticContainer: true,
        elevation: 0,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFE4E8E9), width: widget.borderWidth),
          borderRadius: constants.borderRadius,
        ),
        child: DropdownButton<String>(
          style: AppTextStyle.normalRegular10
              .copyWith(color: textColor2),
          value: selectedValue,
          dropdownColor: colortextfield,
          underline: Container(),
          hint: Padding(
            padding: const EdgeInsets.only(left: constants.defaultPadding),
            child: Text('${widget.hintText}',style: AppTextStyle.normalRegular10.copyWith(color: hintText),),
          ),
          padding: EdgeInsets.only(right: 10),
          icon: widget.icon ??
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: headingOrange,
                size: 25,
              ),
          isExpanded: true,
          items: widget.array.toSet().toList().map((String value) {
            return DropdownMenuItem<String>(
              // enabled: widget.enable,
              value: value,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: constants.defaultPadding,
                  right: constants.defaultPadding,
                ),
                child: Text(
                  value,
                    style: AppTextStyle.normalRegular10
                        .copyWith(color: textColor2),
                ),
              ),
            );
          }).toList(),
          onChanged: widget.enable
              ? (value) {
                  setState(() {
                    selectedValue = value;
                  });
                  widget.onChange(value);
                }
              : null,
        ),
      ),
    );
  }
}
