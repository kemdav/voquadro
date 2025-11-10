--
-- This migration alters the 'id' column of the 'practice_sessions' table
-- to automatically generate a new UUID for each new row.
--
ALTER TABLE public.practice_sessions
ALTER COLUMN id SET DEFAULT gen_random_uuid();