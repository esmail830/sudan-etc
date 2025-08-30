// widgets/smart_app_bar.dart
import 'package:flutter/material.dart';

class SmartAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const SmartAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      centerTitle: true,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed:
                    onBackPressed ??
                    () {
                      // منطق ذكي للعودة
                      // تحقق من نوع الصفحة الحالية
                      final route = ModalRoute.of(context);
                      if (route != null && route.isCurrent) {
                        // إذا كانت الصفحة الحالية هي جزء من BottomNavigationBar
                        // انتقل إلى الصفحة الرئيسية
                        Navigator.pushReplacementNamed(context, '/main');
                      } else if (Navigator.canPop(context)) {
                        // إذا كانت هناك صفحة سابقة، ارجع إليها
                        Navigator.pop(context);
                      } else {
                        // إذا لم تكن هناك صفحة سابقة، انتقل إلى الرئيسية
                        Navigator.pushReplacementNamed(context, '/main');
                      }
                    },
              )
              : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
