import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  // Initialize Supabase
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  // Authentication Methods
  
  // Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
        'balance': 0.00001, // Initial balance
      },
    );
    return response;
  }

  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Get current user
  static User? get currentUser => client.auth.currentUser;

  // Check if user is signed in
  static bool get isSignedIn => currentUser != null;

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // Resend email verification
  static Future<void> resendEmailVerification({required String email}) async {
    await client.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  // User Data Methods
  
  // Get user profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isSignedIn) return null;
    
    final response = await client
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .single();
    
    return response;
  }

  // Update user balance
  static Future<void> updateUserBalance(double newBalance) async {
    if (!isSignedIn) return;
    
    await client
        .from('profiles')
        .update({'balance': newBalance})
        .eq('id', currentUser!.id);
  }

  // Get user balance
  static Future<double> getUserBalance() async {
    if (!isSignedIn) return 0.0;
    
    try {
      final profile = await getUserProfile();
      return profile?['balance']?.toDouble() ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Create or update user profile
  static Future<void> upsertUserProfile({
    required String username,
    double? balance,
  }) async {
    if (!isSignedIn) return;
    
    await client.from('profiles').upsert({
      'id': currentUser!.id,
      'username': username,
      'balance': balance ?? 0.00001,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Mining Methods
  
  // Add mining reward to user balance
  static Future<void> addMiningReward(double reward) async {
    if (!isSignedIn) return;
    
    final currentBalance = await getUserBalance();
    final newBalance = currentBalance + reward;
    await updateUserBalance(newBalance);
  }

  // Check if user can mine (implement cooldown logic)
  static Future<bool> canMine() async {
    if (!isSignedIn) return false;
    
    try {
      final profile = await getUserProfile();
      final lastMined = profile?['last_mined'];
      
      if (lastMined == null) return true;
      
      final lastMinedTime = DateTime.parse(lastMined);
      final now = DateTime.now();
      final difference = now.difference(lastMinedTime);
      
      // Allow mining every 24 hours
      return difference.inHours >= 24;
    } catch (e) {
      return true;
    }
  }

  // Update last mined timestamp
  static Future<void> updateLastMined() async {
    if (!isSignedIn) return;
    
    await client
        .from('profiles')
        .update({'last_mined': DateTime.now().toIso8601String()})
        .eq('id', currentUser!.id);
  }
}

