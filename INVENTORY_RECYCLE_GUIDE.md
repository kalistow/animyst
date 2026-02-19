# 📦 INVENTORY & RECYCLE SYSTEM - Complete Implementation Guide

## ✅ Tahap 5 Complete - Inventory & Recycle

### Overview
Sistem inventory lengkap dengan grid display, recycle feature, UR collection tracker, dan reward system sudah selesai diimplementasi!

---

## 📁 Files Created/Updated

```
✅ lib/features/inventory/screens/inventory_page.dart              - Main inventory UI (REPLACED)
✅ lib/features/inventory/widgets/card_detail_dialog.dart          - Card detail & recycle
✅ lib/features/inventory/widgets/collection_complete_dialog.dart  - Reward celebration
✅ lib/core/services/inventory_service.dart                        - UPDATED (recycle logic)
```

---

## 🎯 Features Implemented

### 1. Inventory Grid Display ✅
```
- GridView dengan 3 columns
- Menampilkan semua kartu yang dimiliki user
- Data dari user_cards JOIN cards
- Sort by obtained_at descending (newest first)
```

**Card Item Features:**
- ✅ Card icon (rarity-based)
- ✅ Card name
- ✅ Rarity badge (U/S/R/E/N)
- ✅ Rarity-colored border & glow
- ✅ Quantity badge ("x3" if multiple)
- ✅ Tap to view details

---

### 2. Ultra Rare Collection Tracker ✅
```
Progress Bar: "X / 5 Collected"
- Count unique Ultra Rare cards
- Progress bar animation
- "COMPLETE!" badge when 5 UR collected
- "KLAIM REWARD SPESIAL" button
```

**Reward Logic:**
```dart
if (ultraRareCount >= 5 && !hasClaimedReward) {
  // Show celebration dialog
  // Confetti animation
  // "Master Collector" achievement
}
```

---

### 3. Card Detail & Recycle ✅

**Feature:**
- Tap card → Show detail dialog
- Display: Large icon, name, rarity,description, stats
- Recycle value in Dust
- Current quantity owned
- "Recycle for Dust" button

**Recycle Logic:**
```dart
1. Confirm dialog
2. Decrease quantity by 1
3. If quantity == 0, delete row
4. Add dust to profile
5. Refresh profile ( Riverpod)
6. Reload inventory
7. Show success message
```

**SQL Operations:**
```sql
-- If quantity > 1:
UPDATE user_cards
SET quantity = quantity - 1
WHERE user_id = ? AND card_id = ?;

-- If quantity == 1:
DELETE FROM user_cards
WHERE user_id = ? AND card_id = ?;

-- Add dust:
UPDATE profiles
SET dust = dust + recycle_value
WHERE id = ?;
```

---

### 4. Collection Complete Dialog ✅

**Features:**
- 🎊 **Confetti Animation:** 30 particles falling
- 🏆 **Trophy Icon:** Rotating animation
- ⭐ **Achievement Badge:** "Master Collector"
- 💝 **Reward Message:** Special developer message
- 🎁 **Claim Button:** Mark as claimed

**Animations:**
- Scale transition (elastic out)
- Rotating trophy
- Falling confetti particles
- Gradient background (purple → blue → yellow)

---

## 💻 Code Structure

### InventoryPage State
```dart
class _InventoryPageState {
  List<Map<String, dynamic>> _userCards = [];
  bool _isLoading = true;
  int _ultraRareCount = 0;
  bool _hasClaimedReward = false;

  // Methods:
  - _loadInventory()
  - _handleRecycle()
  - _showCollectionCompleteDialog()
  - _buildCardItem()
}
```

### Load Inventory Logic
```dart
Future<void> _loadInventory() async {
  1. Get user profile from provider
  2. Fetch user_cards WITH card details (JOIN)
  3. Count Ultra Rare cards
  4. Update state
  5. Check if collection complete (5 UR)
  6. Show reward dialog if eligible
}
```

### Recycle Logic
```dart
Future<void> _handleRecycle(Card card, int quantity) async {
  1. Call inventoryService.recycleCard()
     - Decrease quantity
     - Get dust value
  2. Update dust in profiles table
  3. Refresh profile (Riverpod)
  4. Reload inventory
  5. Show success SnackBar
}
```

