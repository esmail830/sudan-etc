-- إصلاح RLS Policies لجدول reportc
-- نفذ هذا في Supabase SQL Editor

-- 1. حذف السياسات الموجودة
DROP POLICY IF EXISTS "Allow inserts" ON reportc;
DROP POLICY IF EXISTS "Allow reads" ON reportc;
DROP POLICY IF EXISTS "Users can view their own reports" ON reportc;
DROP POLICY IF EXISTS "Anyone can create reports" ON reportc;
DROP POLICY IF EXISTS "Users can update their own reports" ON reportc;
DROP POLICY IF EXISTS "Users can delete their own reports" ON reportc;

-- 2. إنشاء سياسات جديدة صحيحة

-- سياسة للسماح بالإدراج (أي شخص يمكنه إنشاء بلاغ)
CREATE POLICY "Anyone can create reports" ON reportc
    FOR INSERT WITH CHECK (true);

-- سياسة للقراءة (أي شخص يمكنه قراءة البلاغات)
CREATE POLICY "Anyone can read reports" ON reportc
    FOR SELECT USING (true);

-- سياسة للتحديث (المستخدم يمكنه تحديث بلاغاته فقط)
CREATE POLICY "Users can update own reports" ON reportc
    FOR UPDATE USING (
        auth.uid() = user_id OR 
        user_id IS NULL
    );

-- سياسة للحذف (المستخدم يمكنه حذف بلاغاته فقط)
CREATE POLICY "Users can delete own reports" ON reportc
    FOR DELETE USING (
        auth.uid() = user_id OR 
        user_id IS NULL
    );

-- 3. التأكد من تفعيل RLS
ALTER TABLE reportc ENABLE ROW LEVEL SECURITY;

-- 4. اختبار السياسات
-- محاولة إدراج بيانات تجريبية
INSERT INTO reportc (type, description, location, legal_agreement_accepted, status)
VALUES ('اختبار RLS', 'اختبار السياسات', 'موقع اختبار', true, 'pending');

-- عرض البيانات
SELECT * FROM reportc WHERE type = 'اختبار RLS';

-- حذف البيانات التجريبية
DELETE FROM reportc WHERE type = 'اختبار RLS';

-- 5. عرض السياسات النشطة
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'reportc';
