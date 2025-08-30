-- إنشاء جدول reportc مبسط
-- نفذ هذا في Supabase SQL Editor

-- حذف الجدول إذا كان موجوداً
DROP TABLE IF EXISTS reportc CASCADE;

-- إنشاء الجدول
CREATE TABLE reportc (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    type VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    location TEXT NOT NULL,
    image_url TEXT,
    legal_agreement_accepted BOOLEAN NOT NULL DEFAULT false,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID
);

-- إنشاء فهارس بسيطة
CREATE INDEX idx_reportc_type ON reportc(type);
CREATE INDEX idx_reportc_status ON reportc(status);
CREATE INDEX idx_reportc_created_at ON reportc(created_at);

-- تفعيل RLS
ALTER TABLE reportc ENABLE ROW LEVEL SECURITY;

-- سياسة بسيطة للسماح بالإدراج
CREATE POLICY "Allow inserts" ON reportc
    FOR INSERT WITH CHECK (true);

-- سياسة للقراءة
CREATE POLICY "Allow reads" ON reportc
    FOR SELECT USING (true);

-- اختبار إدراج بيانات
INSERT INTO reportc (type, description, location, legal_agreement_accepted, status)
VALUES ('اختبار', 'وصف اختبار', 'موقع اختبار', true, 'pending');

-- عرض البيانات
SELECT * FROM reportc; 