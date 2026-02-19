import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_card.dart';
import '../../../core/enums/enums.dart';

class InventoryCardItem extends ConsumerWidget {
  final UserCard userCard;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;

  const InventoryCardItem({
    super.key,
    required this.userCard,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
  });

  Color _getRarityColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.ultraRare: return Colors.amberAccent;
      case Rarity.superRare: return Colors.purpleAccent;
      case Rarity.rare: return Colors.blueAccent;
      case Rarity.elite: return Colors.greenAccent;
      case Rarity.normal: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = userCard.card;
    if (card == null) return const SizedBox();

    final rarityColor = _getRarityColor(card.rarity);
    final isUltra = card.rarity == Rarity.ultraRare;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Main Card Container
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.white : rarityColor.withOpacity(0.6),
                width: isSelected ? 3 : (isUltra ? 2 : 1),
              ),
              boxShadow: [
                 if (isUltra || isSelected)
                   BoxShadow(
                     color: isSelected ? Colors.white54 : rarityColor.withOpacity(0.4),
                     blurRadius: 10,
                     spreadRadius: 1,
                   ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  Image.asset(
                    'assets/images/${card.imageUrl}',
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => Container(color: Colors.black, child: Icon(Icons.broken_image, color: rarityColor)),
                  ),
                  
                  // Gradient Overlay (Bottom)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 60,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black87, Colors.transparent],
                        ),
                      ),
                    ),
                  ),

                  // Name & Rarity
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            shadows: [BoxShadow(color: Colors.black, blurRadius: 4)],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          card.rarity.displayName.toUpperCase(),
                          style: TextStyle(
                            color: rarityColor,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quantity Badge
                  if (userCard.quantity > 1)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'x${userCard.quantity}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ).animate(onPlay: (c) => isUltra ? c.repeat(reverse: true) : null)
           .shimmer(duration: 2.seconds, color: isUltra ? Colors.amber.withOpacity(0.2) : Colors.transparent),

          // Selection Overlay
          if (isSelectionMode)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: isSelected 
                        ? const Icon(Icons.check, size: 20, color: Colors.white)
                        : const SizedBox(width: 20, height: 20),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
