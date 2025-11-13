-- This migration permanently removes the duration_seconds column 
-- from the practice_sessions table.
ALTER TABLE public.practice_sessions
  DROP COLUMN IF EXISTS duration_seconds;