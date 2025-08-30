-- إنشاء جدول البلاغات
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
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    admin_notes TEXT,
    priority VARCHAR(20) DEFAULT 'medium',
    estimated_fix_time TIMESTAMP WITH TIME ZONE,
    assigned_technician VARCHAR(100),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(100)
);

-- إنشاء فهارس لتحسين الأداء
CREATE INDEX idx_reportc_user_id ON reportc(user_id);
CREATE INDEX idx_reportc_status ON reportc(status);
CREATE INDEX idx_reportc_created_at ON reportc(created_at);
CREATE INDEX idx_reportc_type ON reportc(type);

-- إنشاء جدول لتتبع تحديثات البلاغات
CREATE TABLE report_updates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    report_id UUID REFERENCES reportc(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL,
    notes TEXT,
    updated_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء جدول لأنواع الأعطال
CREATE TABLE report_types (
    id SERIAL PRIMARY KEY,
    name_ar VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    icon VARCHAR(50),
    color VARCHAR(7),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إدراج أنواع الأعطال الافتراضية
INSERT INTO report_types (name_ar, name_en, icon, color, description) VALUES
('انقطاع كهرباء', 'Power Outage', 'power_off', '#FF0000', 'انقطاع كامل للكهرباء في المنطقة'),
('ماس كهربائي', 'Electrical Short Circuit', 'electric_bolt', '#FFA500', 'ماس كهربائي أو شرارة'),
('ضعف في التيار', 'Weak Current', 'trending_down', '#FFD700', 'ضعف في قوة التيار الكهربائي'),
('أخرى', 'Other', 'more_horiz', '#808080', 'مشاكل أخرى غير مصنفة');

-- إنشاء RLS (Row Level Security) policies
ALTER TABLE reportc ENABLE ROW LEVEL SECURITY;
ALTER TABLE report_updates ENABLE ROW LEVEL SECURITY;

-- سياسة للقراءة: المستخدم يمكنه رؤية بلاغاته فقط
CREATE POLICY "Users can view their own reports" ON reportc
    FOR SELECT USING (auth.uid() = user_id);

-- سياسة للإدراج: أي شخص يمكنه إنشاء بلاغ
CREATE POLICY "Anyone can create reports" ON reportc
    FOR INSERT WITH CHECK (true);

-- سياسة للتحديث: المستخدم يمكنه تحديث بلاغاته فقط
CREATE POLICY "Users can update their own reports" ON reportc
    FOR UPDATE USING (auth.uid() = user_id);

-- سياسة لحذف: المستخدم يمكنه حذف بلاغاته فقط
CREATE POLICY "Users can delete their own reports" ON reportc
    FOR DELETE USING (auth.uid() = user_id);

-- إنشاء bucket لتخزين الصور
-- (يتم إنشاؤه من خلال Supabase Dashboard)

-- إنشاء function لتحديث updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- إنشاء trigger لتحديث updated_at
CREATE TRIGGER update_reportc_updated_at 
    BEFORE UPDATE ON reportc 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- إنشاء view لعرض البلاغات مع معلومات إضافية
CREATE VIEW reportc_with_details AS
SELECT 
    r.*,
    rt.name_ar as type_name_ar,
    rt.name_en as type_name_en,
    rt.icon as type_icon,
    rt.color as type_color
FROM reportc r
LEFT JOIN report_types rt ON r.type = rt.name_ar
WHERE rt.is_active = true;

-- إنشاء function لحساب إحصائيات البلاغات
CREATE OR REPLACE FUNCTION get_reportc_stats(user_uuid UUID DEFAULT NULL)
RETURNS TABLE(
    total_reports BIGINT,
    pending_reports BIGINT,
    in_progress_reports BIGINT,
    completed_reports BIGINT,
    cancelled_reports BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) as total_reports,
        COUNT(*) FILTER (WHERE status = 'pending') as pending_reports,
        COUNT(*) FILTER (WHERE status = 'in_progress') as in_progress_reports,
        COUNT(*) FILTER (WHERE status = 'completed') as completed_reports,
        COUNT(*) FILTER (WHERE status = 'cancelled') as cancelled_reports
    FROM reportc
    WHERE user_uuid IS NULL OR user_id = user_uuid;
END;
$$ LANGUAGE plpgsql; 