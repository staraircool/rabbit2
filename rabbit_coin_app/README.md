# Rabbit Coin - Flutter Crypto Mining App

A modern Flutter application for cryptocurrency mining simulation with Supabase backend integration.

## Features

- 🔐 **User Authentication**: Sign up, sign in, and email verification
- 💰 **Balance Management**: Real-time balance tracking with RBT tokens
- ⛏️ **Mining Simulation**: Tap-to-mine functionality with 24-hour cooldown
- 🎨 **Modern UI**: Glassmorphism design with particle effects
- 📱 **Responsive Design**: Works on both Android and iOS
- 🔄 **Real-time Updates**: Live balance updates using Supabase

## Screenshots

The app includes:
- Sign Up/Sign In screen with particle background
- Email verification flow
- Home screen with balance meter and learning cards
- Bottom navigation with 4 tabs (Home, Spin, Mining, Wallet)

## Tech Stack

- **Frontend**: Flutter 3.24.5
- **Backend**: Supabase (PostgreSQL + Auth)
- **State Management**: Provider
- **UI Components**: Custom glassmorphism widgets
- **Fonts**: Google Fonts (Poppins)
- **Animations**: Flutter Animate

## Project Structure

```
lib/
├── config/
│   └── supabase_config.dart      # Supabase configuration
├── models/
│   └── user_model.dart           # User data model
├── screens/
│   ├── sign_up_sign_in_screen.dart
│   ├── email_verification_screen.dart
│   └── home_screen.dart
├── services/
│   ├── supabase_service.dart     # Supabase API wrapper
│   └── auth_service.dart         # Authentication state management
├── widgets/
│   ├── particle_background.dart  # Animated particle background
│   └── glassmorphism_container.dart # Reusable glassmorphism widget
└── main.dart                     # App entry point
```

## Setup Instructions

### 1. Prerequisites

- Flutter SDK 3.24.5 or higher
- Dart SDK
- Android Studio / VS Code
- Supabase account

### 2. Supabase Setup

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to Settings > API in your Supabase dashboard
3. Copy your Project URL and anon/public key
4. Create the following table in your Supabase database:

```sql
-- Create profiles table
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
```

5. Enable email authentication in Supabase:
   - Go to Authentication > Settings
   - Enable "Enable email confirmations"
   - Configure your email templates if needed

### 3. Flutter App Setup

1. Clone or extract the project
2. Navigate to the project directory:
   ```bash
   cd rabbit_coin_app
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Configure Supabase credentials:
   - Open `lib/config/supabase_config.dart`
   - Replace `YOUR_SUPABASE_URL` with your Supabase project URL
   - Replace `YOUR_SUPABASE_ANON_KEY` with your Supabase anon key

5. Run the app:
   ```bash
   flutter run
   ```

## Configuration

### Supabase Configuration

Update the following file with your Supabase credentials:

```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
}
```

### App Features Configuration

- **Mining Cooldown**: Currently set to 24 hours (configurable in `auth_service.dart`)
- **Mining Reward**: 0.00001 RBT per mining session
- **Initial Balance**: 0.00001 RBT for new users

## Usage

### User Registration
1. Open the app
2. Fill in username, email, and password
3. Tap "Sign Up"
4. Check your email for verification link
5. Click the verification link
6. Return to app and sign in

### Mining
1. Sign in to your account
2. Tap the spin wheel icon in the top bar
3. Earn 0.00001 RBT per mining session
4. Wait 24 hours before mining again

### Navigation
- **Home**: Main dashboard with balance and learning cards
- **Spin**: Mining functionality (same as spin wheel icon)
- **Mining**: Mining history and statistics (to be implemented)
- **Wallet**: Balance details and transaction history (to be implemented)

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  supabase_flutter: ^2.5.6
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.0
  glassmorphism: ^3.0.0
  provider: ^6.1.2
```

## Color Palette

- **Primary**: #7B2CBF (Purple)
- **Secondary**: #F4A261 (Orange)
- **Accent**: #E9C46A (Gold)
- **Background**: #000000 (Black)
- **Surface**: #0D1117 (Dark Navy)

## Known Issues

- App requires internet connection for Supabase functionality
- Email verification is required for account activation
- Mining cooldown is enforced server-side

## Future Enhancements

- [ ] Referral system
- [ ] Leaderboards
- [ ] Push notifications
- [ ] Wallet integration
- [ ] Trading functionality
- [ ] Social features

## Support

For issues and questions:
1. Check the Supabase configuration
2. Verify database setup
3. Ensure internet connectivity
4. Check Flutter and Dart versions

## License

This project is for educational and demonstration purposes.

---

**Note**: This is a simulation app for educational purposes. No real cryptocurrency is involved.

