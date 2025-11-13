--
-- This migration aligns the 'practice_sessions' table with the Dart 'Session' model.
-- It cleans up old columns, adds required new columns, and renames others for consistency.
--

-- First, ensure a proper foreign key relationship with cascade delete exists.
-- This prevents errors if we try to add it again.
ALTER TABLE public.practice_sessions
  DROP CONSTRAINT IF EXISTS practice_sessions_user_id_fkey;

ALTER TABLE public.practice_sessions
  ADD CONSTRAINT practice_sessions_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- Clean up old, now-redundant XP columns.
ALTER TABLE public.practice_sessions
  DROP COLUMN IF EXISTS mxp_gained_pacing,
  DROP COLUMN IF EXISTS mxp_gained_filler_w;

-- Add all the new columns required by the 'Session' model in your app.
-- We use 'IF NOT EXISTS' to make the script re-runnable without errors.
ALTER TABLE public.practice_sessions
  ADD COLUMN IF NOT EXISTS mode_id TEXT NOT NULL DEFAULT 'public_speaking',
  ADD COLUMN IF NOT EXISTS mode_exp INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS pace_control_exp INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS filler_control_exp INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS topic TEXT,
  ADD COLUMN IF NOT EXISTS generated_question TEXT,
  ADD COLUMN IF NOT EXISTS pace_control REAL,
  ADD COLUMN IF NOT EXISTS filler_control INTEGER,
  ADD COLUMN IF NOT EXISTS overall_rating REAL,
  ADD COLUMN IF NOT EXISTS content_clarity_score REAL,
  ADD COLUMN IF NOT EXISTS clarity_structure_score REAL,
  ADD COLUMN IF NOT EXISTS feedback TEXT;

-- Rename existing columns to match the camelCase properties in your Dart 'Session' model.
-- This makes the code cleaner and less error-prone.
ALTER TABLE public.practice_sessions
  RENAME COLUMN session_date TO timestamp;

ALTER TABLE public.practice_sessions
  RENAME COLUMN ai_feedback_text TO feedback_summary;