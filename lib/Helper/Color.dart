import 'package:flutter/material.dart';

//colors class in all colors define
extension colors on ColorScheme {
  static MaterialColor primaryApp = const MaterialColor(
    0xffff3f4c,
    const <int, Color>{
      50: primary,
      100: primary,
      200: primary,
      300: primary,
      400: primary,
      500: primary,
      600: primary,
      700: primary,
      800: primary,
      900: primary,
    },
  );

  static const Color primary = Color(0xffff3f4c);
  static const Color tempboxColor = Color(0xffffffff);
  static const Color bgColor = Color(0xffEEEEEE);
  static const Color templightColor = Color(0xffE5E5E5);
  static const Color tempBorderColor = Color(0xff6B6B6B);
  static const Color lightBorderColor = Color(0xff92c4e);
  static const Color lightTextColor = Color(0xfffafafa);
  static const Color textFormFieldColor = Color(0xfff5f4f9);
  static const Color tempdarkColor = Color(0xff305599);
  static const Color darkBorderColor = Color(0xff629afe);
  static const Color darkColor1 = Color(0xff1a2e51);
  static const Color darkModeColor = Color(0xff102041);
  static const Color clearColor = Colors.transparent;
  static const Color blackColor = Colors.black;
  static const Color secondaryColor = Color(0xff102041);
  static const Color disabledColor = Color(0xffbebdc4);
  static const Color settingsIconClrL = Color(0xff5c5c5c);
  // static const Color settingsIconClrD = Color(0xff8db2f5);
  static const Color shadowColor = Color(0xff29000000);
  static const Color lightLikeContainerColor = Color(0xfff5f5f5);
  static const Color dartLikeContainerColor = Color(0xff1b325b);
  static const Color coverageUnSelColor = Color(0xff7b8cac);

  static const Color transparentColor = Colors.transparent;

  Color get borderColor =>
      this.brightness == Brightness.dark ? bgColor : tempBorderColor;

  Color get likeContainerColor => this.brightness == Brightness.dark
      ? dartLikeContainerColor
      : lightLikeContainerColor;

  Color get lightColor =>
      this.brightness == Brightness.dark ? secondaryColor : templightColor;

  Color get boxColor =>
      this.brightness == Brightness.dark ? dartLikeContainerColor : tempboxColor;

  Color get fontColor =>
      this.brightness == Brightness.dark ? bgColor : darkColor1;

  Color get darkColor =>
      this.brightness == Brightness.dark ? tempboxColor : tempdarkColor;

  Color get skipColor =>
      this.brightness == Brightness.dark ? bgColor : secondaryColor;

  Color get tabColor =>
      this.brightness == Brightness.dark ? primary : secondaryColor;

  /* Color get langSel =>
      this.brightness == Brightness.dark ? tempdarkColor : secondaryColor; */

  Color get agoLabel =>
      this.brightness == Brightness.dark ? darkBorderColor : tempBorderColor;

  Color get coverage =>
      this.brightness == Brightness.dark ? darkBorderColor : bgColor;

  Color get settingIconColor => this.brightness == Brightness.dark
      ? bgColor
      : settingsIconClrL; //settingsIconClrD

  Color get controlBGColor =>
      this.brightness == Brightness.dark ? darkColor1 : textFormFieldColor;

  Color get controlSettings =>
      this.brightness == Brightness.dark ? darkColor1 : tempboxColor;
}
