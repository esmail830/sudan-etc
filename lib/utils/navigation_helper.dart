import 'package:flutter/material.dart';

class NavigationHelper {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // العودة إلى الصفحة الرئيسية في MainScreen
  static void goToHome(BuildContext context) {
    // البحث عن MainScreen في شجرة الـ widgets
    Navigator.of(context).pushReplacementNamed('/main');
  }
  
  // العودة إلى الصفحة السابقة
  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      goToHome(context);
    }
  }
}
