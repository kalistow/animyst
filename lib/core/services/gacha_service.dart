import 'dart:math';
import '../enums/enums.dart';
import '../models/models.dart';
import '../constants/app_constants.dart';
import 'profile_service.dart';
import 'card_service.dart';
import 'inventory_service.dart';

/// Result dari gacha pull
class GachaResult {
  final Card card;
  final bool isPityTriggered;

  GachaResult({
    required this.card,
    this.isPityTriggered = false,
  });
}

/// Service untuk mekanisme gacha
class GachaService {
  final ProfileService _profileService = ProfileService();
  final CardService _cardService = CardService();
  final InventoryService _inventoryService = InventoryService();
  final Random _random = Random();

  /// Determine rarity berdasarkan probability rates
  Rarity _determineRarity(int pityCounter) {
    // Check pity counter - guaranteed Ultra Rare at max pity
    if (pityCounter >= AppConstants.maxPityCounter) {
      return Rarity.ultraRare;
    }

    // Generate random number 0-100
    final roll = _random.nextDouble() * 100;
    double cumulative = 0;

    // Check dari yang paling langka
    cumulative += AppConstants.ultraRareRate;
    if (roll < cumulative) return Rarity.ultraRare;

    cumulative += AppConstants.superRareRate;
    if (roll < cumulative) return Rarity.superRare;

    cumulative += AppConstants.rareRate;
    if (roll < cumulative) return Rarity.rare;

    cumulative += AppConstants.eliteRate;
    if (roll < cumulative) return Rarity.elite;

    // Default to normal
    return Rarity.normal;
  }

  /// Single pull (cost: 100 gems)
  Future<GachaResult?> performSinglePull(String userId) async {
    try {
      // Get user profile
      final profile = await _profileService.getProfile(userId);
      if (profile == null) {
        print('Profile not found');
        return null;
      }

      // Check if user has enough gems
      if (profile.gems < AppConstants.singlePullCost) {
        print('Not enough gems');
        return null;
      }

      // Determine rarity
      final rarity = _determineRarity(profile.pityCounter);
      final isPityTriggered = profile.pityCounter >= AppConstants.maxPityCounter;

      // Get random card of that rarity
      final card = await _cardService.getRandomCardByRarity(rarity);
      if (card == null) {
        print('No cards available for this rarity');
        return null;
      }

      // Deduct gems
      final newGems = profile.gems - AppConstants.singlePullCost;
      await _profileService.updateGems(userId, newGems);

      // Update pity counter
      if (rarity == Rarity.ultraRare) {
        // Reset pity if got Ultra Rare
        await _profileService.resetPityCounter(userId);
      } else {
        // Increment pity counter
        await _profileService.incrementPityCounter(userId);
      }

      // Add card to inventory
      await _inventoryService.addCardToInventory(userId, card.id);

      return GachaResult(
        card: card,
        isPityTriggered: isPityTriggered,
      );
    } catch (e) {
      print('Error performing single pull: $e');
      return null;
    }
  }

  /// Ten pull (cost: 900 gems, 10% discount)
  Future<List<GachaResult>?> performTenPull(String userId) async {
    try {
      // Get user profile
      final profile = await _profileService.getProfile(userId);
      if (profile == null) {
        print('Profile not found');
        return null;
      }

      // Check if user has enough gems
      if (profile.gems < AppConstants.tenPullCost) {
        print('Not enough gems');
        return null;
      }

      // Deduct gems first
      final newGems = profile.gems - AppConstants.tenPullCost;
      await _profileService.updateGems(userId, newGems);

      // Perform 10 pulls
      final results = <GachaResult>[];
      int currentPityCounter = profile.pityCounter;

      for (int i = 0; i < 10; i++) {
        // Determine rarity
        final rarity = _determineRarity(currentPityCounter);
        final isPityTriggered = currentPityCounter >= AppConstants.maxPityCounter;

        // Get random card of that rarity
        final card = await _cardService.getRandomCardByRarity(rarity);
        if (card == null) continue;

        // Update pity counter for next pull
        if (rarity == Rarity.ultraRare) {
          currentPityCounter = 0; // Reset pity
        } else {
          currentPityCounter++; // Increment pity
        }

        // Add card to inventory
        await _inventoryService.addCardToInventory(userId, card.id);

        results.add(GachaResult(
          card: card,
          isPityTriggered: isPityTriggered,
        ));
      }

      // Update final pity counter
      await _profileService.updatePityCounter(userId, currentPityCounter);

      return results;
    } catch (e) {
      print('Error performing ten pull: $e');
      return null;
    }
  }

  /// Check jika user bisa melakukan single pull
  Future<bool> canPerformSinglePull(String userId) async {
    final profile = await _profileService.getProfile(userId);
    if (profile == null) return false;
    return profile.gems >= AppConstants.singlePullCost;
  }

  /// Check jika user bisa melakukan ten pull
  Future<bool> canPerformTenPull(String userId) async {
    final profile = await _profileService.getProfile(userId);
    if (profile == null) return false;
    return profile.gems >= AppConstants.tenPullCost;
  }

  /// Get probability untuk masing-masing rarity
  Map<Rarity, double> getProbabilities(int pityCounter) {
    if (pityCounter >= AppConstants.maxPityCounter) {
      // Guaranteed Ultra Rare
      return {
        Rarity.normal: 0.0,
        Rarity.elite: 0.0,
        Rarity.rare: 0.0,
        Rarity.superRare: 0.0,
        Rarity.ultraRare: 100.0,
      };
    }

    return {
      Rarity.normal: AppConstants.normalRate,
      Rarity.elite: AppConstants.eliteRate,
      Rarity.rare: AppConstants.rareRate,
      Rarity.superRare: AppConstants.superRareRate,
      Rarity.ultraRare: AppConstants.ultraRareRate,
    };
  }

  /// Calculate pulls remaining until guaranteed Ultra Rare
  int getPullsUntilPity(int currentPityCounter) {
    return AppConstants.maxPityCounter - currentPityCounter;
  }
}
