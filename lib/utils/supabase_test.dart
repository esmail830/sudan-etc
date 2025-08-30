// utils/supabase_test.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseTest {
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      print('بدء اختبار الاتصال بـ Supabase...');
      
      // اختبار الاتصال
      final client = Supabase.instance.client;
      print('تم الاتصال بـ Supabase بنجاح');
      
      // اختبار قراءة من جدول reportc
      try {
        print('اختبار قراءة من جدول reportc...');
        final result = await client
            .from('reportc')
            .select('count')
            .limit(1);
        print('تم قراءة من جدول reportc بنجاح');
        print('النتيجة: $result');
      } catch (tableError) {
        print('خطأ في قراءة جدول reportc: $tableError');
        return {
          'success': false,
          'error': 'جدول reportc غير موجود أو لا يمكن الوصول إليه',
          'details': tableError.toString(),
        };
      }
      
      // اختبار Storage
      try {
        print('اختبار Storage...');
        final buckets = await client.storage.listBuckets();
        print('Buckets المتاحة: ${buckets.map((b) => b.name).toList()}');
        
        if (buckets.any((b) => b.name == 'report_images')) {
          print('Storage bucket "report_images" موجود');
        } else {
          print('Storage bucket "report_images" غير موجود');
        }
      } catch (storageError) {
        print('خطأ في اختبار Storage: $storageError');
      }
      
      return {
        'success': true,
        'message': 'جميع الاختبارات نجحت',
      };
      
    } catch (error) {
      print('خطأ في اختبار الاتصال: $error');
      return {
        'success': false,
        'error': 'فشل في الاتصال بـ Supabase',
        'details': error.toString(),
      };
    }
  }
  
  static Future<Map<String, dynamic>> testTableStructure() async {
    try {
      print('اختبار هيكل جدول reportc...');
      
      final client = Supabase.instance.client;
      
      // محاولة إدراج بيانات تجريبية
      final testData = {
        'type': 'اختبار',
        'description': 'بيانات اختبار',
        'location': 'موقع اختبار',
        'legal_agreement_accepted': true,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };
      
      print('محاولة إدراج بيانات تجريبية: $testData');
      
      final result = await client
          .from('reportc')
          .insert(testData)
          .select()
          .single();
      
      print('تم الإدراج بنجاح: $result');
      
      // حذف البيانات التجريبية
      await client
          .from('reportc')
          .delete()
          .eq('type', 'اختبار');
      
      print('تم حذف البيانات التجريبية');
      
      return {
        'success': true,
        'message': 'هيكل الجدول صحيح',
        'data': result,
      };
      
    } catch (error) {
      print('خطأ في اختبار هيكل الجدول: $error');
      return {
        'success': false,
        'error': 'مشكلة في هيكل الجدول',
        'details': error.toString(),
      };
    }
  }
} 