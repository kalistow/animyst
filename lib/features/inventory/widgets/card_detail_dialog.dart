// --- PERBAIKAN 1: Tambahkan 'hide Card' agar tidak bentrok dengan Model Card kita
import 'package:flutter/material.dart' hide Card; 
import '../../../core/models/card.dart';
import '../../../core/enums/rarity.dart';

class CardDetailDialog extends StatelessWidget {
  final Card card; // Sekarang 'Card' merujuk ke Model kita
  final int quantity;
  final VoidCallback? onRecycle;
  final bool isRecycling;

  const CardDetailDialog({
    super.key,
    required this.card,
    this.quantity = 1,
    this.onRecycle,
    this.isRecycling = false,
  });

  @override
  Widget build(BuildContext context) {
    // --- PERBAIKAN 2: Inisialisasi default agar tidak error "must be assigned"
    Color rarityColor = Colors.grey; 
    
    switch (card.rarity) {
      case Rarity.normal: rarityColor = Colors.grey; break;
      case Rarity.elite: rarityColor = Colors.green; break;
      case Rarity.rare: rarityColor = Colors.blue; break;
      case Rarity.superRare: rarityColor = Colors.purple; break;
      case Rarity.ultraRare: rarityColor = Colors.amber; break;
      // Default case sudah tercover oleh inisialisasi di atas
    }

    // Karena kita hide 'Card' widget, kita pakai 'Dialog' atau 'Container' saja
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: rarityColor, width: 3),
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage('assets/images/${card.imageUrl}'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              card.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: rarityColor.withOpacity(0.2),
                border: Border.all(color: rarityColor),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                card.rarity.toString().split('.').last.toUpperCase(),
                style: TextStyle(
                  color: rarityColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              card.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (onRecycle != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: (quantity > 0 && !isRecycling) ? onRecycle : null,
                  icon: isRecycling 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.delete_outline, color: Colors.white),
                  label: Text(
                    isRecycling ? "Memproses..." : "Jual (+${card.recycleDustValue} Dust)",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}