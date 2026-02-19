# 🚀 QUICK REFERENCE - Development Guide

Panduan cepat untuk development lanjutan Animyst Gacha Game.

---

## 📦 Import Statements

### Models
```dart
import 'package:animyst/core/models/models.dart';
// Includes: Profile, Card, UserCard

import 'package:animyst/core/enums/enums.dart';
// Includes: Rarity enum
```

### Services
```dart
import 'package:animyst/core/services/services.dart';
// Includes: ProfileService, CardService, InventoryService, GachaService

// Or import specific service
import 'package:animyst/core/services/gacha_service.dart';
```

### Constants
```dart
import 'package:animyst/core/constants/app_constants.dart';
```

### Supabase Client
```dart
import 'package:animyst/main.dart'; // for: supabase
// atau
import 'package:supabase_flutter/supabase_flutter.dart';
final supabase = Supabase.instance.client;
```

---

## 🎮 Common Code Snippets

### Authentication

#### Register User
```dart
final response = await supabase.auth.signUp(
  email: email,
  password: password,
  data: {
    'username': username, // Will be used in auto-create profile trigger
  },
);

// Profile will be auto-created by database trigger
```

#### Login
```dart
final response = await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);

// Update last login
final userId = response.user?.id;
if (userId != null) {
  await ProfileService().updateLastLogin(userId);
}
```

#### Logout
```dart
await supabase.auth.signOut();
```

#### Get Current User
```dart
final user = supabase.auth.currentUser;
if (user != null) {
  print('User ID: ${user.id}');
  print('Email: ${user.email}');
}
```

#### Listen to Auth State
```dart
supabase.auth.onAuthStateChange.listen((data) {
  final AuthChangeEvent event = data.event;
  final Session? session = data.session;
  
  if (event == AuthChangeEvent.signedIn) {
    // User logged in
  } else if (event == AuthChangeEvent.signedOut) {
    // User logged out
  }
});
```

---

### Profile Operations

#### Get Current User Profile
```dart
final profileService = ProfileService();
final profile = await profileService.getCurrentUserProfile();

if (profile != null) {
  print('Username: ${profile.username}');
  print('Gems: ${profile.gems}');
  print('Dust: ${profile.dust}');
  print('Pity Counter: ${profile.pityCounter}');
}
```

#### Update Gems
```dart
final profileService = ProfileService();
final success = await profileService.updateGems(userId, newGems);
```

#### Update Profile
```dart
final profileService = ProfileService();
final updatedProfile = profile.copyWith(
  username: 'NewUsername',
  gems: 500,
);
await profileService.updateProfile(updatedProfile);
```

---

### Gacha Operations

#### Single Pull
```dart
final gachaService = GachaService();
final userId = supabase.auth.currentUser?.id;

if (userId != null) {
  final result = await gachaService.performSinglePull(userId);
  
  if (result != null) {
    print('Got card: ${result.card.name}');
    print('Rarity: ${result.card.rarity.displayName}');
    print('Pity triggered: ${result.isPityTriggered}');
  } else {
    print('Failed to pull (not enough gems?)');
  }
}
```

#### Ten Pull
```dart
final gachaService = GachaService();
final userId = supabase.auth.currentUser?.id;

if (userId != null) {
  final results = await gachaService.performTenPull(userId);
  
  if (results != null) {
    print('Got ${results.length} cards:');
    for (final result in results) {
      print('- ${result.card.name} (${result.card.rarity.displayName})');
    }
  }
}
```

#### Check if Can Pull
```dart
final gachaService = GachaService();
final userId = supabase.auth.currentUser?.id;

if (userId != null) {
  final canSingle = await gachaService.canPerformSinglePull(userId);
  final canTen = await gachaService.canPerformTenPull(userId);
  
  print('Can single pull: $canSingle');
  print('Can ten pull: $canTen');
}
```

