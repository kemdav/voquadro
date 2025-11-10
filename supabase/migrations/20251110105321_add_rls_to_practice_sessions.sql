-- First, turn on Row Level Security for the table.
ALTER TABLE public.practice_sessions ENABLE ROW LEVEL SECURITY;

-- POLICY 1: Allow a logged-in user to INSERT a session for THEMSELVES.
-- The 'WITH CHECK' clause is the security rule. It ensures that the 'user_id'
-- of the new row MUST match the ID of the person trying to save it.
CREATE POLICY "Allow authenticated users to insert their own sessions"
ON public.practice_sessions
FOR INSERT
TO authenticated
WITH CHECK ( auth.uid() = user_id );

-- POLICY 2: Allow a user to SELECT (read) their own sessions.
-- This will be essential for your session history screen later.
CREATE POLICY "Allow individual user to read their own sessions"
ON public.practice_sessions
FOR SELECT
TO authenticated
USING ( auth.uid() = user_id );