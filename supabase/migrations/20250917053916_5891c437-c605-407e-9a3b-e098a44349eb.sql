-- Fix duplicate policy by dropping and recreating with unique names
DROP POLICY IF EXISTS "Users can update their own progress" ON public.user_progress;

CREATE POLICY "Users can insert their own progress" ON public.user_progress
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can modify their own progress" ON public.user_progress
  FOR UPDATE USING (auth.uid() = user_id);