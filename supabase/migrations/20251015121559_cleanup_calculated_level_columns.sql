-- This migration removes the redundant, pre-calculated level columns
-- from the 'users' table. Levels will now be calculated in the
-- application code based on raw XP values.

--ALTER TABLE public.users
--DROP COLUMN "level",
--DROP COLUMN "MasteryLevel",
--DROP COLUMN "PubSpeakLvl";