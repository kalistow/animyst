import 'package:flutter/material.dart';
import '../core/models/models.dart';
import '../core/services/services.dart';
import '../core/enums/enums.dart';
import '../main.dart';

/// 🎨 EXAMPLE SCREENS - Reference Implementation
/// 
/// File ini berisi contoh-contoh screen sederhana untuk referensi.
/// Copy & customize sesuai kebutuhan Anda.

// ============================================================================
// EXAMPLE 1: Profile Display Screen
// ============================================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  Profile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      _profile = await _profileService.getProfile(userId);
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? const Center(child: Text('Profile not found'))
              : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username
          Text(
            _profile!.username,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.diamond,
                  label: 'Gems',
                  value: _profile!.gems.toString(),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.auto_awesome,
                  label: 'Dust',
                  value: _profile!.dust.toString(),
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pity Counter
          _buildStatCard(
            icon: Icons.timeline,
            label: 'Pity Counter',
            value: '${_profile!.pityCounter} / 90',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 2: Simple Gacha Screen
// ============================================================================

class SimpleGachaScreen extends StatefulWidget {
  const SimpleGachaScreen({super.key});

  @override
  State<SimpleGachaScreen> createState() => _SimpleGachaScreenState();
}

class _SimpleGachaScreenState extends State<SimpleGachaScreen> {
  final GachaService _gachaService = GachaService();
  final ProfileService _profileService = ProfileService();
  
  Profile? _profile;
  bool _isLoading = false;
  bool _isPulling = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      _profile = await _profileService.getProfile(userId);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _performSinglePull() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isPulling = true);

    final result = await _gachaService.performSinglePull(userId);

    if (result != null && mounted) {
      // Show result dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Gacha Result!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 64,
                color: _getRarityColor(result.card.rarity),
              ),
              const SizedBox(height: 16),
              Text(
                result.card.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.card.rarity.displayName,
                style: TextStyle(
                  color: _getRarityColor(result.card.rarity),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (result.isPityTriggered)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '⭐ PITY ACTIVATED!',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loadProfile(); // Refresh profile
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough gems!')),
      );
    }

    setState(() => _isPulling = false);
  }

  Color _getRarityColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.normal:
        return Colors.grey;
      case Rarity.elite:
        return Colors.blue;
      case Rarity.rare:
        return Colors.purple;
      case Rarity.superRare:
        return Colors.amber;
      case Rarity.ultraRare:
        return Colors.pink;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gacha'),
        actions: [
          // Gems display
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.diamond, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _profile?.gems.toString() ?? '0',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pity counter
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Pity Counter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_profile?.pityCounter ?? 0} / 90',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${90 - (_profile?.pityCounter ?? 0)} pulls until guaranteed Ultra Rare',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Pull button
            ElevatedButton(
              onPressed: _isPulling ? null : _performSinglePull,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: _isPulling
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Single Pull (100 💎)',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 3: Inventory Grid
// ============================================================================

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryService _inventoryService = InventoryService();
  final CardService _cardService = CardService();
  
  List<UserCard> _userCards = [];
  Map<String, Card> _cardDetails = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);

    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      // Get user cards
      _userCards = await _inventoryService.getUserCards(userId);

      // Get card details
      if (_userCards.isNotEmpty) {
        final cardIds = _userCards.map((uc) => uc.cardId).toList();
        final cards = await _cardService.getCardsByIds(cardIds);
        _cardDetails = {for (var card in cards) card.id: card};
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userCards.isEmpty
              ? const Center(
                  child: Text('No cards yet. Try pulling some!'),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _userCards.length,
                  itemBuilder: (context, index) {
                    final userCard = _userCards[index];
                    final card = _cardDetails[userCard.cardId];
                    
                    if (card == null) return const SizedBox();

                    return _buildCardItem(userCard, card);
                  },
                ),
    );
  }

  Widget _buildCardItem(UserCard userCard, Card card) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card image (placeholder)
          Expanded(
            child: Container(
              color: _getRarityColor(card.rarity).withOpacity(0.3),
              child: Icon(
                Icons.auto_awesome,
                size: 64,
                color: _getRarityColor(card.rarity),
              ),
            ),
          ),
          
          // Card info
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      card.rarity.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getRarityColor(card.rarity),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'x${userCard.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.normal:
        return Colors.grey;
      case Rarity.elite:
        return Colors.blue;
      case Rarity.rare:
        return Colors.purple;
      case Rarity.superRare:
        return Colors.amber;
      case Rarity.ultraRare:
        return Colors.pink;
    }
  }
}
