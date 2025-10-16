-- This migration adjusts the 'users' table to match the structure
-- expected by the addExp and _getUserXP functions in UserService.dart.

-- Step A: Rename the existing 'total_pxp' column to 'practice_xp'
-- to match the Dart code's expectation.
ALTER TABLE public.users
RENAME COLUMN total_pxp TO practice_xp;

-- Step B: Add all the other specific XP columns that the functions need.
-- They are all integers and should default to 0.
ALTER TABLE public.users
ADD COLUMN master_xp INT NOT NULL DEFAULT 0,
ADD COLUMN pace_control INT NOT NULL DEFAULT 0,
ADD COLUMN filler_control INT NOT NULL DEFAULT 0,
ADD COLUMN public_speaking_xp INT NOT NULL DEFAULT 0;