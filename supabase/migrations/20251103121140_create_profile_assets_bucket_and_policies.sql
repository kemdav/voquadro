INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('profile-assets', 'profile-assets', true, 5242880, ARRAY['image/jpeg', 'image/png']);

CREATE POLICY "public"

ON storage.objects

FOR ALL

TO public

USING ( bucket_id = 'profile-assets' )
WITH CHECK ( bucket_id = 'profile-assets' );