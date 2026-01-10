// File: lib/utils/responsive.dart

import 'package:flutter/material.dart';

class R {
  static double w(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * (percent / 100);
  }
  
  static double h(BuildContext context, double percent) {
    return MediaQuery.of(context).size.height * (percent / 100);
  }
  
  static double sp(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * (percent / 100);
  }
  
  static double fs(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * (percent / 100);
  }
}