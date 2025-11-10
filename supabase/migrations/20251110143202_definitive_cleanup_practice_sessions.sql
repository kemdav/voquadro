--
-- This is a definitive cleanup migration to perfectly align the 'practice_sessions' table
-- with the final Dart 'Session' model. It removes all known old/deprecated columns.
--

-- 1. Drop all old, redundant, or deprecated columns from the table.
--    We are using the exact names from the database schema and error logs.
ALTER TABLE public.practice_sessions
  DROP COLUMN IF EXISTS topic_id,
  DROP COLUMN IF EXISTS filler_word_count,
  DROP COLUMN IF EXISTS mxp_gained_filler_words, -- CORRECTED NAME
  DROP COLUMN IF EXISTS modexp_gained,
  DROP COLUMN IF EXISTS feedback_summary;       -- Also remove this for consistency.


-- 2. Modify the 'words_per_minute' column to be correct.
--    - Change its data type from INTEGER to REAL to allow decimal values.
--    - Make it optional (nullable) to prevent future crashes.
ALTER TABLE public.practice_sessions
  ALTER COLUMN words_per_minute TYPE real,
  ALTER COLUMN words_per_minute DROP NOT NULL;