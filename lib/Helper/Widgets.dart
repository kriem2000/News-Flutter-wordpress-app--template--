// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:news/Helper/String.dart';
// import 'package:flutter/widgets.dart';
// import 'package:news/Helper/Color.dart';
// import 'package:news/Helper/String.dart';

//backbutton
setBackButton(BuildContext context, Color color) {
  /* return IconButton(
    icon: Icon(Icons.arrow_back,
        color: color), //isDark! ? colors.bgColor : colors.secondaryColor),
    onPressed: () => Navigator.of(context).pop(),
    splashColor: Colors.transparent,
  ); */
  // print("Back Button - Ontap ");
  /* InkWell(
    onTap: () => Navigator.of(context).pop(),
    child: Container(
        padding: EdgeInsets.all(15),
        alignment: Alignment.centerLeft,
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: color,
        )),
  ); */
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.0),
    child: InkWell(
      onTap: () => Navigator.of(context).pop(),
      child: Icon(Icons.arrow_back, color: color),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    ),
  );
}

double ContainerHeight = deviceHeight! / 4.2;
