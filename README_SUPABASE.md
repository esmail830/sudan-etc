# دليل استخدام Supabase في تطبيق الكهرباء السودانية

## ✅ ما تم إضافته:

### 1. ملفات التكوين
- `lib/config/supabase_config.dart` - إعدادات Supabase
- `lib/services/supabase_service.dart` - خدمة التعامل مع قاعدة البيانات
- `lib/models/report_model.dart` - نموذج البيانات

### 2. قاعدة البيانات
- `database_schema.sql` - مخطط قاعدة البيانات
- جداول: `reportc`, `report_updates`, `report_types`
- سياسات أمان (RLS) مفعلة

### 3. الميزات
- ✅ إرسال بلاغات جديدة
- ✅ رفع الصور
- ✅ تخزين البيانات في Supabase
- ✅ إدارة حالات البلاغات
- ✅ أمان البيانات

## 🚀 كيفية الاستخدام:

### 1. تحديث التكوين
```dart
// في lib/config/supabase_config.dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_KEY_HERE';
}
```

### 2. إنشاء قاعدة البيانات
- انسخ محتوى `database_schema.sql`
- نفذه في Supabase SQL Editor

### 3. إنشاء Storage Bucket
- اسم: `report_images`
- سياسات: السماح بالرفع والقراءة

### 4. اختبار التطبيق
- شغل التطبيق
- جرب إنشاء بلاغ جديد
- تحقق من إضافة البيانات

## 📱 الميزات المتاحة:

### إرسال بلاغ:
```dart
final supabaseService = SupabaseService();
final result = await supabaseService.submitReport(
  type: 'انقطاع كهرباء',
  description: 'وصف العطل',
  location: 'الموقع',
  image: selectedImage, // اختياري
  legalAgreementAccepted: true,
);
```

### جلب البلاغات:
```dart
final reports = await supabaseService.getUserReports();
```

### تحديث الحالة:
```dart
await supabaseService.updateReportStatus('report_id', 'completed');
```

## 🔒 الأمان:
- RLS مفعل لجميع الجداول
- المستخدم يرى بلاغاته فقط
- أي شخص يمكنه إنشاء بلاغ جديد
- الصور محمية بسياسات Storage

## 📊 البيانات المخزنة:
- نوع العطل
- الوصف
- الموقع
- رابط الصورة
- الموافقة القانونية
- الحالة
- التاريخ والوقت
- معرف المستخدم (إذا كان مسجل)

## 🛠️ استكشاف الأخطاء:
1. تحقق من صحة URL و API key
2. راجع console logs
3. تحقق من Supabase Dashboard
4. تأكد من إنشاء الجداول
5. تحقق من سياسات Storage

## 📞 الدعم:
إذا واجهت مشاكل:
1. راجع ملف `SUPABASE_SETUP.md`
2. تحقق من logs
3. راجع Supabase Dashboard
4. تأكد من صحة البيانات 