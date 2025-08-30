// services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
// Removed unused imports
import 'classifier_service.dart';
import 'notification_service.dart';

class PSupabaseService {
  static final PSupabaseService _instance = PSupabaseService._internal();
  factory PSupabaseService() => _instance;
  PSupabaseService._internal();

  SupabaseClient get _supabase => Supabase.instance.client;

  // لا نحتاج initialize() لأن Supabase يتم تهيئته في main.dart

  // إرسال بلاغ عطل جديد
  Future<Map<String, dynamic>> submitPReport({
    required String type,
    required String description,
    required String location,
    File? image,
    required bool legalAgreementAccepted,
  }) async {
    try {
      print('بدء إرسال البلاغ...');
      print('نوع العطل: $type');
      print('الوصف: $description');
      print('الموقع: $location');
      print('الصورة موجودة: ${image != null}');

      // رفع الصورة إذا كانت موجودة
      String? imageUrl;
      if (image != null) {
        try {
          print('بدء رفع الصورة...');
          final fileName =
              'reports/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
          print('اسم الملف: $fileName');

          await _supabase.storage
              .from('preport_images')
              .upload(fileName, image);
          print('تم رفع الصورة بنجاح');

          imageUrl = _supabase.storage
              .from('preport_images')
              .getPublicUrl(fileName);
          print('رابط الصورة: $imageUrl');
        } catch (imageError) {
          print('خطأ في رفع الصورة: $imageError');
          // نستمر بدون الصورة
        }
      }

      // استدعاء المصنف لتحديد الفني المسؤول (البلاغ العام)
      String? assignedTechnician;
      try {
        final classifier = ClassifierService();
        final result = await classifier.classifyReport(
          description: description,
          type: type,
          location: location,
        );
        // ignore: avoid_print
        print(
          '[Classifier] Assigned label (public): ' + (result?.label ?? 'null'),
        );
        if (result != null && result.label.isNotEmpty) {
          assignedTechnician = result.label;
          print(
            '[PSupabaseService] Using classifier result: $assignedTechnician',
          );
        } else {
          // إذا فشل Classifier، استخدم نوع العطل كتصنيف افتراضي
          assignedTechnician = type;
          print(
            '[PSupabaseService] Classifier failed, using fallback: $assignedTechnician',
          );
        }
      } catch (e) {
        // في حالة حدوث خطأ، استخدم نوع العطل كتصنيف افتراضي
        assignedTechnician = type;
        print(
          '[PSupabaseService] Classifier error, using fallback: $assignedTechnician',
        );
        print('[PSupabaseService] Error details: $e');
      }

      // إذا كان المستخدم مسجل دخول، امنع إرسال أكثر من بلاغ عام واحد غير مكتمل
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId != null) {
        final existing = await _supabase
            .from('preportc')
            .select('id,status')
            .eq('user_id', currentUserId)
            .not('status', 'in', ['completed,cancelled'])
            .limit(1);
        if (existing.isNotEmpty) {
          return {
            'success': false,
            'message': 'لديك بلاغ عام قيد المعالجة بالفعل',
          };
        }
      }

      // إدراج البيانات في جدول البلاغات
      final Map<String, dynamic> reportData = {
        'type': type,
        'description': description,
        'location': location,
        'image_url': imageUrl,
        'legal_agreement_accepted': legalAgreementAccepted,
        'status': 'قيد المعالجة', // حالة البلاغ
        'created_at': DateTime.now().toIso8601String(),
        if (assignedTechnician != null)
          'assigned_technician': assignedTechnician,
      };

      // ignore: avoid_print
      print(
        '[PSupabaseService] Payload for preportc: ' + reportData.toString(),
      );

      // إضافة user_id فقط إذا كان المستخدم مسجل دخول
      if (_supabase.auth.currentUser?.id != null) {
        reportData['user_id'] = _supabase.auth.currentUser!.id;
        print('معرف المستخدم: ${_supabase.auth.currentUser!.id}');
      } else {
        print('لا يوجد مستخدم مسجل دخول');
      }

      print('البيانات المرسلة: $reportData');
      print('محاولة الإدراج في جدول reportc...');

      final response =
          await _supabase.from('preportc').insert(reportData).select().single();

      print('تم الإدراج بنجاح: $response');

      // إشعار محلي داخل التطبيق للمستخدم (بلاغ عام)
      NotificationService().addNotification(
        AppNotification(
          title: 'تم استلام البلاغ (عام)',
          body:
              'رقم البلاغ: ' +
              (response['id']?.toString() ?? '-') +
              ' وسيتم معالجته قريباً',
          playSound: true,
          soundFile: 'success_notification.mp3',
        ),
      );

      return {
        'success': true,
        'data': response,
        'message': 'تم إرسال البلاغ بنجاح',
      };
    } catch (error) {
      print('خطأ في إرسال البلاغ: $error');
      print('نوع الخطأ: ${error.runtimeType}');

      // طباعة تفاصيل أكثر للـ PostgrestException
      if (error.runtimeType.toString().contains('PostgrestException')) {
        print('=== تفاصيل PostgrestException ===');
        print('الخطأ الكامل: $error');
        print('نوع الخطأ: ${error.runtimeType}');
        print('رسالة الخطأ: ${error.toString()}');
        print('===============================');
      }

      // رسائل خطأ أكثر تفصيلاً
      String errorMessage = 'حدث خطأ أثناء إرسال البلاغ';

      if (error.toString().contains('relation "preportc" does not exist')) {
        errorMessage =
            'جدول البلاغات غير موجود. تأكد من إنشاء الجدول في Supabase';
      } else if (error.toString().contains('column') &&
          error.toString().contains('does not exist')) {
        errorMessage = 'عمود مفقود في الجدول. تأكد من هيكل الجدول';
      } else if (error.toString().contains('null value in column') &&
          error.toString().contains('violates not-null constraint')) {
        errorMessage = 'قيمة فارغة في عمود مطلوب. تأكد من ملء جميع الحقول';
      } else if (error.toString().contains(
        'duplicate key value violates unique constraint',
      )) {
        errorMessage = 'قيمة مكررة. حاول مرة أخرى';
      } else if (error.toString().contains('foreign key constraint')) {
        errorMessage = 'مشكلة في العلاقة بين الجداول';
      } else if (error.toString().contains('permission denied')) {
        errorMessage = 'خطأ في الصلاحيات. تأكد من إعداد RLS Policies';
      } else if (error.toString().contains('storage')) {
        errorMessage = 'خطأ في رفع الصورة. تأكد من إعداد Storage Bucket';
      } else if (error.toString().contains('network')) {
        errorMessage = 'خطأ في الاتصال. تأكد من الاتصال بالإنترنت';
      } else if (error.toString().contains('PostgrestException')) {
        errorMessage = 'مشكلة في قاعدة البيانات. راجع Console logs للتفاصيل';
      }

      return {
        'success': false,
        'error': error.toString(),
        'message': errorMessage,
      };
    }
  }

  // جلب جميع البلاغات للمستخدم
  Future<List<Map<String, dynamic>>> getUserReports() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final response = await _supabase
          .from('preportc')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('فشل في جلب البلاغات: $error');
    }
  }

  // تحديث حالة البلاغ
  Future<bool> updateReportStatus(String reportId, String status) async {
    try {
      await _supabase
          .from('preportc')
          .update({'status': status})
          .eq('id', reportId);
      return true;
    } catch (error) {
      return false;
    }
  }
}
