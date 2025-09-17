-- Create enum for user roles
CREATE TYPE public.user_role AS ENUM ('admin', 'teacher', 'student');

-- Create enum for module types
CREATE TYPE public.module_type AS ENUM ('theory', 'quiz', 'game', 'emergency');

-- Create enum for difficulty levels
CREATE TYPE public.difficulty_level AS ENUM ('beginner', 'intermediate', 'advanced');

-- Create profiles table
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT NOT NULL,
  role user_role NOT NULL DEFAULT 'student',
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create learning modules table
CREATE TABLE public.learning_modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  content TEXT,
  module_type module_type NOT NULL,
  difficulty_level difficulty_level NOT NULL DEFAULT 'beginner',
  order_index INTEGER NOT NULL,
  passing_score INTEGER DEFAULT 80,
  video_url TEXT,
  thumbnail_url TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Enable RLS on learning_modules
ALTER TABLE public.learning_modules ENABLE ROW LEVEL SECURITY;

-- Create quiz questions table
CREATE TABLE public.quiz_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id UUID NOT NULL REFERENCES public.learning_modules(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  options JSONB NOT NULL,
  correct_answer INTEGER NOT NULL,
  explanation TEXT,
  order_index INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Enable RLS on quiz_questions
ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;

-- Create user progress table
CREATE TABLE public.user_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  module_id UUID NOT NULL REFERENCES public.learning_modules(id) ON DELETE CASCADE,
  completed_at TIMESTAMP WITH TIME ZONE,
  score INTEGER,
  attempts INTEGER NOT NULL DEFAULT 0,
  is_completed BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, module_id)
);

-- Enable RLS on user_progress
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;

-- Create achievements table
CREATE TABLE public.achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  badge_icon TEXT,
  criteria JSONB NOT NULL,
  points INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Enable RLS on achievements
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;

-- Create user achievements table
CREATE TABLE public.user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  achievement_id UUID NOT NULL REFERENCES public.achievements(id) ON DELETE CASCADE,
  earned_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, achievement_id)
);

-- Enable RLS on user_achievements
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

-- Create emergency procedures table
CREATE TABLE public.emergency_procedures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  steps JSONB NOT NULL,
  warning_text TEXT,
  image_url TEXT,
  video_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Enable RLS on emergency_procedures
ALTER TABLE public.emergency_procedures ENABLE ROW LEVEL SECURITY;

-- Create function to handle new user profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'student')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user profile creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_learning_modules_updated_at
  BEFORE UPDATE ON public.learning_modules
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_progress_updated_at
  BEFORE UPDATE ON public.user_progress
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_emergency_procedures_updated_at
  BEFORE UPDATE ON public.emergency_procedures
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- RLS Policies for profiles
CREATE POLICY "Users can view their own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles" ON public.profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- RLS Policies for learning_modules
CREATE POLICY "Everyone can view active modules" ON public.learning_modules
  FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Admins and teachers can manage modules" ON public.learning_modules
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'teacher')
    )
  );

-- RLS Policies for quiz_questions
CREATE POLICY "Everyone can view quiz questions" ON public.quiz_questions
  FOR SELECT USING (TRUE);

CREATE POLICY "Admins and teachers can manage quiz questions" ON public.quiz_questions
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'teacher')
    )
  );

-- RLS Policies for user_progress
CREATE POLICY "Users can view their own progress" ON public.user_progress
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own progress" ON public.user_progress
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own progress" ON public.user_progress
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Teachers and admins can view all progress" ON public.user_progress
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'teacher')
    )
  );

-- RLS Policies for achievements
CREATE POLICY "Everyone can view achievements" ON public.achievements
  FOR SELECT USING (TRUE);

CREATE POLICY "Admins can manage achievements" ON public.achievements
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- RLS Policies for user_achievements
CREATE POLICY "Users can view their own achievements" ON public.user_achievements
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "System can award achievements" ON public.user_achievements
  FOR INSERT WITH CHECK (TRUE);

-- RLS Policies for emergency_procedures
CREATE POLICY "Everyone can view emergency procedures" ON public.emergency_procedures
  FOR SELECT USING (TRUE);

CREATE POLICY "Admins and teachers can manage emergency procedures" ON public.emergency_procedures
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'teacher')
    )
  );

-- Insert sample data for emergency procedures
INSERT INTO public.emergency_procedures (title, category, steps, warning_text, image_url) VALUES
('CPR (Cardiopulmonary Resuscitation)', 'Medical Emergency', 
 '["Check responsiveness and breathing", "Call emergency services (911)", "Position hands on chest center", "Push hard and fast 2 inches deep", "Give 30 chest compressions", "Tilt head back, lift chin", "Give 2 rescue breaths", "Continue cycles until help arrives"]'::jsonb,
 'Only perform CPR if you are trained. Incorrect technique can cause harm.',
 null),
('Treating Fainting', 'Medical Emergency',
 '["Check if person is responsive", "Position person on their back", "Elevate legs 8-12 inches", "Loosen tight clothing", "Check for breathing and pulse", "Keep person warm", "Do not give food or water", "Call emergency services if no improvement"]'::jsonb,
 'Do not move person if neck or spine injury is suspected.',
 null),
('ORS Preparation', 'Medical Treatment',
 '["Use clean water (1 liter boiled and cooled)", "Add 1/2 teaspoon salt", "Add 2 tablespoons sugar", "Mix until completely dissolved", "Taste - should be no saltier than tears", "Use within 24 hours", "Give small frequent sips", "Discard if it tastes very salty"]'::jsonb,
 'Use exact measurements. Too much salt can be dangerous.',
 null),
('Bee Sting Treatment', 'First Aid',
 '["Remove stinger by scraping with credit card", "Do not squeeze stinger", "Wash area with soap and water", "Apply cold compress for 15-20 minutes", "Take pain reliever if needed", "Apply topical antihistamine", "Monitor for allergic reactions", "Seek emergency care if severe reaction occurs"]'::jsonb,
 'Call emergency services immediately if signs of severe allergic reaction appear.',
 null),
('Snake Bite First Aid', 'Emergency Treatment',
 '["Keep person calm and still", "Remove jewelry before swelling starts", "Position bite below heart level", "Mark swelling edge and time", "Do not cut the bite", "Do not apply tourniquet", "Do not apply ice", "Get to hospital immediately"]'::jsonb,
 'Never attempt to catch or kill the snake. Get medical help immediately.',
 null);

-- Insert sample achievements
INSERT INTO public.achievements (title, description, criteria, points, badge_icon) VALUES
('First Steps', 'Complete your first learning module', '{"modules_completed": 1}'::jsonb, 10, '🏆'),
('Knowledge Seeker', 'Complete 5 learning modules', '{"modules_completed": 5}'::jsonb, 25, '📚'),
('Quiz Master', 'Score 100% on any quiz', '{"perfect_score": true}'::jsonb, 15, '🎯'),
('Disaster Expert', 'Complete all disaster preparedness modules', '{"category_completed": "disaster"}'::jsonb, 50, '🛡️'),
('Emergency Hero', 'Complete all emergency procedures', '{"category_completed": "emergency"}'::jsonb, 50, '🚑'),
('Persistent Learner', 'Complete modules for 7 consecutive days', '{"consecutive_days": 7}'::jsonb, 30, '🔥');