import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/gacha_service.dart';
import '../../../core/constants/app_constants.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/gacha_result_dialog.dart';
import '../../inventory/controllers/inventory_controller.dart';

/// Gacha Page - Main gacha pull screen
class GachaPage extends ConsumerStatefulWidget {
  const GachaPage({super.key});

  @override
  ConsumerState<GachaPage> createState() => _GachaPageState();
}

class _GachaPageState extends ConsumerState<GachaPage>
    with SingleTickerProviderStateMixin {
  final GachaService _gachaService = GachaService();
  bool _isPulling = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    // Use controller for Shake Effect, default 0
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _performPull({required bool isTenPull}) async {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return;

    final cost = isTenPull ? AppConstants.tenPullCost : AppConstants.singlePullCost;

    // Check gems
    if (profile.gems < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Not enough gems!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isPulling = true);
    
    // Trigger Shake Animation
    _shakeController.forward(from: 0.0);

    // Artificial delay for tension
    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      // Perform pull
      List<GachaResult> results;
      if (isTenPull) {
        results = await _gachaService.performTenPull(profile.id) ?? [];
      } else {
        final result = await _gachaService.performSinglePull(profile.id);
        results = result != null ? [result] : [];
      }
      
      if (results.isEmpty) throw Exception('Gacha Failed');

      // Refresh profile
      await ref.read(authProvider.notifier).refreshProfile();
      
      // Refresh Inventory IMMEDIATELY so new items appear
      await ref.read(inventoryControllerProvider.notifier).fetchInventory();

      // Show results
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.9), // Dark overlay
          builder: (context) => GachaResultDialog(
            results: results,
            isTenPull: isTenPull,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPulling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final canSinglePull = profile.gems >= AppConstants.singlePullCost;
    final canTenPull = profile.gems >= AppConstants.tenPullCost;
    final pullsUntilPity = AppConstants.maxPityCounter - profile.pityCounter;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('SUMMON ENTITY'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E004F),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40), // Added bottom padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Saldo Display (Simplified)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBalanceChip(Icons.diamond, '${profile.gems}', Colors.cyanAccent),
                    _buildBalanceChip(Icons.favorite, '${profile.pityCounter}/${AppConstants.maxPityCounter}', Colors.pinkAccent),
                  ],
                ),
                
                const SizedBox(height: 20),

                // Pity Info
                 if (pullsUntilPity <= 10)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      border: Border.all(color: Colors.orangeAccent),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pullsUntilPity == 0
                          ? '🔥 GUARANTEED ULTRA RARE NEXT! 🔥'
                          : '⚡ $pullsUntilPity PULLS UNTIL UR!',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(duration: 800.ms),

                const SizedBox(height: 40),

                const SizedBox(height: 60),

                // CYBERPUNK CORE
                Center(child: _buildGachaCore()),

                const SizedBox(height: 50),

                // PULL BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: _buildPullButton(
                        context, 
                        isTenPull: false, 
                        canAfford: canSinglePull, 
                        cost: AppConstants.singlePullCost
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPullButton(
                        context, 
                        isTenPull: true, 
                        canAfford: canTenPull, 
                        cost: AppConstants.tenPullCost
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Rates Info
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.info_outline, color: Colors.white54, size: 16),
                    label: const Text('View Drop Rates', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    onPressed: () => _showRatesDialog(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPullButton(BuildContext context, {required bool isTenPull, required bool canAfford, required int cost}) {
    final title = isTenPull ? '10x SUMMON' : '1x SUMMON';
    final subtitle = isTenPull ? 'Guaranteed SR' : 'Try your luck';
    
    return ElevatedButton(
      onPressed: _isPulling || !canAfford ? null : () => _performPull(isTenPull: isTenPull),
      style: ElevatedButton.styleFrom(
        backgroundColor: canAfford ? Theme.of(context).colorScheme.primary : Colors.grey[800],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: canAfford ? 8 : 0,
        shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.diamond, size: 14, color: Colors.cyanAccent),
              const SizedBox(width: 4),
              Text('$cost', style: TextStyle(color: canAfford ? Colors.cyanAccent : Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  void _showRatesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DROP RATES'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRateRow('Ultra Rare', AppConstants.ultraRareRate, Colors.yellow),
            _buildRateRow('Super Rare', AppConstants.superRareRate, Colors.purple),
            _buildRateRow('Rare', AppConstants.rareRate, Colors.blue),
            _buildRateRow('Elite', AppConstants.eliteRate, Colors.green),
            _buildRateRow('Normal', AppConstants.normalRate, Colors.grey),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')),
        ],
      ),
    );
  }

  Widget _buildGachaCore() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        // Shake logic
        final sineValue = 5.0 * 2 * (0.5 - (0.5 - _shakeController.value).abs());
        final offset = _shakeController.value > 0 
             ? Offset(sineValue * 5 * (DateTime.now().millisecond % 2 == 0 ? 1 : -1), 0) 
             : Offset.zero;

        return Transform.translate(
          offset: offset,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                     BoxShadow(
                       color: _isPulling ? Colors.pinkAccent.withOpacity(0.6) : Colors.purpleAccent.withOpacity(0.2),
                       blurRadius: _isPulling ? 100 : 60,
                       spreadRadius: _isPulling ? 20 : -10,
                     ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Ring
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 290, height: 290, 
                          child: CircularProgressIndicator(
                            value: null, 
                            strokeWidth: 2, 
                            valueColor: AlwaysStoppedAnimation(Colors.purple),
                          )
                        )
                      ),
                    ).animate(
                      onPlay: (c) => c.repeat(),
                    ).rotate(duration: _isPulling ? 1.seconds : 20.seconds),

                    // Inner Ring
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 4),
                      ),
                    ).animate(
                      onPlay: (c) => c.repeat(reverse: false),
                    ).rotate(duration: _isPulling ? 500.ms : 10.seconds, begin: 1, end: 0),

                    // Center Core
                    Container(
                       width: 160, 
                       height: 160,
                       decoration: BoxDecoration(
                         color: _isPulling ? Colors.white : Colors.black.withOpacity(0.8),
                         shape: BoxShape.circle,
                         border: Border.all(color: Colors.white, width: _isPulling ? 4 : 2),
                         boxShadow: [
                           BoxShadow(color: _isPulling ? Colors.purple : Colors.cyan, blurRadius: 20, spreadRadius: 5)
                         ]
                       ),
                       child: Center(
                         child: _isPulling 
                           ? const Icon(Icons.flash_on, size: 80, color: Colors.black)
                               .animate(onPlay: (c)=>c.repeat(reverse:true)).scale(begin: Offset(0.8,0.8), end: Offset(1.2,1.2))
                           : const Icon(Icons.hexagon_outlined, size: 80, color: Colors.white),
                       ),
                    ).animate(
                      target: _isPulling ? 1 : 0
                    ).scale(end: const Offset(1.1, 1.1), duration: 200.ms)
                     .shimmer(duration: 500.ms),
                  ],
                ),
              ),
              if (_isPulling)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: const Text("INITIALIZING SUMMON...", style: TextStyle(
                    color: Colors.cyanAccent, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 16
                  )).animate(onPlay: (c) => c.repeat())
                    .fadeIn(duration: 300.ms)
                    .shimmer(duration: 1.seconds, color: Colors.white),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRateRow(String name, double rate, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(name)),
          Text('$rate%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