#### Get Probabilities
```dart
final gachaService = GachaService();
final profile = await ProfileService().getCurrentUserProfile();

if (profile != null) {
  final probs = gachaService.getProbabilities(profile.pityCounter);
  
  probs.forEach((rarity, percentage) {
    print('${rarity.displayName}: $percentage%');
  });
  
  final pullsLeft = gachaService.getPullsUntilPity(profile.pityCounter);
  print('Pulls until guaranteed Ultra Rare: $pullsLeft');
}
```

---

### Inventory Operations

#### Get User Inventory
```dart
final inventoryService = InventoryService();
final userId = supabase.auth.currentUser?.id;

if (userId != null) {
  final userCards = await inventoryService.getUserCards(userId);
  
  print('Total unique cards: ${userCards.length}');
  for (final userCard in userCards) {
    print('Card ID: ${userCard.cardId}, Quantity: ${userCard.quantity}');
  }
}
```

#### Get Inventory with Card Details
```dart
final inventoryService = InventoryService();
final cardService = CardService();
final userId = supabase.auth.currentUser?.id;

if (userId != null) {
  final userCards = await inventoryService.getUserCards(userId);
  
  // Get all card IDs
  final cardIds = userCards.map((uc) => uc.cardId).toList();
  
  // Fetch card details
  final cards = await cardService.getCardsByIds(cardIds);
  
  // Create map for easy lookup
  final cardMap = {for (var card in cards) card.id: card};
  
  // Display
  for (final userCard in userCards) {
    final card = cardMap[userCard.cardId];
    if (card != null) {
      print('${card.name} x${userCard.quantity} - ${card.rarity.displayName}');
    }
  }
}
```

#### Recycle Card
```dart
final inventoryService = InventoryService();
final cardService = CardService();
final profileService = ProfileService();
final userId = supabase.auth.currentUser?.id;

if (userId != null) {
  // Get card info
  final card = await cardService.getCard(cardId);
  if (card != null) {
    // Decrease quantity
    final success = await inventoryService.decreaseCardQuantity(
      userId, 
      cardId, 
      1, // recycle 1 card
    );
    
    if (success) {
      // Add dust to profile
      final profile = await profileService.getProfile(userId);
      if (profile != null) {
        final newDust = profile.dust + card.recycleDustValue;
        await profileService.updateDust(userId, newDust);
        
        print('Recycled ${card.name} for ${card.recycleDustValue} dust');
      }
    }
  }
}
```

---

### Card Operations

#### Get All Cards
```dart
final cardService = CardService();
final allCards = await cardService.getAllCards();

for (final card in allCards) {
  print('${card.name} - ${card.rarity.displayName}');
}
```

#### Get Cards by Rarity
```dart
final cardService = CardService();
final ultraRareCards = await cardService.getCardsByRarity(Rarity.ultraRare);

print('Found ${ultraRareCards.length} Ultra Rare cards');
```

---

## 🎨 UI Helpers

### Rarity Colors
```dart
Color getRarityColor(Rarity rarity) {
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
```

### Rarity Gradient
```dart
LinearGradient getRarityGradient(Rarity rarity) {
  switch (rarity) {
    case Rarity.normal:
      return LinearGradient(colors: [Colors.grey[700]!, Colors.grey[500]!]);
    case Rarity.elite:
      return LinearGradient(colors: [Colors.blue[700]!, Colors.blue[400]!]);
    case Rarity.rare:
      return LinearGradient(colors: [Colors.purple[700]!, Colors.purple[400]!]);
    case Rarity.superRare:
      return LinearGradient(colors: [Colors.amber[700]!, Colors.amber[300]!]);
    case Rarity.ultraRare:
      return LinearGradient(colors: [Colors.pink[700]!, Colors.pink[300]!]);
  }
}
```

### Format Numbers
```dart
String formatNumber(int number) {
  if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1)}M';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}K';
  }
  return number.toString();
}

// Usage
print(formatNumber(1500)); // "1.5K"
print(formatNumber(2500000)); // "2.5M"
```

