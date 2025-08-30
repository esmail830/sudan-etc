import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SupabaseClient get _supabase => Supabase.instance.client;

  /// تنسيق رقم الهاتف
  String formatPhoneNumber(String phone) {
    // إزالة المسافات والرموز
    phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // إذا لم يبدأ بـ +، أضف رمز السودان
    if (!phone.startsWith('+')) {
      if (phone.startsWith('0')) {
        // إذا بدأ بـ 0، استبدله بـ +249
        phone = '+249${phone.substring(1)}';
      } else if (phone.startsWith('249')) {
        // إذا بدأ بـ 249، أضف +
        phone = '+$phone';
      } else {
        // إضافة رمز السودان +249
        phone = '+249$phone';
      }
    }
    
    print('[AuthService] رقم الهاتف المنسق: $phone');
    return phone;
  }

  /// إرسال رمز OTP
  Future<Map<String, dynamic>> sendOtp({required String phone}) async {
    try {
      // تنسيق رقم الهاتف
      final formattedPhone = formatPhoneNumber(phone);
      print('[AuthService] محاولة إرسال OTP إلى: $formattedPhone');
      
      // حفظ رقم الهاتف في SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_phone', formattedPhone);
      
      await _supabase.auth.signInWithOtp(
        phone: formattedPhone, 
        shouldCreateUser: true,
      );
      
      print('[AuthService] تم إرسال OTP بنجاح');
      return {'success': true, 'message': 'تم إرسال رمز التحقق إلى رقمك'};
    } catch (e) {
      print('[AuthService] خطأ في إرسال OTP: $e');
      print('[AuthService] نوع الخطأ: ${e.runtimeType}');
      
      // معالجة خاصة لخطأ 403
      if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
        print('[AuthService] خطأ 403: مشكلة في الصلاحيات');
        return {
          'success': false, 
          'message': 'خطأ في الصلاحيات (403). تأكد من صحة رقم الهاتف',
          'error_code': '403',
          'details': e.toString(),
        };
      }
      
      // معالجة أخطاء أخرى
      if (e.toString().contains('Invalid phone')) {
        return {
          'success': false, 
          'message': 'رقم الهاتف غير صحيح',
          'error_code': 'INVALID_PHONE',
        };
      }
      
      if (e.toString().contains('rate limit') || e.toString().contains('too many')) {
        return {
          'success': false, 
          'message': 'تم تجاوز الحد المسموح. انتظر قليلاً ثم جرب مرة أخرى',
          'error_code': 'RATE_LIMIT',
        };
      }
      
      if (e is AuthException) {
        return {
          'success': false, 
          'message': 'تعذر إرسال الرمز: ${e.message}',
          'error_code': 'AUTH_EXCEPTION',
          'details': e.toString(),
        };
      }
      
      return {
        'success': false, 
        'message': 'تعذر إرسال الرمز: $e',
        'error_code': 'UNKNOWN_ERROR',
        'details': e.toString(),
      };
    }
  }

  /// التحقق من رمز OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String token,
  }) async {
    try {
      // تنسيق رقم الهاتف
      final formattedPhone = formatPhoneNumber(phone);
      print('[AuthService] محاولة التحقق من OTP: $formattedPhone');
      print('[AuthService] رمز التحقق: $token');
      
      final res = await _supabase.auth.verifyOTP(
        phone: formattedPhone,
        token: token,
        type: OtpType.sms,
      );
      
      if (res.user != null) {
        // حفظ معلومات المستخدم في SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_id', res.user!.id);
        await prefs.setString('user_phone', formattedPhone);
        await prefs.setString('last_login', DateTime.now().toIso8601String());
        
        print('[AuthService] تم تسجيل الدخول بنجاح: ${res.user!.id}');
        
        return {
          'success': true,
          'message': 'تم التحقق بنجاح',
          'user': res.user,
        };
      }
      return {'success': false, 'message': 'رمز غير صالح أو منتهي'};
    } catch (e) {
      print('[AuthService] خطأ في التحقق من OTP: $e');
      print('[AuthService] نوع الخطأ: ${e.runtimeType}');
      
      // معالجة خاصة لخطأ 403
      if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
        print('[AuthService] خطأ 403: مشكلة في الصلاحيات');
        return {
          'success': false, 
          'message': 'خطأ في الصلاحيات (403). تأكد من صحة الرمز أو جرب مرة أخرى',
          'error_code': '403',
          'details': e.toString(),
        };
      }
      
      // معالجة أخطاء أخرى
      if (e.toString().contains('Invalid OTP') || e.toString().contains('expired')) {
        return {
          'success': false, 
          'message': 'رمز التحقق غير صالح أو منتهي الصلاحية',
          'error_code': 'INVALID_OTP',
        };
      }
      
      if (e.toString().contains('rate limit') || e.toString().contains('too many')) {
        return {
          'success': false, 
          'message': 'تم تجاوز الحد المسموح. انتظر قليلاً ثم جرب مرة أخرى',
          'error_code': 'RATE_LIMIT',
        };
      }
      
      return {
        'success': false, 
        'message': 'فشل التحقق: $e',
        'error_code': 'UNKNOWN_ERROR',
        'details': e.toString(),
      };
    }
  }

  /// التحقق من حالة تسجيل الدخول
  Future<bool> isLoggedIn() async {
    try {
      // أولاً، تحقق من Supabase
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        // تحديث SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_id', currentUser.id);
        await prefs.setString('last_login', DateTime.now().toIso8601String());
        return true;
      }
      
      // إذا لم يكن هناك مستخدم في Supabase، تحقق من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      if (isLoggedIn) {
        // محاولة استعادة الجلسة
        try {
          await _supabase.auth.recoverSession(_supabase.auth.currentSession?.accessToken ?? '');
          return true;
        } catch (e) {
          print('[AuthService] فشل في استعادة الجلسة: $e');
          // مسح البيانات المحفوظة
          await prefs.clear();
          return false;
        }
      }
      
      return false;
    } catch (e) {
      print('[AuthService] خطأ في التحقق من حالة تسجيل الدخول: $e');
      return false;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      // تسجيل الخروج من Supabase
      await _supabase.auth.signOut();
      
      // مسح البيانات المحفوظة
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      print('[AuthService] تم تسجيل الخروج بنجاح');
    } catch (e) {
      print('[AuthService] خطأ في تسجيل الخروج: $e');
    }
  }

  /// الحصول على معرف المستخدم الحالي
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  /// الحصول على رقم الهاتف المحفوظ
  Future<String?> getSavedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_phone');
  }

  /// الحصول على آخر وقت تسجيل دخول
  Future<DateTime?> getLastLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLogin = prefs.getString('last_login');
    if (lastLogin != null) {
      return DateTime.tryParse(lastLogin);
    }
    return null;
  }

  /// التحقق من صلاحية الجلسة
  Future<bool> isSessionValid() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return false;
      
      // التحقق من أن الجلسة لم تنتهي
      final session = _supabase.auth.currentSession;
      if (session == null) return false;
      
      // التحقق من أن الجلسة لم تنتهي صلاحيتها
      final now = DateTime.now();
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
      
      if (now.isAfter(expiresAt)) {
        print('[AuthService] انتهت صلاحية الجلسة');
        await signOut();
        return false;
      }
      
      return true;
    } catch (e) {
      print('[AuthService] خطأ في التحقق من صلاحية الجلسة: $e');
      return false;
    }
  }

  /// محاولة استعادة الجلسة تلقائياً
  Future<bool> tryRestoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      if (!isLoggedIn) return false;
      
      // محاولة استعادة الجلسة من Supabase
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        print('[AuthService] تم استعادة الجلسة بنجاح');
        return true;
      }
      
      // إذا لم تنجح الاستعادة، مسح البيانات
      await prefs.clear();
      return false;
    } catch (e) {
      print('[AuthService] خطأ في استعادة الجلسة: $e');
      return false;
    }
  }
}
