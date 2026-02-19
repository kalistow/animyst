import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/models/user_card.dart';
import '../../../core/enums/enums.dart'; // Rarity
import '../controllers/inventory_controller.dart';

class CardSellDialog extends ConsumerStatefulWidget {
  final UserCard userCard;

  const CardSellDialog({super.key, required this.userCard});

  @override
  ConsumerState<CardSellDialog> createState() => _CardSellDialogState();
}

class _CardSellDialogState extends ConsumerState<CardSellDialog> {
  late int _sellAmount;
  bool _isSelling = false;

  @override
  void initState() {
    super.initState();
    // Default to 1 if we have few cards, but if we have duplicates, maybe start at 1?
    _sellAmount = 1; 
  }

  int get _maxQuantity => widget.userCard.quantity;
  int get _dustPerCard => widget.userCard.card?.recycleDustValue ?? 0;
  int get _totalDust => _sellAmount * _dustPerCard;

  Color _getRarityColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.ultraRare: return Colors.amberAccent;
      case Rarity.superRare: return Colors.purpleAccent;
      case Rarity.rare: return Colors.blueAccent;
      case Rarity.elite: return Colors.greenAccent;
      case Rarity.normal: return Colors.grey;
    }
  }

  Future<void> _performSell() async {
    setState(() => _isSelling = true);
    
    final success = await ref.read(inventoryControllerProvider.notifier)
        .sellCustomAmount(widget.userCard, _sellAmount);
    
    if (success && mounted) {
      Navigator.pop(context); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Sold $_sellAmount cards for $_totalDust Dust!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      setState(() => _isSelling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Sale failed.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.userCard.card;
    if (card == null) return const SizedBox();

    final rarityColor = _getRarityColor(card.rarity);
    final isUltra = card.rarity == Rarity.ultraRare;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Blur Background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E).withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: rarityColor.withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(color: rarityColor.withOpacity(0.2), blurRadius: 30, spreadRadius: 5),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header with Close Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            card.name.toUpperCase(),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Card Image Visualization
                  Center(
                    child: Container(
                      height: 250,
                      width: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: rarityColor, width: 2),
                        boxShadow: [
                          if (isUltra) BoxShadow(color: rarityColor, blurRadius: 20),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/images/${card.imageUrl}',
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => Container(color: Colors.black, child: const Icon(Icons.broken_image, color: Colors.white)),
                        ),
                      ),
                    ).animate(onPlay: (c) => isUltra ? c.repeat(reverse: true) : null)
                     .scale(duration: 2.seconds, begin: const Offset(1, 1), end: const Offset(1.02, 1.02)),
                  ),

                  const SizedBox(height: 20),

                  // 3. Stats & Quantity
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatPill('RARITY', card.rarity.displayName, rarityColor),
                        _buildStatPill('OWNED', '$_maxQuantity', Colors.white),
                        _buildStatPill('VALUE', '$_dustPerCard Dust', Colors.cyanAccent),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white12, height: 40),

                  // 4. Slider Control (If duplicates exist)
                  if (_maxQuantity > 1) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Sell Amount', style: TextStyle(color: Colors.white70)),
                              Text(
                                '$_sellAmount',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.redAccent,
                              thumbColor: Colors.white,
                              overlayColor: Colors.redAccent.withOpacity(0.2),
                            ),
                            child: Slider(
                              value: _sellAmount.toDouble(),
                              min: 1,
                              max: _maxQuantity.toDouble(),
                              divisions: _maxQuantity > 1 ? _maxQuantity - 1 : 1,
                              label: '$_sellAmount',
                              onChanged: (val) {
                                setState(() => _sellAmount = val.round());
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                     const Padding(
                       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                       child: Center(child: Text("You have only 1 copy.", style: TextStyle(color: Colors.white54))),
                     ),
                  ],

                  // 5. Action Button
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: ElevatedButton(
                      onPressed: _isSelling ? null : _performSell,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: _isSelling 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.delete_outline),
                              const SizedBox(width: 8),
                              Text(
                                'SELL FOR $_totalDust DUST', 
                                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                            ],
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(
          value.toUpperCase(),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}
