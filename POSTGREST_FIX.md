# حل مشكلة PostgrestException

## 🚨 المشكلة: PostgrestException

هذا الخطأ يعني أن هناك مشكلة في قاعدة البيانات PostgreSQL.

## 🔧 الحلول:

### **الحل 1: إنشاء الجدول المبسط**

1. اذهب إلى Supabase Dashboard
2. اذهب إلى SQL Editor
3. انسخ محتوى `simple_table_creation.sql`
4. نفذ الأوامر

### **الحل 2: فحص هيكل الجدول**

```sql
-- فحص الجداول الموجودة
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';

-- فحص هيكل جدول reportc
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'reportc';

-- فحص البيانات الموجودة
SELECT * FROM reportc LIMIT 5;
```

### **الحل 3: إصلاح الجدول**

```sql
-- إضافة أعمدة مفقودة
ALTER TABLE reportc 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- تحديث القيم الافتراضية
ALTER TABLE reportc 
ALTER COLUMN status SET DEFAULT 'pending';

-- إصلاح القيود
ALTER TABLE reportc 
ALTER COLUMN legal_agreement_accepted SET NOT NULL;
```

## 📋 خطوات التشخيص:

### **الخطوة 1: فحص Console Logs**
ابحث عن هذه الرسائل:
```
=== تفاصيل PostgrestException ===
الخطأ الكامل: [تفاصيل الخطأ]
نوع الخطأ: PostgrestException
رسالة الخطأ: [رسالة الخطأ]
```

### **الخطوة 2: تحديد نوع المشكلة**

#### **❌ "relation 'reportc' does not exist"**
- الجدول غير موجود
- **الحل:** نفذ `simple_table_creation.sql`

#### **❌ "column 'X' does not exist"**
- عمود مفقود
- **الحل:** أضف العمود المفقود

#### **❌ "null value in column 'X'"**
- قيمة فارغة في عمود مطلوب
- **الحل:** تأكد من ملء جميع الحقول

#### **❌ "permission denied"**
- مشكلة في الصلاحيات
- **الحل:** تأكد من RLS Policies

### **الخطوة 3: اختبار الإدراج**

```sql
-- اختبار إدراج بيانات
INSERT INTO reportc (type, description, location, legal_agreement_accepted, status)
VALUES ('اختبار', 'وصف اختبار', 'موقع اختبار', true, 'pending');

-- عرض النتيجة
SELECT * FROM reportc WHERE type = 'اختبار';

-- حذف البيانات التجريبية
DELETE FROM reportc WHERE type = 'اختبار';
```

## 🎯 الحل السريع:

1. **انسخ `simple_table_creation.sql`**
2. **نفذه في Supabase SQL Editor**
3. **أعد تشغيل التطبيق**
4. **جرب إرسال بلاغ جديد**

## ⚠️ ملاحظات مهمة:

- تأكد من أن Supabase يعمل
- تحقق من صحة URL و API Key
- راجع Console logs للتفاصيل
- تأكد من تفعيل RLS

## 📞 إذا استمرت المشكلة:

1. انسخ رسالة الخطأ كاملة
2. انسخ Console logs
3. راجع Supabase Dashboard
4. تأكد من إنشاء الجدول 