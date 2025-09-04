// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sudan_electricity_app/confirmation_screen.dart';
import 'package:sudan_electricity_app/otp_screen.dart';
import 'package:sudan_electricity_app/p_report_screens.dart';
import 'package:sudan_electricity_app/phone_auth_screen.dart';
import 'package:sudan_electricity_app/screens/home_screen.dart';
import 'package:sudan_electricity_app/screens/report_screen.dart';
import 'package:sudan_electricity_app/welcome_screens.dart';
import 'screens/general_report_screen.dart';
import 'screens/main_screen.dart';
import 'report_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "supabase api",
    anonKey:
        "api key",
  );

  // محاولة استعادة الجلسة عند بدء التطبيق
  try {
    final authService = AuthService();
    await authService.tryRestoreSession();
    print('[Main] تم فحص حالة تسجيل الدخول');
  } catch (e) {
    print('[Main] خطأ في فحص حالة تسجيل الدخول: $e');
  }

  // تهيئة خدمة الإشعارات
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
    print('[Main] تم تهيئة خدمة الإشعارات');
  } catch (e) {
    print('[Main] خطأ في تهيئة خدمة الإشعارات: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ar'),
      // استخدم الحزمة الكاملة من المفوضين لتضمين Cupertino تلقائياً
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // أضف الإنجليزية كبديل احتياطي بجانب العربية
      supportedLocales: const [Locale('ar'), Locale('en')],
      debugShowCheckedModeBanner: false,
      title: 'شركة الكهرباء السودانية',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.blue,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
      home: WelcomeScreens(),
      //home: MainScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreens(),
        '/phone_auth': (context) => PhoneAuthScreen(),
        '/otp': (context) => OtpScreen(),
        '/main': (context) => const MainScreen(),
        '/home': (context) => const HomeScreen(),
        '/confirmation': (context) => const ConfirmationScreen(),
        '/general_report': (context) => const GeneralReportScreen(),
        '/private_report': (context) => const PReportScreen(),
        '/report_status': (context) => const ReportScreen(),
        '/report': (context) => const ReportScree(),
      },
    );
  }
}
