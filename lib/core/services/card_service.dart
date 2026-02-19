import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../enums/enums.dart';
import '../constants/app_constants.dart';

/// Service untuk operasi database kartu
class CardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Ambil semua kartu
  Future<List<Card>> getAllCards() async {
    try {
      final response = await _supabase
          .from(AppConstants.cardsTable)
          .select()
          .order('rarity');

      return (response as List)
          .map((json) => Card.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching cards: $e');
      return [];
    }
  }

  /// Ambil kartu berdasarkan ID
  Future<Card?> getCard(String cardId) async {
    try {
      final response = await _supabase
          .from(AppConstants.cardsTable)
          .select()
          .eq('id', cardId)
          .single();

      return Card.fromJson(response);
    } catch (e) {
      print('Error fetching card: $e');
      return null;
    }
  }

  /// Ambil kartu berdasarkan rarity
  Future<List<Card>> getCardsByRarity(Rarity rarity) async {
    try {
      final response = await _supabase
          .from(AppConstants.cardsTable)
          .select()
          .eq('rarity', rarity.toJson());

      return (response as List)
          .map((json) => Card.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching cards by rarity: $e');
      return [];
    }
  }

  /// Ambil multiple kartu berdasarkan IDs
  Future<List<Card>> getCardsByIds(List<String> cardIds) async {
    if (cardIds.isEmpty) return [];

    try {
      final response = await _supabase
          .from(AppConstants.cardsTable)
          .select()
          .filter('id', 'in', '(${cardIds.join(',')})');

      return (response as List)
          .map((json) => Card.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching cards by IDs: $e');
      return [];
    }
  }

  /// Count total kartu berdasarkan rarity
  Future<int> getCardCountByRarity(Rarity rarity) async {
    try {
      final response = await _supabase
          .from(AppConstants.cardsTable)
          .select()
          .eq('rarity', rarity.toJson());

      return (response as List).length;
    } catch (e) {
      print('Error counting cards: $e');
      return 0;
    }
  }

  /// Get random card berdasarkan rarity (untuk gacha simulation)
  Future<Card?> getRandomCardByRarity(Rarity rarity) async {
    try {
      final cards = await getCardsByRarity(rarity);
      if (cards.isEmpty) return null;

      // Return random card from the list
      cards.shuffle();
      return cards.first;
    } catch (e) {
      print('Error getting random card: $e');
      return null;
    }
  }
}
