import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'profile_service.dart';

/// Service untuk autentikasi
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ProfileService _profileService = ProfileService();

  /// Get current logged in user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Login anonim
  Future<User?> signInAnonymously() async {
    try {
      final response = await _supabase.auth.signInAnonymously();
      return response.user;
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }

  /// Login dengan email dan password
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      print('Error signing in with email: $e');
      rethrow;
    }
  }

  /// Register dengan email dan password
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
        },
      );
      return response.user;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  /// Check daily reset dan update free_dust jika perlu
  /// Returns true jika terjadi reset, false jika tidak
  Future<bool> checkDailyReset(String userId) async {
    try {
      // Get profile dari database
      final profile = await _profileService.getProfile(userId);
      if (profile == null) {
        print('Profile not found for daily reset check');
        return false;
      }

      // Get tanggal hari ini
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get tanggal last login
      DateTime? lastLoginDate;
      if (profile.lastLogin != null) {
        final lastLogin = profile.lastLogin!;
        lastLoginDate = DateTime(
          lastLogin.year,
          lastLogin.month,
          lastLogin.day,
        );
      }

      // Cek apakah hari berbeda
      final isDifferentDay = lastLoginDate == null || 
                             today.isAfter(lastLoginDate);

      if (isDifferentDay) {
        print('🎁 Daily reset triggered! Resetting free_dust to 3000');
        
        // Update free_dust dan last_login
        await _supabase
            .from('profiles')
            .update({
              'free_dust': 3000,
              'last_login': now.toIso8601String(),
            })
            .eq('id', userId);

        return true; // Reset terjadi
      } else {
        print('✓ Same day login, no reset needed');
        
        // Update last_login saja (untuk tracking)
        await _profileService.updateLastLogin(userId);
        
        return false; // Tidak ada reset
      }
    } catch (e) {
      print('Error in checkDailyReset: $e');
      return false;
    }
  }

  /// Get user profile dengan daily reset check
  /// Ini adalah method utama yang dipanggil setelah login
  Future<Profile?> getProfileAndCheckDailyReset(String userId) async {
    try {
      // Check dan lakukan daily reset jika perlu
      final wasReset = await checkDailyReset(userId);

      // Fetch profile terbaru (setelah potential reset)
      final profile = await _profileService.getProfile(userId);

      if (wasReset && profile != null) {
        print('✅ Daily reset complete! Free dust: ${profile.freeDust}');
      }

      return profile;
    } catch (e) {
      print('Error in getProfileAndCheckDailyReset: $e');
      return null;
    }
  }

  /// Stream auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