---

## 🔔 Real-time Updates

### Listen to Profile Changes
```dart
final userId = supabase.auth.currentUser?.id;

if (userId != null) {
  supabase
    .from('profiles')
    .stream(primaryKey: ['id'])
    .eq('id', userId)
    .listen((data) {
      if (data.isNotEmpty) {
        final profile = Profile.fromJson(data.first);
        print('Profile updated: ${profile.gems} gems, ${profile.dust} dust');
        // Update UI
      }
    });
}
```

### Listen to Inventory Changes
```dart
final userId = supabase.auth.currentUser?.id;

if (userId != null) {
  supabase
    .from('user_cards')
    .stream(primaryKey: ['id'])
    .eq('user_id', userId)
    .listen((data) {
      final userCards = data.map((json) => UserCard.fromJson(json)).toList();
      print('Inventory updated: ${userCards.length} unique cards');
      // Update UI
    });
}
```

---

## 🧪 Testing / Debug

### Test Data Generation
```dart
// Test by giving gems
final userId = supabase.auth.currentUser?.id;
if (userId != null) {
  await ProfileService().updateGems(userId, 10000); // Give 10k gems
  print('✅ Added 10,000 gems for testing');
}
```

### Check Database Connection
```dart
Future<void> testConnection() async {
  try {
    final response = await supabase.from('cards').select().limit(1);
    print('✅ Database connection successful');
    print('Response: $response');
  } catch (e) {
    print('❌ Database connection failed: $e');
  }
}
```

### Log Gacha Statistics
```dart
void logGachaStats(List<GachaResult> results) {
  final rarityCount = <Rarity, int>{};
  
  for (final result in results) {
    rarityCount[result.card.rarity] = 
      (rarityCount[result.card.rarity] ?? 0) + 1;
  }
  
  print('=== Gacha Results ===');
  rarityCount.forEach((rarity, count) {
    print('${rarity.displayName}: $count');
  });
}
```

---

## 📊 State Management Suggestions

### Using Provider (Recommended)
```dart
// Add to pubspec.yaml:
// provider: ^6.1.0

// Create ProfileProvider
class ProfileProvider extends ChangeNotifier {
  Profile? _profile;
  final ProfileService _service = ProfileService();
  
  Profile? get profile => _profile;
  
  Future<void> loadProfile(String userId) async {
    _profile = await _service.getProfile(userId);
    notifyListeners();
  }
  
  Future<void> updateGems(String userId, int newGems) async {
    await _service.updateGems(userId, newGems);
    await loadProfile(userId);
  }
}

// Setup in main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ProfileProvider()),
  ],
  child: MyApp(),
)

// Use in widget
final profile = context.watch<ProfileProvider>().profile;
```

### Using Riverpod
```dart
// Add to pubspec.yaml:
// flutter_riverpod: ^2.4.0

// Create providers
final profileProvider = FutureProvider.family<Profile?, String>((ref, userId) async {
  return await ProfileService().getProfile(userId);
});

// Use in widget
final profileAsync = ref.watch(profileProvider(userId));
profileAsync.when(
  data: (profile) => Text('Gems: ${profile?.gems}'),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

---

## 🎯 Common Patterns

### Loading State Pattern
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  bool _isLoading = false;
  Profile? _profile;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      _profile = await ProfileService().getProfile(userId);
    }
    
    setState(() => _isLoading = false);
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return CircularProgressIndicator();
    if (_profile == null) return Text('No profile');
    
    return Text('Gems: ${_profile!.gems}');
  }
}
```

---

## 🔐 Security Notes

- ✅ **Never** expose `service_role` key di client
- ✅ **Always** use `anon` key di Flutter
- ✅ RLS policies akan protect data
- ✅ Users can only access their own data (except cards table which is public read)

---

**📘 Keep this file handy during development!**
