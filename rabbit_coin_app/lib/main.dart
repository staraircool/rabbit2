import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'services/auth_service.dart';
import 'services/supabase_service.dart';
import 'screens/sign_up_sign_in_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase only if configured
  if (SupabaseConfig.isConfigured) {
    try {
      await SupabaseService.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization failed: $e');
    }
  } else {
    debugPrint('Supabase not configured. Please update config/supabase_config.dart');
  }
  
  runApp(const RabbitCoinApp());
}

class RabbitCoinApp extends StatelessWidget {
  const RabbitCoinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MaterialApp(
        title: 'Rabbit Coin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          primaryColor: const Color(0xFF7B2CBF),
          scaffoldBackgroundColor: Colors.black,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
          ),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7B2CBF),
            secondary: Color(0xFFF4A261),
            surface: Color(0xFF0D1117),
            background: Colors.black,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.white,
            onBackground: Colors.white,
          ),
        ),
        home: Consumer<AuthService>(
          builder: (context, authService, child) {
            if (authService.isSignedIn) {
              return const HomeScreen();
            } else {
              return const SignUpSignInScreen();
            }
          },
        ),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/auth': (context) => const SignUpSignInScreen(),
        },
      ),
    );
  }
}

