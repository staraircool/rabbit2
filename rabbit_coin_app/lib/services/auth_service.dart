import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _currentUser != null;

  AuthService() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _currentUser = SupabaseService.currentUser;
    if (_currentUser != null) {
      _loadUserProfile();
    }

    // Listen to auth state changes
    SupabaseService.authStateChanges.listen((AuthState state) {
      _currentUser = state.session?.user;
      if (_currentUser != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final profileData = await SupabaseService.getUserProfile();
      if (profileData != null) {
        _userProfile = UserModel.fromJson({
          ...profileData,
          'email': _currentUser!.email!,
        });
      }
    } catch (e) {
      _errorMessage = 'Failed to load user profile: $e';
    }
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await SupabaseService.signUp(
        email: email,
        password: password,
        username: username,
      );

      if (response.user != null) {
        // Create user profile
        await SupabaseService.upsertUserProfile(
          username: username,
          balance: 0.00001,
        );
        return true;
      } else {
        _errorMessage = 'Sign up failed. Please try again.';
        return false;
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await SupabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadUserProfile();
        return true;
      } else {
        _errorMessage = 'Sign in failed. Please check your credentials.';
        return false;
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await SupabaseService.signOut();
      _currentUser = null;
      _userProfile = null;
    } catch (e) {
      _errorMessage = 'Failed to sign out: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendEmailVerification(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await SupabaseService.resendEmailVerification(email: email);
    } catch (e) {
      _errorMessage = 'Failed to resend verification email: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateBalance(double newBalance) async {
    if (_userProfile == null) return;

    try {
      await SupabaseService.updateUserBalance(newBalance);
      _userProfile = _userProfile!.copyWith(balance: newBalance);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update balance: $e';
      notifyListeners();
    }
  }

  Future<bool> performMining() async {
    if (_userProfile == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final canMine = await SupabaseService.canMine();
      if (!canMine) {
        _errorMessage = 'You can only mine once every 24 hours';
        return false;
      }

      // Add mining reward (0.00001 RBT per mining session)
      const miningReward = 0.00001;
      await SupabaseService.addMiningReward(miningReward);
      await SupabaseService.updateLastMined();

      // Update local user profile
      final newBalance = _userProfile!.balance + miningReward;
      _userProfile = _userProfile!.copyWith(
        balance: newBalance,
        lastMined: DateTime.now(),
      );

      return true;
    } catch (e) {
      _errorMessage = 'Mining failed: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}

