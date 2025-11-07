CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS void
LANGUAGE sql
-- IMPORTANT: This gives the function the necessary permissions to delete from the auth schema.
SECURITY DEFINER
AS $$

  DELETE FROM auth.users WHERE id = auth.uid();
$$;

-- Grant permission to authenticated users to call this function.
GRANT EXECUTE ON FUNCTION public.delete_user_account() TO authenticated;