---

## 🎨 UI Components

### Inventory Page Layout:
```
┌────────────────────────────┐
│ Inventory       [Refresh]  │
├────────────────────────────┤
│ ┌──────────────────────┐   │
│ │ ⭐ Ultra Rare        │   │
│ │ X / 5 Collected      │   │
│ │ [Progress Bar ████  ]│   │
│ │ [KLAIM REWARD] (if 5)│   │
│ └──────────────────────┘   │
│                            │
│ ┌──────┐  ┌──────┐        │
│ │Unique│  │Total │        │
│ │  5   │  │  12  │        │
│ └──────┘  └──────┘        │
│                            │
│ ┌──┐┌──┐┌──┐  (Grid 3x)   │
│ │🎴││🎴││🎴│              │
│ │x2││x1││x5│              │
│ └──┘└──┘└──┘              │
│ ┌──┐┌──┐ ...              │
│ │🎴││🎴│                  │
│ └──┘└──┘                  │
└────────────────────────────┘
```

### Card Detail Dialog:
```
┌────────────────────────┐
│ ⭐ Sword Legendary     │ ← Golden header
│                    x3  │
├────────────────────────┤
│                        │
│       ┌──────┐         │
│       │ ICON │         │ ← Large icon
│       └──────┘         │
│                        │
│ "A legendary sword..." │ ← Description
│                        │
│ ┌──────────────────┐   │
│ │ ♻️ Recycle: 150  │   │ ← Recycle value
│ │ 📦 You own: x3    │   │
│ └──────────────────┘   │
│                        │
│ [Recycle for Dust]     │ ← Recycle button
│ [Close]                │
└────────────────────────┘
```

### Collection Complete Dialog:
```
┌────────────────────────┐
│   ✨ Confetti ✨      │ ← Animated
│                        │
│      ┌─────┐           │
│      │ 🏆  │           │ ← Rotating
│      └─────┘           │
│                        │
│ 🎊 CONGRATULATIONS! 🎊│
│ You are a True         │
│ Collector!             │
│                        │
│ ┌──────────────────┐   │
│ │ ⭐ Achievement   │   │
│ │ Master Collector │   │
│ └──────────────────┘   │
│                        │
│ "Special reward..."    │
│                        │
│ [CLAIM REWARD]         │
└────────────────────────┘
```

---

## 🎮 User Flow

### Flow 1: View Inventory
```
1. User di Lobby Page
   ↓
2. Click tab "Inventory"
   ↓
3. Load inventory:
   - Fetch user_cards + card details
   - Count Ultra Rare
   - Display grid
   ↓
4. See:
   - Ultra Rare progress: 3/5
   - Unique Cards: 8
   - Total Cards: 15
   - Grid of  cards with quantities
```

### Flow 2: Recycle Card
```
1. Tap on a card in grid
   ↓
2. Card Detail Dialog opens:
   - Large icon
   - Card info
   - Recycle value: 30 Dust
   - Quantity: x5
   ↓
3. Click "Recycle for Dust"
   ↓
4. Confirmation:
   "Convert 1x Sword to 30 Dust?
    You will have 4 left."
   ↓
5. Click "Recycle"
   ↓
6. Backend:
   - quantity: 5 → 4
   - dust: 100 → 130
   - Refresh profile
   - Reload inventory
   ↓
7. ✅ "Recycled! +30 Dust"
   ↓
8. Dialog closes
   - Inventory updated
   - Card now shows "x4"
   - Dust in Lobby/Shop updated automatically
```

### Flow 3: Complete Collection
```
1. User has 4 Ultra Rare cards
   - Progress: 4/5
   ↓
2. Do gacha pull
   ↓
3. Get 5th Ultra Rare!
   ↓
4. Return to Inventory
   ↓
5. _loadInventory() detects: ultraRareCount = 5
   ↓
6. Auto-show Collection Complete Dialog:
   - Confetti animation
   - Trophy rotating
   - "CONGRATULATIONS!"
   - "Master Collector" achievement
   ↓
7. Click "CLAIM REWARD"
   ↓
8. Dialog closes
   - hasClaimedReward = true
   - Button changes to "COMPLETE!" badge
```

---

