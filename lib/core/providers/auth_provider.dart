import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../services/auth_service.dart';

/// Auth state untuk tracking login status
class AuthState {
  final User? user;
  final Profile? profile;
  final bool isLoading;
  final String? error;
  final bool dailyResetOccurred;

  AuthState({
    this.user,
    this.profile,
    this.isLoading = false,
    this.error,
    this.dailyResetOccurred = false,
  });

  AuthState copyWith({
    User? user,
    Profile? profile,
    bool? isLoading,
    String? error,
    bool? dailyResetOccurred,
  }) {
    return AuthState(
      user: user ?? this.user,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      dailyResetOccurred: dailyResetOccurred ?? this.dailyResetOccurred,
    );
  }

  bool get isAuthenticated => user != null;
}

/// Auth Provider - mengelola state autentikasi
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _init();
  }

  /// Initialize - check current user
  Future<void> _init() async {
    final user = _authService.currentUser;
    if (user != null) {
      // User sudah login, fetch profile
      await _loadProfile(user.id);
    }
  }

  /// Login anonim
  Future<void> signInAnonymously() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authService.signInAnonymously();
      
      if (user != null) {
        // Fetch profile dan check daily reset
        await _loadProfile(user.id);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to sign in anonymously',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Login dengan email
  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      
      if (user != null) {
        // Fetch profile dan check daily reset
        await _loadProfile(user.id);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Register dengan email
  Future<void> signUpWithEmail(
    String email,
    String password,
    String username,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        username: username,
      );
      
      if (user != null) {
        // Fetch profile (akan auto-created oleh trigger)
        await _loadProfile(user.id);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = AuthState(); // Reset to initial state
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load profile dan check daily reset
  Future<void> _loadProfile(String userId) async {
    try {
      // Get profile dengan daily reset check
      final profile = await _authService.getProfileAndCheckDailyReset(userId);
      
      if (profile != null) {
        // Check if reset occurred by comparing free_dust
        final dailyReset = profile.freeDust == 3000;
        
        state = state.copyWith(
          user: _authService.currentUser,
          profile: profile,
          isLoading: false,
          dailyResetOccurred: dailyReset,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Profile not found',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh profile (untuk update setelah gacha, dll)
  Future<void> refreshProfile() async {
    if (state.user != null) {
      await _loadProfile(state.user!.id);
    }
  }

  /// Clear daily reset flag (setelah menampilkan notifikasi)
  void clearDailyResetFlag() {
    state = state.copyWith(dailyResetOccurred: false);
  }
}

/// Provider untuk AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider untuk AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// Provider untuk quick access ke user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// Provider untuk quick access ke profile
final currentProfileProvider = Provider<Profile?>((ref) {
  return ref.watch(authProvider).profile;
});

/// Provider untuk check if authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
