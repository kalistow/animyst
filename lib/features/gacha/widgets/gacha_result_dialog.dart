import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui'; // For ImageFilter
import '../../../core/services/gacha_service.dart';
import '../../../core/enums/enums.dart';

/// Gacha Result Dialog - Updated for Sequential Reveal with Blur
class GachaResultDialog extends StatefulWidget {
  final List<GachaResult> results;
  final bool isTenPull;

  const GachaResultDialog({
    super.key,
    required this.results,
    required this.isTenPull,
  });

  @override
  State<GachaResultDialog> createState() => _GachaResultDialogState();
}

class _GachaResultDialogState extends State<GachaResultDialog> {
  int _currentIndex = 0;
  bool _isRevealed = false;
  bool _isAnimationPlaying = false;

  @override
  Widget build(BuildContext context) {
    final currentResult = widget.results[_currentIndex];
    final total = widget.results.length;
    final isLast = _currentIndex == total - 1;

    return Dialog(
      backgroundColor: Colors.transparent, // Transparent for overlay feel
      insetPadding: EdgeInsets.zero, // Full screen feel
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9), // Dark background
        ),
        child: Column(
          children: [
            // Header: Counter
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SUMMON RESULT',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / $total',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Card Area
            Expanded(
              child: Center(
                child: _buildSingleCardView(currentResult),
              ),
            ),

            // Footer: Control Buttons
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: _buildActionButton(isLast),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleCardView(GachaResult result) {
    final card = result.card;
    final color = _getRarityColor(card.rarity);
    final isUltra = card.rarity == Rarity.ultraRare;

    // Determine content based on revealed state
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey('card_${_currentIndex}_revealed_$_isRevealed'),
        width: 300,
        height: 450,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isRevealed ? color : Colors.white24,
            width: isUltra && _isRevealed ? 3 : 1,
          ),
          boxShadow: [
            if (_isRevealed)
              BoxShadow(
                color: color.withOpacity(isUltra ? 0.6 : 0.3),
                blurRadius: isUltra ? 40 : 20,
                spreadRadius: isUltra ? 5 : 2,
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. The Image (Always there, but maybe blurred)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/images/${card.imageUrl}',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.white54),
                ),
              ),
            ),

            // 2. Blur Overlay (If not revealed)
            if (!_isRevealed)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app, color: Colors.white70, size: 50)
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1)),
                        const SizedBox(height: 10),
                        const Text(
                          "TAP TO REVEAL",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 3. Info Overlay (Only if revealed)
            if (_isRevealed)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        card.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.rarity.displayName.toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              
            // 4. Tap Detector
            if (!_isRevealed)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _revealCard,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(bool isLast) {
    if (!_isRevealed) {
      // If not revealed, button can also trigger reveal
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white24,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: _revealCard,
        child: const Text('REVEAL ENTITY'),
      );
    }

    if (isLast) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text('COLLECT ALL', style: TextStyle(fontWeight: FontWeight.bold)),
      );
    } // else
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: _nextCard,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('NEXT ENTITY'),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward),
        ],
      ),
    );
  }

  void _revealCard() {
    setState(() {
      _isRevealed = true;
    });
  }

  void _nextCard() {
    if (_currentIndex < widget.results.length - 1) {
      setState(() {
        _currentIndex++;
        _isRevealed = false;
      });
    }
  }

  Color _getRarityColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.ultraRare:
        return Colors.amberAccent;
      case Rarity.superRare:
        return Colors.purpleAccent;
      case Rarity.rare:
        return Colors.blueAccent;
      case Rarity.elite:
        return Colors.greenAccent;
      case Rarity.normal:
        return Colors.grey;
    }
  }
}