## 🗄️ Database Operations

### Fetch Inventory with Details:
```sql
SELECT 
  user_cards.*,
  cards.*
FROM user_cards
INNER JOIN cards ON user_cards.card_id = cards.id
WHERE user_cards.user_id = 'user-id'
ORDER BY user_cards.obtained_at DESC;
```

**Supabase Syntax:**
```dart
await _supabase
    .from('user_cards')
    .select('*, cards(*)')
    .eq('user_id', userId)
    .order('obtained_at', ascending: false);
```

**Result Format:**
```json
[
  {
    "id": "uc-1",
    "user_id": "user-123",
    "card_id": "card-abc",
    "quantity": 3,
    "obtained_at": "2026-02-01...",
    "cards": {
      "id": "card-abc",
      "name": "Sword",
      "rarity": "Ultra Rare",
      "recycle_dust_value": 150,
      ...
    }
  },
  ...
]
```

### Recycle Operation:
```sql
-- Transaction:
BEGIN;

-- 1. Decrease quantity or delete
UPDATE user_cards 
SET quantity = quantity - 1
WHERE user_id = ? AND card_id = ?;
-- If quantity becomes 0, DELETE instead

-- 2. Add dust
UPDATE profiles
SET dust = dust + ?
WHERE id = ?;

COMMIT;
```

---

## 🎨 Rarity Colors

```dart
Ultra Rare (UR): Colors.yellow      (Gold)
Super Rare (SR): Colors.purple      (Purple)
Rare (R):        Colors.blue        (Blue)
Elite (E):       Colors.green       (Green)
Normal (N):      Colors.grey        (Grey)
```

**Applied to:**
- Border color
- Icon color
- Badge background
- Glow/shadow effect

---

## 🧪 Testing Guide

### Test 1: View Empty Inventory
```
1. New user (no cards)
2. Go to Inventory
3. ✅ Should show:
   - "No cards yet"
   - "Go to Gacha" button
   - UR Progress: 0/5
   - Unique: 0, Total: 0
```

### Test 2: View Cards
```
1. User with cards
2. Go to Inventory
3. ✅ Should show:
   - Grid of cards
   - Correct quantities ("x3")
   - Rarity colors
   - UR progress updated
```

### Test 3: Card Detail
```
1. Tap on a card
2. ✅ Dialog should show:
   - Large icon
   - Card name & rarity
   - Description
   - Recycle value
   - Current quantity
   - Recycle button
```

### Test 4: Recycle Single Card
```
1. User has: Sword x1, Dust: 100
2. Tap Sword → Recycle
3. Confirm
4. ✅ Should:
   - Remove Sword from inventory (quantity 0)
   - Dust: 100 → 130 (if recycle value = 30)
   - Card disappears from grid
   - Success message shows
```

### Test 5: Recycle Duplicate
```
1. User has: Shield x5, Dust: 50
2. Tap Shield → Recycle
3. Confirm
4. ✅ Should:
   - Shield quantity: 5 → 4
   - Dust: 50 → 80 (if recycle value = 30)
   - Card still in grid, shows "x4"
```

### Test 6: Collection Complete
```
Method 1 - Manual Insert:
-- Insert 5 different Ultra Rare cards
INSERT INTO user_cards (user_id, card_id, quantity)
VALUES 
  ('user-id', 'ur-card-1', 1),
  ('user-id', 'ur-card-2', 1),
  ('user-id', 'ur-card-3', 1),
  ('user-id', 'ur-card-4', 1),
  ('user-id', 'ur-card-5', 1);

Method 2 - Gacha Pulls:
-- Keep pulling until you get 5 different UR

Then:
1. Navigate to Inventory
2. ✅ Should auto-show:
   - Confetti dialog
   - "CONGRATULATIONS!"
   - "Master Collector"
   - Claim button
3. Click Claim
4. ✅ Dialog closes
5. ✅ "COMPLETE!" badge shows
```

### Test 7: State Refresh
```
1. User at Inventory: Dust: 100
2. Recycle card (+30 dust)
3. ✅ Inventory updates
4. Go to Shop tab
5. ✅ Should show: Dust: 130 (no refresh needed!)
6. Go to Lobby tab
7. ✅ Should show: Dust: 130 (automatic!)
```

