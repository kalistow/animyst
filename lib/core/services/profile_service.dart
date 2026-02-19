import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../constants/app_constants.dart';

/// Service untuk operasi database profil user
class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Ambil profil user berdasarkan ID
  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', userId)
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  /// Ambil profil user yang sedang login
  Future<Profile?> getCurrentUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    return await getProfile(user.id);
  }

  /// Update profil user
  Future<bool> updateProfile(Profile profile) async {
    try {
      await _supabase
          .from(AppConstants.profilesTable)
          .update(profile.toJson())
          .eq('id', profile.id);

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  /// Update gems
  Future<bool> updateGems(String userId, int newGems) async {
    try {
      await _supabase
          .from(AppConstants.profilesTable)
          .update({'gems': newGems})
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Error updating gems: $e');
      return false;
    }
  }

  /// Update dust
  Future<bool> updateDust(String userId, int newDust) async {
    try {
      await _supabase
          .from(AppConstants.profilesTable)
          .update({'dust': newDust})
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Error updating dust: $e');
      return false;
    }
  }

  /// Update pity counter
  Future<bool> updatePityCounter(String userId, int newPityCounter) async {
    try {
      await _supabase
          .from(AppConstants.profilesTable)
          .update({'pity_counter': newPityCounter})
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Error updating pity counter: $e');
      return false;
    }
  }

  /// Update last login timestamp
  Future<bool> updateLastLogin(String userId) async {
    try {
      await _supabase
          .from(AppConstants.profilesTable)
          .update({'last_login': DateTime.now().toIso8601String()})
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Error updating last login: $e');
      return false;
    }
  }

  /// Reset pity counter (setelah dapat Ultra Rare)
  Future<bool> resetPityCounter(String userId) async {
    return await updatePityCounter(userId, 0);
  }

  /// Increment pity counter
  Future<bool> incrementPityCounter(String userId) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) return false;

      return await updatePityCounter(userId, profile.pityCounter + 1);
    } catch (e) {
      print('Error incrementing pity counter: $e');
      return false;
    }
  }
}
