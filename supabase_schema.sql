-- =====================================================
-- صيدلي PRO - Supabase Schema
-- شغّل الكود ده في Supabase SQL Editor
-- =====================================================

-- جدول جلسات الإرسال (كل مرة الدكتور يبعت للمندوب)
CREATE TABLE IF NOT EXISTS rep_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_code TEXT UNIQUE NOT NULL,        -- الكود الفريد (8 أحرف)
  rep_name TEXT NOT NULL,                   -- اسم المندوب
  rep_phone TEXT,                           -- تليفون المندوب
  pharmacy_name TEXT DEFAULT 'صيدليتي',    -- اسم الصيدلية
  status TEXT DEFAULT 'pending',            -- pending / responded / closed
  created_at TIMESTAMPTZ DEFAULT NOW(),
  responded_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '24 hours')
);

-- جدول أصناف الجلسة (الأصناف اللي بعتها الدكتور)
CREATE TABLE IF NOT EXISTS session_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID REFERENCES rep_sessions(id) ON DELETE CASCADE,
  drug_name TEXT NOT NULL,
  company TEXT DEFAULT 'غير محدد',
  quantity INTEGER DEFAULT 1,
  is_private INTEGER DEFAULT 0,            -- الأصناف السرية مش بتتبعت
  -- رد المندوب
  is_available INTEGER,                    -- 1=متاح, 0=مش متاح, NULL=لم يرد
  price REAL,
  discount REAL DEFAULT 0,
  rep_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- جدول كود الرد (اللي بيدخله الدكتور في التطبيق)
CREATE TABLE IF NOT EXISTS response_codes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  response_code TEXT UNIQUE NOT NULL,      -- كود الرد (8 أحرف)
  session_id UUID REFERENCES rep_sessions(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- RLS Policies (السماح بالقراءة والكتابة بدون Auth)
-- =====================================================
ALTER TABLE rep_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE response_codes ENABLE ROW LEVEL SECURITY;

-- السماح للكل بالقراءة والكتابة (بنستخدم الكود كـ authentication)
CREATE POLICY "allow_all_rep_sessions" ON rep_sessions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_session_items" ON session_items FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_response_codes" ON response_codes FOR ALL USING (true) WITH CHECK (true);

-- =====================================================
-- Index للبحث السريع
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_sessions_code ON rep_sessions(session_code);
CREATE INDEX IF NOT EXISTS idx_response_code ON response_codes(response_code);
CREATE INDEX IF NOT EXISTS idx_items_session ON session_items(session_id);
