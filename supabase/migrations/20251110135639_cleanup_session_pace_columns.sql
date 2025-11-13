-- This migration cleans up the pace-related columns in the practice_sessions table.

-- 1. Remove the redundant 'pace_control' column that was added by a previous migration.
ALTER TABLE public.practice_sessions
  DROP COLUMN IF EXISTS pace_control;

-- 2. IMPORTANT: Make the 'words_per_minute' column nullable (optional).
-- This prevents the app from crashing if the AI analysis ever fails to return a WPM value.
ALTER TABLE public.practice_sessions
  ALTER COLUMN words_per_minute DROP NOT NULL;