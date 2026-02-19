import 'card.dart'; // Pastikan import ini sesuai lokasi model Card kamu

class UserCard {
  final String id;
  final String userId;
  final int cardId;
  final int quantity;
  final Card? card; // Data kartu dari relasi (Join)

  UserCard({
    required this.id,
    required this.userId,
    required this.cardId,
    required this.quantity,
    this.card,
  });

  factory UserCard.fromJson(Map<String, dynamic> json) {
    return UserCard(
      // --- PERBAIKAN DI SINI ---
      // Gunakan .toString() agar ID (angka 13) diubah jadi String "13"
      id: json['id'].toString(), 
      
      userId: json['user_id'] as String,
      
      // card_id juga dari DB biasanya int, kita aman terima sebagai int
      cardId: json['card_id'] as int, 
      
      quantity: json['quantity'] as int? ?? 0,
      
      // Parse data kartu jika ada (hasil join dari Supabase: .select('*, cards(*)'))
      card: json['cards'] != null ? Card.fromJson(json['cards']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'card_id': cardId,
      'quantity': quantity,
      // 'cards': card?.toJson(), // Biasanya tidak perlu dikirim balik ke DB
    };
  }
}