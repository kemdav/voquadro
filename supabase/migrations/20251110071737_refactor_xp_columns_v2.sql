
ALTER TABLE public.users
  DROP COLUMN IF EXISTS master_xp,
  DROP COLUMN IF EXISTS practice_xp;


ALTER TABLE public.practice_sessions
  DROP COLUMN IF EXISTS pxp_gained;

ALTER TABLE public.practice_sessions
  ADD COLUMN modexp_gained INTEGER NOT NULL DEFAULT 0;