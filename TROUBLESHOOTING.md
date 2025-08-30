# استكشاف أخطاء Supabase

## 🚨 المشكلة: "حدث خطأ أثناء إرسال البلاغ"

### 1. **اختبار الاتصال**
- اضغط على أيقونة 🐛 في AppBar لاختبار الاتصال
- راجع Console logs للحصول على تفاصيل أكثر

### 2. **الخطوات الأساسية**

#### ✅ **تأكد من إعداد Supabase:**
1. اذهب إلى [supabase.com](https://supabase.com)
2. سجل دخول إلى مشروعك
3. تأكد من أن URL و API Key صحيحان

#### ✅ **تأكد من إنشاء الجداول:**
1. اذهب إلى SQL Editor
2. نفذ محتوى `database_schema.sql`
3. تأكد من إنشاء جدول `reportc`

#### ✅ **تأكد من إعداد Storage:**
1. اذهب إلى Storage
2. أنشئ bucket باسم `report_images`
3. اضبط السياسات للوصول

### 3. **الأخطاء الشائعة وحلولها**

#### ❌ **"relation 'reportc' does not exist"**
**المشكلة:** الجدول غير موجود
**الحل:**
```sql
-- نفذ هذا في SQL Editor
CREATE TABLE reportc (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    type VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    location TEXT NOT NULL,
    image_url TEXT,
    legal_agreement_accepted BOOLEAN NOT NULL DEFAULT false,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL
);
```

#### ❌ **"permission denied"**
**المشكلة:** مشكلة في RLS Policies
**الحل:**
```sql
-- تفعيل RLS
ALTER TABLE reportc ENABLE ROW LEVEL SECURITY;

-- إنشاء سياسات
CREATE POLICY "Anyone can create reports" ON reportc
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can view their own reports" ON reportc
    FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);
```

#### ❌ **"storage bucket not found"**
**المشكلة:** Storage bucket غير موجود
**الحل:**
1. اذهب إلى Storage
2. أنشئ bucket جديد باسم `report_images`
3. اضبط السياسات:
```sql
CREATE POLICY "Allow image uploads" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'report_images');

CREATE POLICY "Allow image downloads" ON storage.objects
    FOR SELECT USING (bucket_id = 'report_images');
```

### 4. **اختبار خطوة بخطوة**

#### **الخطوة 1: اختبار الاتصال**
```dart
// اضغط على أيقونة 🐛 في AppBar
// راجع Console logs
```

#### **الخطوة 2: اختبار الجدول**
```sql
-- في SQL Editor
SELECT * FROM reportc LIMIT 1;
```

#### **الخطوة 3: اختبار الإدراج**
```sql
-- في SQL Editor
INSERT INTO reportc (type, description, location, legal_agreement_accepted, status, created_at)
VALUES ('اختبار', 'وصف اختبار', 'موقع اختبار', true, 'pending', NOW());
```

### 5. **فحص Console Logs**

ابحث عن هذه الرسائل في Console:
```
بدء إرسال البلاغ...
نوع العطل: [النوع]
الوصف: [الوصف]
الموقع: [الموقع]
الصورة موجودة: [true/false]
محاولة الإدراج في جدول reportc...
```

### 6. **إعادة تشغيل التطبيق**

1. أغلق التطبيق تماماً
2. أعد تشغيله
3. جرب مرة أخرى

### 7. **طلب المساعدة**

إذا استمرت المشكلة:
1. انسخ رسالة الخطأ كاملة
2. انسخ Console logs
3. تأكد من إعداد Supabase
4. راجع ملف `SUPABASE_SETUP.md`

## 🔧 نصائح إضافية

- تأكد من الاتصال بالإنترنت
- تحقق من صحة URL و API Key
- راجع Supabase Dashboard للأخطاء
- تأكد من تفعيل جميع الخدمات 