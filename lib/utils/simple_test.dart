// utils/simple_test.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SimpleTest {
  static Future<bool> testBasicConnection() async {
    try {
      print('اختبار الاتصال الأساسي...');

      // محاولة الوصول إلى Supabase client
      final client = Supabase.instance.client;
      print('✅ تم الوصول إلى Supabase client');

      // اختبار بسيط للاتصال
      final response = await client.from('reportc').select('count').limit(1);

      print('✅ تم الاتصال بقاعدة البيانات بنجاح');
      print('النتيجة: $response');

      return true;
    } catch (error) {
      print('❌ خطأ في الاتصال: $error');
      print('نوع الخطأ: ${error.runtimeType}');
      return false;
    }
  }

  static Future<void> printSupabaseInfo() async {
    try {
      print('=== معلومات Supabase ===');
      print(
        'Auth Status: ${Supabase.instance.client.auth.currentUser != null ? 'مستخدم مسجل' : 'لا يوجد مستخدم'}',
      );
      print('=======================');
    } catch (error) {
      print('❌ خطأ في طباعة المعلومات: $error');
    }
  }
}
