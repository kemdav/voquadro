--
-- This migration adds a foreign key constraint to the public.users table.
-- It links the 'id' column of a user's profile to their corresponding entry
-- in the 'auth.users' table.
--
-- The crucial part is 'ON DELETE CASCADE', which tells Postgres:
-- "If a user is deleted from auth.users, automatically delete their
--  corresponding row from this table (public.users) as well."
--
ALTER TABLE public.users
ADD CONSTRAINT users_id_fkey
FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;