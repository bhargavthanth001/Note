import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ResponsiveSize {
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double appBarHeight(BuildContext context) {
    return AppBar().preferredSize.height;
  }

  static double contentHeight(BuildContext context) {
    return appBarHeight(context) - screenHeight(context);
  }
}
