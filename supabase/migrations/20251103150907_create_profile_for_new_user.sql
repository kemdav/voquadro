--
-- Creates a trigger that automatically inserts a new row into public.users
-- whenever a new user signs up in auth.users.
--

-- 1. Create the Function
-- This function will be executed by the trigger.
-- It takes the user data from the newly created auth.users row
-- and inserts it into our public.users table.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  -- Insert a new row into public.users
  -- - id is taken from the new user's id in auth.users
  -- - email is taken from the new user's email
  -- - username is extracted from the 'raw_user_meta_data' JSON field,
  --   which is where we stored it during sign-up.
  INSERT INTO public.users (id, email, username)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data ->> 'username');
  
  -- aaaaaaa
  
  RETURN NEW;
END;
$$;

-- 2. Create the Trigger
-- This trigger calls the 'handle_new_user' function immediately
-- AFTER a new user is created in the auth.users table.
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();