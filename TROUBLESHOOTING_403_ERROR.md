# حل مشكلة خطأ 403 في Supabase Auth

## 🚨 المشكلة
```
خطأ 403: مشكلة في الصلاحيات (403). تأكد من صحة الرمز أو جرب مرة أخرى
```

## 🔍 أسباب خطأ 403

### 1. **مشكلة في إعدادات Supabase**
- عدم تفعيل Phone Auth
- مشكلة في RLS Policies
- عدم إعداد SMS Provider

### 2. **مشكلة في الكود**
- خطأ في URL أو API Key
- مشكلة في تنسيق رقم الهاتف
- مشكلة في إعدادات Auth

### 3. **مشكلة في الشبكة**
- حظر من Firewall
- مشكلة في DNS
- مشكلة في SSL

## ✅ الحلول المقترحة

### **الحل الأول: فحص إعدادات Supabase**

#### 1. تفعيل Phone Auth
```sql
-- في Supabase Dashboard > Authentication > Settings
-- تأكد من تفعيل "Enable phone confirmations"
```

#### 2. فحص RLS Policies
```sql
-- تأكد من وجود سياسات صحيحة
CREATE POLICY "Enable phone auth" ON auth.users
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can view own data" ON auth.users
    FOR SELECT USING (auth.uid() = id);
```

#### 3. إعداد SMS Provider
- اذهب إلى Authentication > Settings
- تأكد من إعداد SMS Provider (Twilio, MessageBird, etc.)
- تأكد من صحة API Keys

### **الحل الثاني: فحص الكود**

#### 1. التحقق من URL و API Key
```dart
// في lib/main.dart
await Supabase.initialize(
  url: "https://yryvvelcmymifkjtfenf.supabase.co", // تأكد من صحة URL
  anonKey: "your-anon-key-here", // تأكد من صحة API Key
);
```

#### 2. تنسيق رقم الهاتف
```dart
// تأكد من تنسيق رقم الهاتف
// يجب أن يكون بالشكل: +249123456789
String formatPhoneNumber(String phone) {
  if (!phone.startsWith('+')) {
    phone = '+249$phone'; // إضافة رمز السودان
  }
  return phone;
}
```

#### 3. إضافة headers إضافية
```dart
// في AuthService
final res = await _supabase.auth.verifyOTP(
  phone: phone,
  token: token,
  type: OtpType.sms,
  // إضافة headers إضافية
  headers: {
    'X-Client-Info': 'supabase-flutter/2.9.1',
  },
);
```

### **الحل الثالث: اختبار الاتصال**

#### 1. اختبار بسيط
```dart
// أضف هذا الكود في main.dart للاختبار
try {
  final response = await http.get(
    Uri.parse('https://yryvvelcmymifkjtfenf.supabase.co/rest/v1/'),
    headers: {
      'apikey': 'your-anon-key',
      'Authorization': 'Bearer your-anon-key',
    },
  );
  print('Status Code: ${response.statusCode}');
  print('Response: ${response.body}');
} catch (e) {
  print('Error: $e');
}
```

#### 2. اختبار Auth
```dart
// اختبار Auth Service
final authService = AuthService();
final result = await authService.sendOtp(phone: '+249123456789');
print('Result: $result');
```

## 🔧 خطوات الحل

### **الخطوة 1: فحص Supabase Dashboard**
1. اذهب إلى [supabase.com](https://supabase.com)
2. سجل دخول إلى مشروعك
3. اذهب إلى Authentication > Settings
4. تأكد من تفعيل Phone Auth
5. تحقق من إعدادات SMS Provider

### **الخطوة 2: فحص RLS Policies**
1. اذهب إلى SQL Editor
2. نفذ هذا الكود:
```sql
-- فحص السياسات الموجودة
SELECT * FROM pg_policies WHERE schemaname = 'auth';

-- إنشاء سياسات جديدة إذا لزم الأمر
CREATE POLICY "Enable phone auth" ON auth.users
    FOR INSERT WITH CHECK (true);
```

### **الخطوة 3: اختبار الكود**
1. أضف logging إضافي
2. اختبر مع أرقام هواتف مختلفة
3. تحقق من Console logs

### **الخطوة 4: فحص الشبكة**
1. تأكد من الاتصال بالإنترنت
2. اختبر من شبكة مختلفة
3. تحقق من Firewall

## 📱 اختبار الحل

### **1. اختبار إرسال OTP**
```bash
flutter run
# أدخل رقم هاتف صحيح
# تأكد من عدم ظهور خطأ 403
```

### **2. اختبار التحقق من OTP**
```bash
# أدخل رمز OTP المستلم
# تأكد من نجاح العملية
```

### **3. مراقبة Logs**
```bash
# راجع Console logs
# ابحث عن رسائل AuthService
```

## 🔍 استكشاف الأخطاء

### **إذا استمر خطأ 403:**

#### 1. فحص Supabase Status
- اذهب إلى [status.supabase.com](https://status.supabase.com)
- تحقق من حالة الخدمة

#### 2. فحص Project Settings
- تأكد من أن المشروع نشط
- تحقق من Billing Status

#### 3. فحص API Keys
- تأكد من صحة anon key
- تحقق من service_role key

#### 4. فحص Network
- اختبر من جهاز مختلف
- اختبر من شبكة مختلفة

## 📝 ملاحظات مهمة

- **خطأ 403 يعني Forbidden**: مشكلة في الصلاحيات
- **تحقق من إعدادات Supabase**: Phone Auth يجب أن يكون مفعل
- **تحقق من RLS Policies**: يجب أن تكون موجودة وصحيحة
- **تحقق من SMS Provider**: يجب أن يكون مُعد بشكل صحيح
- **تحقق من Network**: قد تكون مشكلة في الشبكة

## 🚀 إذا لم يعمل الحل

### **1. إنشاء مشروع جديد**
- أنشئ مشروع Supabase جديد
- اختبر مع الإعدادات الافتراضية

### **2. استخدام Auth UI**
- استخدم Supabase Auth UI بدلاً من الكود المخصص
- قد يحل المشاكل تلقائياً

### **3. التواصل مع الدعم**
- اذهب إلى [supabase.com/support](https://supabase.com/support)
- ارفع تفاصيل المشكلة

## 🎯 الخلاصة

خطأ 403 عادة ما يكون بسبب:
1. **عدم تفعيل Phone Auth** في Supabase
2. **مشكلة في RLS Policies**
3. **عدم إعداد SMS Provider**
4. **مشكلة في URL أو API Key**

اتبع الخطوات أعلاه لحل المشكلة! 🎉
