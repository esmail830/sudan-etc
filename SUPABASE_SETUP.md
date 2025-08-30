# إعداد Supabase للتطبيق

## الخطوات المطلوبة:

### 1. إنشاء مشروع Supabase
- اذهب إلى [supabase.com](https://supabase.com)
- أنشئ حساب جديد أو سجل دخول
- أنشئ مشروع جديد
- احفظ URL و anon key

### 2. تحديث ملف التكوين
في ملف `lib/config/supabase_config.dart`:
```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
}
```

### 3. إنشاء قاعدة البيانات
- اذهب إلى SQL Editor في Supabase Dashboard
- انسخ محتوى ملف `database_schema.sql`
- نفذ الأوامر لإنشاء الجداول
- **ملاحظة**: اسم الجدول الرئيسي هو `reportc` (وليس `reports`)

### 4. إنشاء Storage Bucket
- اذهب إلى Storage في Supabase Dashboard
- أنشئ bucket جديد باسم `report_images`
- اضبط السياسات (policies) للوصول

### 5. إعداد Storage Policies
```sql
-- السماح برفع الصور
CREATE POLICY "Allow image uploads" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'report_images');

-- السماح بقراءة الصور
CREATE POLICY "Allow image downloads" ON storage.objects
    FOR SELECT USING (bucket_id = 'report_images');
```

### 6. اختبار التطبيق
- شغل التطبيق
- جرب إنشاء بلاغ جديد
- تحقق من إضافة البيانات في Supabase

## ملاحظات مهمة:
- تأكد من أن التطبيق متصل بالإنترنت
- تحقق من صحة URL و API key
- راجع logs في Supabase Dashboard للأخطاء
- تأكد من تفعيل RLS policies

## استكشاف الأخطاء:
إذا واجهت مشاكل:
1. تحقق من console logs
2. راجع Supabase Dashboard
3. تأكد من صحة البيانات المدخلة
4. تحقق من سياسات الأمان 