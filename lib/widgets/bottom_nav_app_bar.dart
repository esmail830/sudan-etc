// widgets/bottom_nav_app_bar.dart
import 'package:flutter/material.dart';

class BottomNavAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  const BottomNavAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      centerTitle: true,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed:
            onBackPressed ??
            () {
              // للصفحات التي هي جزء من BottomNavigationBar
              // نعود إلى الصفحة الرئيسية
              Navigator.of(context).pushReplacementNamed('/main');
            },
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
