
  // --- Achievement Logic ---

  Future<bool> hasClaimedUrReward() async {
    final profile = _ref.read(currentProfileProvider);
    if (profile == null) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('ur_reward_claimed_${profile.id}') ?? false;
  }

  Future<bool> claimUrReward() async {
    final profile = _ref.read(currentProfileProvider);
    if (profile == null) return false;

    try {
      // 1. Double check count
      final urCount = state.value?.where((c) => c.card?.rarity == Rarity.ultraRare).length ?? 0;
      if (urCount < 5) return false;

      // 2. Give Reward (500 Gems)
      // We assume gems are added via ProfileService directly or updateDust equivalent
      // Since we don't have 'updateGems' in ProfileService exposed nicely, we might need to add it or use Supabase directly there.
      // Let's use ProfileService.
      
      final currentGems = profile.gems;
      await _profileService.updateGems(profile.id, currentGems + 1000); // 1000 Gems Reward
      
      // 3. Mark as claimed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ur_reward_claimed_${profile.id}', true);

      // 4. Refresh
      await _ref.read(authProvider.notifier).refreshProfile();
      return true;
    } catch (e) {
      print('Claim Error: $e');
      return false;
    }
  }
