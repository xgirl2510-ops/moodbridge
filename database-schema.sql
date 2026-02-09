-- MoodBridge Database Schema
-- PostgreSQL / Supabase

-- ============================================
-- USERS & AUTH
-- ============================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    display_name VARCHAR(50) NOT NULL,
    avatar_url TEXT,
    anonymous_id VARCHAR(20) NOT NULL UNIQUE, -- "Người lạ #1234"
    
    -- Privacy settings
    receive_encouragements BOOLEAN DEFAULT true,
    show_mood_note BOOLEAN DEFAULT false,
    
    -- Notification settings
    push_enabled BOOLEAN DEFAULT true,
    checkin_reminder_enabled BOOLEAN DEFAULT true,
    checkin_reminder_time TIME DEFAULT '09:00',
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_banned BOOLEAN DEFAULT false
);

-- ============================================
-- MOOD CHECK-INS
-- ============================================

CREATE TYPE mood_type AS ENUM ('happy', 'sad');

CREATE TABLE checkins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    mood mood_type NOT NULL,
    note TEXT, -- Optional note (max 200 chars)
    
    -- Matching status (for sad users)
    wants_encouragement BOOLEAN DEFAULT true,
    matched_count INT DEFAULT 0, -- How many happy users saw this
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- One check-in per day per user
    UNIQUE (user_id, DATE(created_at))
);

CREATE INDEX idx_checkins_mood_date ON checkins(mood, created_at DESC);
CREATE INDEX idx_checkins_user_date ON checkins(user_id, created_at DESC);

-- ============================================
-- ENCOURAGEMENTS (Messages)
-- ============================================

CREATE TYPE message_type AS ENUM ('text', 'template', 'voice', 'sticker');

CREATE TABLE encouragements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Link to check-ins
    sender_checkin_id UUID REFERENCES checkins(id),
    receiver_checkin_id UUID REFERENCES checkins(id),
    
    -- Message content
    message_type message_type NOT NULL DEFAULT 'text',
    content TEXT, -- Text content or template ID
    media_url TEXT, -- For voice notes or stickers
    
    -- Status
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Prevent spam: 1 message per sender-receiver pair per day
    UNIQUE (sender_id, receiver_id, DATE(created_at))
);

CREATE INDEX idx_encouragements_receiver ON encouragements(receiver_id, created_at DESC);
CREATE INDEX idx_encouragements_sender ON encouragements(sender_id, created_at DESC);

-- ============================================
-- REACTIONS
-- ============================================

CREATE TYPE reaction_type AS ENUM ('thanks', 'feeling_better', 'want_to_chat');

CREATE TABLE reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    encouragement_id UUID NOT NULL REFERENCES encouragements(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    reaction reaction_type NOT NULL,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- One reaction per encouragement per user
    UNIQUE (encouragement_id, user_id)
);

-- ============================================
-- CONNECTIONS (When both agree to chat)
-- ============================================

CREATE TYPE connection_status AS ENUM ('pending', 'accepted', 'rejected', 'blocked');

CREATE TABLE connections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    requester_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Originated from which encouragement
    encouragement_id UUID REFERENCES encouragements(id),
    
    status connection_status DEFAULT 'pending',
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE (requester_id, receiver_id)
);

CREATE INDEX idx_connections_status ON connections(status, created_at DESC);

-- ============================================
-- CHAT MESSAGES (1-1 after connection)
-- ============================================

CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    connection_id UUID NOT NULL REFERENCES connections(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    message_type message_type NOT NULL DEFAULT 'text',
    content TEXT,
    media_url TEXT,
    
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_chat_messages_connection ON chat_messages(connection_id, created_at DESC);

-- ============================================
-- TEMPLATES (Pre-written encouragement messages)
-- ============================================

CREATE TABLE templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    emoji VARCHAR(10),
    content TEXT NOT NULL,
    category VARCHAR(50),
    
    usage_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed templates
INSERT INTO templates (emoji, content, category) VALUES
('💪', 'Bạn làm được! Mình tin bạn!', 'motivation'),
('🌈', 'Ngày mai sẽ tốt hơn! Hãy kiên nhẫn với bản thân nhé.', 'hope'),
('🤗', 'Mình ở đây nếu bạn cần nói chuyện. Bạn không cô đơn đâu.', 'support'),
('☀️', 'Sau cơn mưa trời lại sáng. Gửi bạn nhiều năng lượng tích cực!', 'hope'),
('🌸', 'Hãy cho phép bản thân được buồn, rồi mọi thứ sẽ ổn thôi.', 'comfort'),
('🎯', 'Mỗi ngày là một cơ hội mới. Bạn đang làm tốt lắm rồi!', 'motivation'),
('💕', 'Gửi bạn một cái ôm ấm áp. Take your time.', 'comfort'),
('🌟', 'Bạn mạnh mẽ hơn bạn nghĩ đó!', 'motivation');

-- ============================================
-- STICKERS
-- ============================================

CREATE TABLE stickers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    name VARCHAR(100),
    url TEXT NOT NULL,
    pack_id UUID,
    
    is_premium BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- BADGES & GAMIFICATION
-- ============================================

CREATE TABLE badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    code VARCHAR(50) UNIQUE NOT NULL, -- 'first_send', '5_day_streak', etc.
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url TEXT,
    
    requirement_type VARCHAR(50), -- 'sends', 'streak', 'helped', etc.
    requirement_value INT,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    badge_id UUID NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
    
    earned_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE (user_id, badge_id)
);

