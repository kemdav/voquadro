--
-- Remove the password_hash column from the public.users table.
-- This is no longer needed as password management is now handled
-- securely by the Supabase Auth schema (auth.users).
--
ALTER TABLE public.users
DROP COLUMN password_hash;