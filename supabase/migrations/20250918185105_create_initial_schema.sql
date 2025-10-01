-- =============================================
-- 1. USERS TABLE
-- Stores user account info and overall progress (Practice XP)
-- =============================================
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    total_pxp INT NOT NULL DEFAULT 0,
    level_title VARCHAR(50) NOT NULL DEFAULT 'Novice',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.users IS 'Stores user credentials and overall progression stats.';

-- =============================================
-- 2. SKILLS TABLE (Seed Data Included)
-- A lookup table for the skills that can be mastered.
-- =============================================
CREATE TABLE public.skills (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

COMMENT ON TABLE public.skills IS 'Defines the different public speaking skills users can develop.';

-- Seed the essential skills data
INSERT INTO public.skills (name, description) VALUES
('Pacing Control', 'The ability to speak at a clear and engaging speed, avoiding talking too fast or too slow.'),
('Filler Word Control', 'The skill of minimizing the use of filler words like "um," "uh," and "like" for a more confident delivery.');

-- =============================================
-- 3. USER_SKILLS TABLE
-- A join table to track a user''s progress in each specific skill (Mastery XP).
-- =============================================
CREATE TABLE public.user_skills (
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    skill_id INT NOT NULL REFERENCES public.skills(id) ON DELETE CASCADE,
    total_mxp INT NOT NULL DEFAULT 0,
    skill_level INT NOT NULL DEFAULT 1,
    PRIMARY KEY (user_id, skill_id)
);

COMMENT ON TABLE public.user_skills IS 'Tracks user mastery level and XP for each individual skill.';

-- =============================================
-- 4. TOPICS TABLE (Seed Data Included)
-- Stores the impromptu speaking prompts given to users.
-- =============================================
CREATE TABLE public.topics (
    id SERIAL PRIMARY KEY,
    prompt_text TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.topics IS 'A collection of speaking prompts for practice sessions.';

-- Seed some initial topics
INSERT INTO public.topics (prompt_text) VALUES
('Describe a memorable meal.'),
('What is a skill you would like to learn and why?'),
('Talk about a book or movie that changed your perspective.'),
('If you could have any superpower, what would it be?'),
('Describe your ideal vacation.'),
('What is one of your favorite childhood memories?');


-- =============================================
-- 5. PRACTICE_SESSIONS TABLE
-- The core table that logs every practice attempt, its analytics, and the results.
-- =============================================
CREATE TABLE public.practice_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    topic_id INT REFERENCES public.topics(id) ON DELETE SET NULL,
    session_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    duration_seconds INT NOT NULL,
    words_per_minute INT NOT NULL,
    filler_word_count INT NOT NULL,
    transcript TEXT,
    ai_feedback_text TEXT,
    pxp_gained INT NOT NULL,
    mxp_gained_pacing INT NOT NULL,
    mxp_gained_filler_words INT NOT NULL
);

COMMENT ON TABLE public.practice_sessions IS 'Logs every speech, its analytics, AI feedback, and XP earned.';

-- =============================================
-- 6. INDEXES for performance
-- =============================================
CREATE INDEX idx_practice_sessions_user_id ON public.practice_sessions(user_id);
CREATE INDEX idx_user_skills_user_id ON public.user_skills(user_id);