import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/card.dart' as card_model;
import '../models/user_card.dart';
import '../constants/app_constants.dart';

/// Service untuk operasi inventory user (user_cards)
class InventoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Ambil semua kartu yang dimiliki user
  Future<List<UserCard>> getUserCards(String userId) async {
    try {
      print('📋 getUserCards - userId: $userId');
      
      final response = await _supabase
          .from(AppConstants.userCardsTable)
          .select()
          .eq('user_id', userId)
          .order('obtained_at', ascending: false);

      print('📦 getUserCards response count: ${(response as List).length}');
      
      final userCards = <UserCard>[];
      for (var i = 0; i < (response as List).length; i++) {
        try {
          final json = response[i] as Map<String, dynamic>;
          print('  Processing item $i: card_id=${json['card_id']} (type: ${json['card_id'].runtimeType})');
          final userCard = UserCard.fromJson(json);
          userCards.add(userCard);
        } catch (e, stackTrace) {
          print('❌ Error parsing UserCard at index $i: $e');
          print('   JSON: ${response[i]}');
          print('   Stack trace: $stackTrace');
          // Continue processing other cards
        }
      }
      
      print('✅ Successfully parsed ${userCards.length} user cards');
      return userCards;
    } catch (e, stackTrace) {
      print('❌ Error fetching user cards: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Cek apakah user sudah memiliki kartu tertentu
  Future<UserCard?> getUserCard(String userId, String cardId) async {
    try {
      print('🔍 getUserCard - userId: $userId, cardId: $cardId');
      
      // Convert cardId String to int for bigint database column
      final cardIdInt = int.tryParse(cardId);
      if (cardIdInt == null) {
        print('❌ Error: Invalid card ID format: $cardId');
        return null;
      }
      print('✅ Parsed cardId to int: $cardIdInt');
      
      final response = await _supabase
          .from(AppConstants.userCardsTable)
          .select()
          .eq('user_id', userId)
          .eq('card_id', cardIdInt)  // Use int instead of String
          .maybeSingle();

      print('📦 Query response: $response');
      
      if (response == null) {
        print('⚠️ No user_card found for user $userId and card $cardIdInt');
        return null;
      }
      
      final userCard = UserCard.fromJson(response);
      print('✅ UserCard found: id=${userCard.id}, quantity=${userCard.quantity}');
      return userCard;
    } catch (e, stackTrace) {
      print('❌ Error fetching user card: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Tambah kartu ke inventory user
  /// Jika sudah ada, increment quantity
  Future<bool> addCardToInventory(String userId, String cardId) async {
    try {
      // Convert cardId String to int for bigint database column
      final cardIdInt = int.tryParse(cardId);
      if (cardIdInt == null) {
        print('Error: Invalid card ID format: $cardId');
        return false;
      }
      
      final existingCard = await getUserCard(userId, cardId);

      if (existingCard != null) {
        // Card already exists, increment quantity
        await _supabase
            .from(AppConstants.userCardsTable)
            .update({'quantity': existingCard.quantity + 1})
            .eq('id', existingCard.id);
      } else {
        // New card, insert
        await _supabase
            .from(AppConstants.userCardsTable)
            .insert({
          'user_id': userId,
          'card_id': cardIdInt,  // Use int instead of String
          'quantity': 1,
        });
      }

      return true;
    } catch (e) {
      print('Error adding card to inventory: $e');
      return false;
    }
  }

  /// Tambah multiple kartu sekaligus (untuk 10-pull)
  Future<bool> addCardsToInventory(String userId, List<String> cardIds) async {
    try {
      for (final cardId in cardIds) {
        await addCardToInventory(userId, cardId);
      }
      return true;
    } catch (e) {
      print('Error adding cards to inventory: $e');
      return false;
    }
  }

  /// Kurangi quantity kartu (untuk recycle)
  Future<bool> decreaseCardQuantity(String userId, String cardId, int amount) async {
    try {
      print('🔽 decreaseCardQuantity - userId: $userId, cardId: $cardId, amount: $amount');
      
      final userCard = await getUserCard(userId, cardId);
      if (userCard == null) {
        print('❌ getUserCard returned null - cannot decrease quantity');
        return false;
      }

      final newQuantity = userCard.quantity - amount;
      print('📊 Current quantity: ${userCard.quantity}, New quantity: $newQuantity');

      if (newQuantity <= 0) {
        // Delete the card if quantity reaches 0
        print('🗑️ Deleting user_card with id: ${userCard.id}');
        await _supabase
            .from(AppConstants.userCardsTable)
            .delete()
            .eq('id', userCard.id);
        print('✅ Deleted successfully');
      } else {
        // Update quantity
        print('📝 Updating quantity to $newQuantity for user_card id: ${userCard.id}');
        await _supabase
            .from(AppConstants.userCardsTable)
            .update({'quantity': newQuantity})
            .eq('id', userCard.id);
        print('✅ Updated successfully');
      }

      return true;
    } catch (e, stackTrace) {
      print('❌ Error decreasing card quantity: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Hapus kartu dari inventory
  Future<bool> removeCardFromInventory(String userId, String cardId) async {
    try {
      final userCard = await getUserCard(userId, cardId);
      if (userCard == null) return false;

      await _supabase
          .from(AppConstants.userCardsTable)
          .delete()
          .eq('id', userCard.id);

      return true;
    } catch (e) {
      print('Error removing card from inventory: $e');
      return false;
    }
  }

  /// Get total unique cards yang dimiliki user
  Future<int> getTotalUniqueCards(String userId) async {
    try {
      final userCards = await getUserCards(userId);
      return userCards.length;
    } catch (e) {
      print('Error getting total unique cards: $e');
      return 0;
    }
  }

  /// Get total semua kartu (termasuk duplikat)
  Future<int> getTotalCards(String userId) async {
    try {
      final userCards = await getUserCards(userId);
      return userCards.fold<int>(0, (sum, card) => sum + card.quantity);
    } catch (e) {
      print('Error getting total cards: $e');
      return 0;
    }
  }

  /// Get user cards with full card details (JOIN with cards table)
  /// Returns Map with UserCard + Card details
  Future<List<Map<String, dynamic>>> getUserCardsWithDetails(String userId) async {
    try {
      final response = await _supabase
          .from(AppConstants.userCardsTable)
          .select('*, cards(*)')
          .eq('user_id', userId)
          .order('obtained_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching user cards with details: $e');
      return [];
    }
  }

  /// Recycle card - decrease quantity and add dust to user profile
  /// Returns dust value gained
  Future<int?> recycleCard(String userId, String cardId, card_model.Card card) async {
    try {
      final userCard = await getUserCard(userId, cardId);
      if (userCard == null || userCard.quantity <= 0) {
        return null;
      }

      // Decrease quantity
      final success = await decreaseCardQuantity(userId, cardId, 1);
      if (!success) return null;

      // Add dust to profile (will be done by caller to use ProfileService)
      return card.recycleDustValue;
    } catch (e) {
      print('Error recycling card: $e');
      return null;
    }
  }
  /// Sell/Recycle specific quantity of a card directly using UserCard ID (UUID)
  /// Returns true if successful (Inventory updated + Dust added)
  Future<bool> sellCardQuantity({
    required String userId,
    required String userCardId,
    required int amount,
    required int totalDust,
  }) async {
    try {
      print('💰 sellCardQuantity - userCardId: $userCardId, amount: $amount, dust: $totalDust');

      // 1. Get current quantity directly by ID
      final response = await _supabase
          .from(AppConstants.userCardsTable)
          .select('quantity')
          .eq('id', userCardId)
          .single();
      
      final currentQty = response['quantity'] as int;
      if (currentQty < amount) {
        print('❌ Error: Not enough quantity to sell');
        return false;
      }

      final newQty = currentQty - amount;
      
      // 2. Update Inventory (Delete if 0, else Update)
      if (newQty == 0) {
        await _supabase
            .from(AppConstants.userCardsTable)
            .delete()
            .eq('id', userCardId);
      } else {
        await _supabase
            .from(AppConstants.userCardsTable)
            .update({'quantity': newQty})
            .eq('id', userCardId);
      }

      // 3. Update User Dust Balance
      // Fetch current dust first to be safe
      final profileRes = await _supabase
          .from('profiles')
          .select('dust')
          .eq('id', userId)
          .single();
      
      final currentDust = profileRes['dust'] as int;
      final newDust = currentDust + totalDust;

      await _supabase
          .from('profiles')
          .update({'dust': newDust})
          .eq('id', userId);

      print('✅ Sold $amount cards. New Dust: $newDust');
      return true;

    } catch (e) {
      print('❌ Error in sellCardQuantity: $e');
      return false;
    }
  }
}
