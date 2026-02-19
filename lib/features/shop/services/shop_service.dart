import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/top_up_package.dart';

class ShopService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> submitTopUpRequest(String userId, TopUpPackage package, String paymentMethod) async {
    try {
      if (userId.isEmpty) {
        print('❌ submitTopUpRequest: userId is empty');
        return false;
      }
      
      // Try to get username from metadata or profile for easier admin reading
      final user = _supabase.auth.currentUser;
      final username = user?.userMetadata?['username'] ?? user?.email ?? 'Unknown User';
      
      print('📤 Submitting topup request: User=$username ($userId), Amount=${package.priceRp}, Method=$paymentMethod');
      
      await _supabase.from('topup_requests').insert({
        'user_id': userId,
        'username': username,
        'amount_rupiah': package.priceRp,
        'gems_amount': package.gemsAmount,
        'payment_method': paymentMethod,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
      
      print('✅ Topup request submitted successfully');
      return true;
    } catch (e) {
      print('❌ Error submitting topup request: $e');
      return false;
    }
  }
}
