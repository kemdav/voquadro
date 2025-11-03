INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('profile-assets', 'profile-assets', true, 5242880, ARRAY['image/jpeg', 'image/png']);

--
-- These policies provide secure access to the 'profile-assets' bucket.
--

-- POLICY 1: Allow public, anonymous access to VIEW and DOWNLOAD images.
-- This is necessary so your app can display the images to anyone.
CREATE POLICY "Public Read Access"
ON storage.objects
FOR SELECT
TO public
USING ( bucket_id = 'profile-assets' );

-- POLICY 2: Allow LOGGED-IN users to UPLOAD images.
-- This policy uses 'TO authenticated', which applies ONLY to logged-in users.
-- The WITH CHECK clause ensures a user can only upload into a folder
-- that matches their own unique user ID (auth.uid()).
CREATE POLICY "Allow authenticated user uploads"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profile-assets' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- POLICY 3: Allow LOGGED-IN users to UPDATE their OWN images.
-- The USING clause ensures a user can only update an image if they are the owner
-- (i.e., the folder name matches their user ID).
CREATE POLICY "Allow authenticated user updates"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'profile-assets' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- POLICY 4: Allow LOGGED-IN users to DELETE their OWN images.
-- The USING clause here also ensures users can only delete their own files.
CREATE POLICY "Allow authenticated user deletes"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'profile-assets' AND
  (storage.foldername(name))[1] = auth.uid()::text
);