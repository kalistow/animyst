import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/user_card.dart';
import '../../../core/enums/enums.dart'; // Ensure Rarity enum is available
import '../../../core/services/inventory_service.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/providers/auth_provider.dart';

// 1. Data Provider (Existing Logic, Refined)
final inventoryControllerProvider = StateNotifierProvider<InventoryController, AsyncValue<List<UserCard>>>((ref) {
  return InventoryController(ref);
});

// 2. Selection Mode State Provider
class InventorySelectionState {
  final bool isSelectionMode;
  final Set<String> selectedIds; // IDs of selected UserCards

  const InventorySelectionState({
    this.isSelectionMode = false,
    this.selectedIds = const {},
  });

  InventorySelectionState copyWith({
    bool? isSelectionMode,
    Set<String>? selectedIds,
  }) {
    return InventorySelectionState(
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

final inventorySelectionProvider = StateNotifierProvider<InventorySelectionNotifier, InventorySelectionState>((ref) {
  return InventorySelectionNotifier();
});

class InventorySelectionNotifier extends StateNotifier<InventorySelectionState> {
  InventorySelectionNotifier() : super(const InventorySelectionState());

  void toggleSelectionMode() {
    if (state.isSelectionMode) {
      // Exiting mode: clear selection
      state = const InventorySelectionState(isSelectionMode: false, selectedIds: {});
    } else {
      // Entering mode
      state = state.copyWith(isSelectionMode: true);
    }
  }

  void toggleCardSelection(String userCardId) {
    final currentIds = Set<String>.from(state.selectedIds);
    if (currentIds.contains(userCardId)) {
      currentIds.remove(userCardId);
    } else {
      currentIds.add(userCardId);
    }
    state = state.copyWith(selectedIds: currentIds);
  }

  void selectAllByRarity(List<UserCard> allCards, Rarity rarity) {
    final targetIds = allCards
        .where((c) => c.card?.rarity == rarity)
        .map((c) => c.id) // Assuming UserCard has a unique 'id' field
        .toSet();

    final currentIds = Set<String>.from(state.selectedIds);
    currentIds.addAll(targetIds);
    
    state = state.copyWith(
      isSelectionMode: true, // Auto enter mode if used
      selectedIds: currentIds,
    );
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: {});
  }
}


// --- Main Controller ---

class InventoryController extends StateNotifier<AsyncValue<List<UserCard>>> {
  final Ref _ref;
  final InventoryService _inventoryService = InventoryService();
  final ProfileService _profileService = ProfileService();

  InventoryController(this._ref) : super(const AsyncValue.loading()) {
    fetchInventory(); // Auto fetch on init
  }

  Future<void> fetchInventory() async {
    try {
      // Force loading only if initial
      if (state.value == null) {
        state = const AsyncValue.loading();
      }
      
      // ... continue fetch logic, it will overwrite state.data automatically

      
      final profile = _ref.read(currentProfileProvider);
      if (profile == null) {
         // Wait a bit if profile is not loaded yet
         await Future.delayed(const Duration(milliseconds: 500));
         final retryProfile = _ref.read(currentProfileProvider);
         if (retryProfile == null) {
             state = const AsyncValue.data([]);
             return;
         }
      }

      final currentUser = _ref.read(currentProfileProvider)!;

      // Ambil data dari service
      final rawData = await _inventoryService.getUserCardsWithDetails(currentUser.id);
      
      // Convert ke Model UserCard
      final userCards = rawData.map((json) => UserCard.fromJson(json)).toList();

      state = AsyncValue.data(userCards);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Sell a single card with specific quantity (Slider flow)
  Future<bool> sellCustomAmount(UserCard userCard, int amountToSell) async {
    final profile = _ref.read(currentProfileProvider);
    if (profile == null || userCard.card == null) return false;

    try {
      // Calculate Dust
      final totalDust = userCard.card!.recycleDustValue * amountToSell;

      // 1. Backend Call: Recycle Logic
      final result = await _inventoryService.sellCardQuantity(
        userId: profile.id,
        userCardId: userCard.id, // Ensure user_cards.id is used
        amount: amountToSell,
        totalDust: totalDust
      );

      if (!result) return false;

      // 2. Update Dust & Refresh Profile
      await _ref.read(authProvider.notifier).refreshProfile();
      
      // 3. Refresh Inventory
      await fetchInventory();

      return true;
    } catch (e) {
      print("Error selling custom amount: $e");
      return false;
    }
  }

  /// Bulk Sell Function
  Future<int> sellSelectedCards(Set<String> selectedIds) async {
    final profile = _ref.read(currentProfileProvider);
    final currentInventory = state.value ?? [];
    
    if (profile == null || selectedIds.isEmpty) return 0;

    int totalDustGained = 0;
    int successCount = 0;

    try {
      // We process strictly the selected IDs
      // Optimization: We could do a batch delete in SQL, but for now loop is safer for logic
      // or implement a batch function in Service.
      
      for (final id in selectedIds) {
        final cardItem = currentInventory.firstWhere((c) => c.id == id, orElse: () => UserCard(id: '', userId: '', cardId: -1, quantity: 0));
        if (cardItem.id.isEmpty || cardItem.card == null) continue;

        // Sell ALL quantity for bulk select (as per requirement 2 logic)
      final dust = cardItem.card!.recycleDustValue * cardItem.quantity;
        
        final success = await _inventoryService.sellCardQuantity(
            userId: profile.id,
            userCardId: cardItem.id,
            amount: cardItem.quantity, // Sell ALL
            totalDust: dust
        );

        if (success) {
          totalDustGained += dust;
          successCount++;
        }
      }

      if (successCount > 0) {
        // Refresh everything
        await _ref.read(authProvider.notifier).refreshProfile();
        await fetchInventory();
        
        // Clear selection
        _ref.read(inventorySelectionProvider.notifier).clearSelection();
      }

      return totalDustGained;
    } catch (e) {
      print("Error bulk selling: $e");
      return 0;
    }
  }

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
      final cards = state.value ?? [];
      final urCount = cards.where((c) => c.card?.rarity == Rarity.ultraRare).length;
      
      if (urCount < 5) return false;

      final currentGems = profile.gems;
      final success = await _profileService.updateGems(profile.id, currentGems + 1000); // 1000 Gems Reward
      
      if (!success) return false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ur_reward_claimed_${profile.id}', true);

      await _ref.read(authProvider.notifier).refreshProfile();
      return true;
    } catch (e) {
      print('Claim Error: $e');
      return false;
    }
  }

  Future<bool> exchangeDustForGems(int dustAmount, int gemReward) async {
    final profile = _ref.read(currentProfileProvider);
    if (profile == null) return false;
    
    if (profile.dust < dustAmount) return false;

    try {
      // 1. Update Dust
      final newDust = profile.dust - dustAmount;
      final dustSuccess = await _profileService.updateDust(profile.id, newDust);
      if (!dustSuccess) return false;
      
      // 2. Update Gems
      final newGems = profile.gems + gemReward;
      await _profileService.updateGems(profile.id, newGems);


      // 3. Refresh Profile
      await _ref.read(authProvider.notifier).refreshProfile();
      return true;
    } catch (e) {
      print('Exchange Error: $e');
      return false;
    }
  }
}