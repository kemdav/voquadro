--
-- This migration adds new scoring metrics to the 'practice_sessions' table.
--

ALTER TABLE public.practice_sessions
  ADD COLUMN IF NOT EXISTS vocal_delivery_score REAL NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS message_depth_score REAL NOT NULL DEFAULT 0;