---

## 📊 Statistics & Metrics

**Unique vs Total:**
- **Unique Cards:** Distinct card_id count
- **Total Cards:** Sum of all quantities

**Example:**
```
User has:
- Sword x3
- Shield x2
- Helmet x1

Unique: 3 cards
Total: 6 cards
```

**Ultra Rare Count:**
```
Filter cards WHERE rarity = 'Ultra Rare'
Count unique card_id only (not quantity)

If user has:
- UR Dragon x3
- UR Phoenix x1

UR Count = 2 (not 4!)
```

---

## ⚙️ Configuration

### Change UR Required for Reward:
```dart
// InventoryPage
if (_ultraRareCount >= 5) {  // Change 5 to any number
  _showCollectionCompleteDialog();
}
```

### Change Recycle Dust Values:
```sql
-- In database (cards table)
UPDATE cards
SET recycle_dust_value = 200  -- New value
WHERE rarity = 'Ultra Rare';
```

Or via Card.fromJson() from database.

---

## 🐛 Troubleshooting

### Problem: Inventory tidak update setelah recycle
**Solution:**
- Check await _loadInventory() dipanggil
- Verify ref.read(authProvider.notifier).refreshProfile()
- Check Supabase update success

### Problem: Dust tidak bertambah
**Solution:**
- Check ProfileService.updateDust()
- Verify calculation: profile.dust + dustGained
- Check database constraint (dust >= 0?)

### Problem: Collection dialog tidak muncul
**Solution:**
- Check ultraRareCount calculation
- Verify hasClaimedReward state
- Check if >= 5 unique UR cards

### Problem: Card class conflict
**Solution:**
- Import dengan 'as models'
- Use models.Card instead of Card
- This avoids conflict with Flutter's Card widget

---

## 🔄 State Management

**Riverpod Integration:**
```dart
// Read current profile
final profile = ref.read(currentProfileProvider);

// Refresh after update
await ref.read(authProvider.notifier).refreshProfile();

// Watch for changes
final profile = ref.watch(currentProfileProvider);
```

**Auto-Update Flow:**
```
Recycle Card
  ↓
Update Dust in DB
  ↓
refreshProfile()
  ↓
currentProfileProvider updated
  ↓
ALL widgets watching this provider re-render
  ↓
Lobby/Shop/Inventory show new dust value
  (No manual refresh needed!)
```

---

## ✅ Implementation Checklist

- [x] InventoryService with getUserCardsWithDetails()
- [x] InventoryService with recycleCard()
- [x] InventoryPage with GridView
- [x] Card items with rarity colors
- [x] Quantity badges
- [x] Tap to view details
- [x] Ultra Rare collection tracker
- [x] Progress bar animation
- [x] CardDetailDialog
- [x] Recycle feature with confirmation
- [x] Dust update logic
- [x] Profile refresh integration
- [x] CollectionCompleteDialog
- [x] Confetti animation
- [x] Trophy rotation
- [x] Achievement badge
- [x] Reward claim system
- [x] State management with Riverpod
- [x] Error handling
- [x] Loading states
- [x] Empty state UI

---

## 🎉 Ready Features

### User Can:
- ✅ View all owned cards in grid
- ✅ See card quantities
- ✅ See rarity-colored borders
- ✅ Track Ultra Rare collection progress
- ✅ Tap card to view details
- ✅ See recycle dust value
- ✅ Recycle cards for dust
- ✅ Get confirmation before recycle
- ✅ See dust auto-update everywhere
- ✅ Get rewarded for completing collection
- ✅ See celebration animation
- ✅ Claim "Master Collector" achievement
- ✅ Refresh inventory manually
- ✅ Navigate to Gacha if empty

---

## 🚀 Next Steps

After Inventory complete:

1. ✅ **Inventory & Recycle** - DONE
2. 🔜 **Card Images** - Add real animal images
3. 🔜 **Enhanced Animations** - Gacha pull VFX
4. 🔜 **Sound Effects** - Audio feedback
5. 🔜 **Leaderboard** - Compare collections
6. 🔜 **Trading System** - Card exchange

---

**📦 TAHAP 5 COMPLETE!**

Test inventory, recycle, dan collection reward! ✨
