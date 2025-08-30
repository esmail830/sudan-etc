// screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../widgets/bottom_nav_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BottomNavAppBar(title: 'الإعدادات'),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: const Text('اللغة'),
              trailing: DropdownButton<String>(
                value: 'ar',
                items: const [
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (String? value) {
                  // TODO: Implement language change
                },
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('إشعارات'),
              trailing: Switch(
                value: true,
                onChanged: (bool value) {
                  // TODO: Implement notification toggle
                },
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text('عن التطبيق'),
              onTap: () {
                // TODO: Navigate to about screen
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('تسجيل الخروج'),
              onTap: () {
                Navigator.pushNamed(context, '/report_status');
              },
            ),
          ),
        ],
      ),
    );
  }
}
