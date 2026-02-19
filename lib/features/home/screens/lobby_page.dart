import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/audio_service.dart';
import '../../shop/screens/shop_page.dart';
import '../../inventory/screens/inventory_page.dart';
import '../../gacha/screens/gacha_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/profile_service.dart';

/// Lobby Page - Main home screen with new Cyberpunk UI
class LobbyPage extends ConsumerStatefulWidget {
  const LobbyPage({super.key});

  @override
  ConsumerState<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends ConsumerState<LobbyPage> {

  bool _hasClaimedDaily = true;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkDailyStatus();
    // Start BGM on Lobby Entry, small delay to ensure build is ready
    Future.microtask(() => ref.read(audioServiceProvider).playBgm());
  }

  Future<void> _checkDailyStatus() async {
    // Small delay to ensure profile is loaded if entering directly
    if (ref.read(currentProfileProvider) == null) await Future.delayed(const Duration(milliseconds: 500));
    
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final lastClaim = prefs.getString('last_daily_claim_${profile.id}');
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    if (mounted) {
      setState(() {
        _hasClaimedDaily = lastClaim == today;
        _isChecking = false;
      });
    }
  }

  Future<void> _claimDaily() async {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return;

    try {
       final service = ProfileService();
       final newGems = profile.gems + 1000;
       await service.updateGems(profile.id, newGems);
       
       final prefs = await SharedPreferences.getInstance();
       final today = DateTime.now().toIso8601String().split('T')[0];
       await prefs.setString('last_daily_claim_${profile.id}', today);

       await ref.read(authProvider.notifier).refreshProfile();
       
       if (mounted) {
         setState(() {
           _hasClaimedDaily = true;
         });
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Daily Login Reward: +1000 GEMS!"), backgroundColor: Colors.cyan));
       }
    } catch (e) {
       print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only watch the providers we need for data, logic remains same
    final profile = ref.watch(currentProfileProvider);
    // Watch audio service just to rebuild icon? 
    // Actually AudioService isn't a Notifier yet, it's a raw class. 
    // Ideally AudioService should notify listeners.
    // For now, I'll use setState locally when toggling, or better, keep it simple.
    
    // Auth logic is handled via ref.read in callbacks

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final audioService = ref.watch(audioServiceProvider);

    // Main Gradient Background
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('ANIMYST HUB'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // MUTE BUTTON
          StatefulBuilder(
            builder: (context, setStateInternal) {
              return IconButton(
                icon: Icon(audioService.isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white70),
                onPressed: () async {
                   await audioService.toggleMute();
                   setStateInternal(() {}); // Rebuild button only
                },
              );
            }
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E004F), // Deep Purpleish Black
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Row & Daily Claim
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WELCOME BACK,',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white70,
                            letterSpacing: 2.0,
                          ),
                        ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
                        
                        Text(
                          profile.username.toUpperCase(),
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 32, // Slightly smaller to fit button
                            fontWeight: FontWeight.bold,
                            shadows: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary,
                                blurRadius: 20,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                      ],
                    ),
                    
                    // Daily Claim Button
                    _buildDailyButton(),
                  ],
                ),

                const SizedBox(height: 30),

                // 2. Stats / Currencies Row (Glassmorphism)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCurrencyItem(context, 'GEMS', '${profile.gems}', Icons.diamond, Colors.cyanAccent),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildCurrencyItem(context, 'DUST', '${profile.dust}', Icons.auto_fix_high, Colors.amberAccent),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildCurrencyItem(context, 'PITY', '${profile.pityCounter}/69', Icons.favorite, Colors.pinkAccent),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                const SizedBox(height: 40),

                // 3. Grid Menu Title
                Text(
                  'MAIN MODULES',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    letterSpacing: 1.5,
                  ),
                ).animate().fadeIn(delay: 600.ms),
                
                const SizedBox(height: 16),

                // 4. Grid Menus
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    _buildMenuCard(
                      context,
                      'GACHA SYSTEM',
                      'Summon Entities',
                      Icons.casino_rounded,
                      Colors.purpleAccent,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GachaPage())),
                    ),
                    _buildMenuCard(
                      context,
                      'INVENTORY',
                      'Manage Assets',
                      Icons.inventory_2_rounded,
                      Colors.blueAccent,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryPage())),
                    ),
                    _buildMenuCard(
                      context,
                      'SHOP',
                      'Acquire Gems',
                      Icons.shopping_cart_rounded,
                      Colors.amber,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopPage())),
                    ),
                    _buildMenuCard(
                      context,
                      'PROFILE',
                      'User Data',
                      Icons.person_outline,
                      Colors.tealAccent,
                      () {
                         ref.read(authProvider.notifier).refreshProfile();
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Refreshed!')));
                      },
                    ),
                  ],
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white54,
            fontSize: 10,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, String subtitle, IconData icon, Color accentColor, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF252525),
                const Color(0xFF121212),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 32),
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15, // Adjusted to fit
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SYSTEM LOGOUT'),
        content: const Text('Disconnect from Animyst Server?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.8),
              foregroundColor: Colors.white,
            ),
            child: const Text('DISCONNECT'),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyButton() {
    if (_isChecking) return const SizedBox.shrink();

    if (_hasClaimedDaily) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: const Row(
          children: [
             Icon(Icons.check_circle, size: 16, color: Colors.greenAccent),
             SizedBox(width: 6),
             Text("CLAIMED", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _claimDaily,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.pinkAccent, Colors.purpleAccent]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
             BoxShadow(color: Colors.pinkAccent.withOpacity(0.5), blurRadius: 15, spreadRadius: 1)
          ],
        ),
        child: const Row(
          children: [
             Icon(Icons.card_giftcard, size: 20, color: Colors.white),
             SizedBox(width: 8),
             Text("CLAIM 1000💎", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.05, 1.05)),
    );
  }
}