-- Seed badges (Theme: Thiên Thần Lan Tỏa 👼)
INSERT INTO badges (code, name, description, icon_url, requirement_type, requirement_value) VALUES
('first_send', 'Thiên Thần Nhỏ', 'Gửi lời động viên đầu tiên', '🌟', 'sends', 1),
('5_day_streak', 'Thiên Thần Kiên Nhẫn', '5 ngày liên tiếp gửi động viên', '😇', 'streak', 5),
('10_helped', 'Thiên Thần Lan Tỏa', 'Giúp 10 người vui hơn', '👼', 'helped', 10),
('30_day_streak', 'Thiên Thần Thủ Hộ', '30 ngày liên tiếp', '🕊️', 'streak', 30),
('50_helped', 'Tổng Thiên Thần', 'Giúp 50 người vui hơn', '👑', 'helped', 50);

-- ============================================
-- USER STATS (Aggregated for performance)
-- ============================================

CREATE TABLE user_stats (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    
    total_checkins INT DEFAULT 0,
    happy_days INT DEFAULT 0,
    sad_days INT DEFAULT 0,
    
    total_sent INT DEFAULT 0, -- Encouragements sent
    total_received INT DEFAULT 0, -- Encouragements received
    people_helped INT DEFAULT 0, -- People who reacted 'feeling_better'
    
    current_streak INT DEFAULT 0, -- Days in a row sending
    longest_streak INT DEFAULT 0,
    last_send_date DATE,
    
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- REPORTS (For moderation)
-- ============================================

CREATE TYPE report_status AS ENUM ('pending', 'reviewed', 'resolved', 'dismissed');
CREATE TYPE report_reason AS ENUM ('spam', 'harassment', 'inappropriate', 'other');

CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    reporter_id UUID NOT NULL REFERENCES users(id),
    reported_user_id UUID REFERENCES users(id),
    reported_message_id UUID REFERENCES encouragements(id),
    
    reason report_reason NOT NULL,
    details TEXT,
    
    status report_status DEFAULT 'pending',
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- PUSH TOKENS (For notifications)
-- ============================================

CREATE TABLE push_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    token TEXT NOT NULL,
    platform VARCHAR(20), -- 'ios', 'android', 'web'
    
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ROW LEVEL SECURITY (Supabase)
-- ============================================

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkins ENABLE ROW LEVEL SECURITY;
ALTER TABLE encouragements ENABLE ROW LEVEL SECURITY;
ALTER TABLE reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Users can only see/edit their own data
CREATE POLICY "Users can view own data" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users
    FOR UPDATE USING (auth.uid() = id);

-- Check-ins: users see their own
CREATE POLICY "Users can view own checkins" ON checkins
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create checkins" ON checkins
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Encouragements: sender and receiver can see
CREATE POLICY "Users can view encouragements" ON encouragements
    FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can send encouragements" ON encouragements
    FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Update user stats after sending encouragement
CREATE OR REPLACE FUNCTION update_sender_stats()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_stats (user_id, total_sent, last_send_date)
    VALUES (NEW.sender_id, 1, CURRENT_DATE)
    ON CONFLICT (user_id) DO UPDATE
    SET 
        total_sent = user_stats.total_sent + 1,
        current_streak = CASE 
            WHEN user_stats.last_send_date = CURRENT_DATE - 1 THEN user_stats.current_streak + 1
            WHEN user_stats.last_send_date = CURRENT_DATE THEN user_stats.current_streak
            ELSE 1
        END,
        longest_streak = GREATEST(user_stats.longest_streak, 
            CASE 
                WHEN user_stats.last_send_date = CURRENT_DATE - 1 THEN user_stats.current_streak + 1
                ELSE 1
            END),
        last_send_date = CURRENT_DATE,
        updated_at = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_sender_stats
    AFTER INSERT ON encouragements
    FOR EACH ROW
    EXECUTE FUNCTION update_sender_stats();

-- Update 'people_helped' when someone reacts 'feeling_better'
CREATE OR REPLACE FUNCTION update_helped_stats()
RETURNS TRIGGER AS $$
DECLARE
    sender UUID;
BEGIN
    IF NEW.reaction = 'feeling_better' THEN
        SELECT sender_id INTO sender FROM encouragements WHERE id = NEW.encouragement_id;
        
        UPDATE user_stats
        SET people_helped = people_helped + 1, updated_at = NOW()
        WHERE user_id = sender;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_helped_stats
    AFTER INSERT ON reactions
    FOR EACH ROW
    EXECUTE FUNCTION update_helped_stats();

-- Auto-generate anonymous_id for new users
CREATE OR REPLACE FUNCTION generate_anonymous_id()
RETURNS TRIGGER AS $$
BEGIN
    NEW.anonymous_id := 'User#' || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generate_anonymous_id
    BEFORE INSERT ON users
    FOR EACH ROW
    WHEN (NEW.anonymous_id IS NULL)
    EXECUTE FUNCTION generate_anonymous_id();

-- ============================================
-- INDEXES FOR MATCHING ALGORITHM
-- ============================================

-- Find sad users who want encouragement, ordered by time
CREATE INDEX idx_matching_sad_users ON checkins(created_at DESC)
    WHERE mood = 'sad' AND wants_encouragement = true;

-- Find users who haven't been matched too many times
CREATE INDEX idx_checkins_matched_count ON checkins(matched_count)
    WHERE mood = 'sad';
