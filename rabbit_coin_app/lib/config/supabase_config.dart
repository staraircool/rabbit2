// Supabase Configuration
// Replace these with your actual Supabase project credentials

class SupabaseConfig {
  // TODO: Replace with your Supabase project URL
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  
  // TODO: Replace with your Supabase anon key
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Validate configuration
  static bool get isConfigured {
    return supabaseUrl != 'YOUR_SUPABASE_URL' && 
           supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY' &&
           supabaseUrl.isNotEmpty && 
           supabaseAnonKey.isNotEmpty;
  }
}

/*
SETUP INSTRUCTIONS:

1. Create a new project at https://supabase.com
2. Go to Settings > API in your Supabase dashboard
3. Copy your Project URL and replace 'YOUR_SUPABASE_URL'
4. Copy your anon/public key and replace 'YOUR_SUPABASE_ANON_KEY'

5. Create the following table in your Supabase database:

CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  balance DECIMAL DEFAULT 0.00001,
  last_mined TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Create function to handle user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, balance)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'username', 'User'), 0.00001);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

6. Enable email authentication in Supabase:
   - Go to Authentication > Settings
   - Enable "Enable email confirmations"
   - Configure your email templates if needed

7. Update this file with your credentials and you're ready to go!
*/

