# 🎰 GACHA SYSTEM - Complete Implementation Guide

## ✅ Tahap 4 Complete - Logic Core Gacha

### Overview
Sistem gacha lengkap dengan pity system, RNG, multi-pull, dan result display sudah selesai diimplementasi!

---

## 📁 Files Created

```
✅ lib/features/gacha/screens/gacha_page.dart          - Main gacha UI
✅ lib/features/gacha/widgets/gacha_result_dialog.dart - Result display
✅ lib/core/constants/app_constants.dart               - UPDATED (pity 69)
✅ lib/features/home/screens/lobby_page.dart           - UPDATED (navigation)
```

---

## 🎯 Gacha Mechanics

### 1. Pity System
```
Pity Counter: 0-69
- Starts at 0
- +1 setiap pull yang TIDAK dapat Ultra Rare
- Reset ke 0 ketika dapat Ultra Rare
- GUARANTEED Ultra Rare at pull #70 (pity = 69)
```

**Logic:**
```dart
if (pity_counter >= 69) {
  // FORCED Ultra Rare
  result = randomUltraRare();
  pity_counter = 0;
} else {
  // Normal RNG
  result = performRNG();
  if (result != Ultra Rare) {
    pity_counter++;
  } else {
    pity_counter = 0;
  }
}
```

---

### 2. Drop Rates

**Normal RNG (pity < 69):**
```
| Rarity      | Rate  | Range      |
|-------------|-------|------------|
| Ultra Rare  | 0.5%  | 0.0 - 0.5  |
| Super Rare  | 4.5%  | 0.5 - 5.0  |
| Rare        | 15%   | 5.0 - 20.0 |
| Elite       | 30%   | 20.0 - 50.0|
| Normal      | 50%   | 50.0-100.0 |
```

**Implementation:**
```dart
final roll = random.nextDouble() * 100; // 0-100

if (roll < 0.5) return UltraRare;
if (roll < 5.0) return SuperRare;
if (roll < 20.0) return Rare;
if (roll < 50.0) return Elite;
return Normal;
```

---

### 3. Pull Costs

```
Single Pull (1x): 100 Gems
Ten Pull (10x):   900 Gems  (Save 100 gems - 10% discount!)
```

---

## 🎮 User Flow

### Flow 1: Single Pull (1x)
```
1. User di LobbyPage
   ↓
2. Click "Gacha Pull" button
   ↓
3. Navigate to GachaPage
   ↓
4. See pity counter & gems
   ↓
5. Click "1x Pull" (100 gems)
   ↓
6. Check: gems >= 100?
   ↓
7. ✅ YES:
   - Deduct 100 gems
   - Perform RNG (with pity check)
   - Get random card by rarity
   - Update pity counter
   - Save to user_cards (++quantity if duplicate)
   - Show result dialog
   ↓
8. ❌ NO:
   - Show error: "Gems tidak cukup!"
```

### Flow 2: Ten Pull (10x)
```
1. Click "10x Pull" (900 gems)
   ↓
2. Check: gems >= 900?
   ↓
3. ✅ YES:
   - Deduct 900 gems FIRST
   - Loop 10 times:
     * Check pity
     * Perform RNG
     * Get card
     * Update pity
     * Save to inventory
   - Update final pity to DB
   - Show results dialog (all 10 cards)
   ↓
4. ❌ NO:
   - Show error: "Need X more gems"
```

---

## 💻 Code Structure

### GachaService Logic

**performSinglePull():**
```dart
1. Get user profile
2. Check gems >= 100
3. Determine rarity (with pity check)
4. Get random card of that rarity
5. Deduct 100 gems
6. Update pity counter:
   - If UR: reset to 0
   - Else: increment +1
7. Add card to inventory
8. Return GachaResult
```

**performTenPull():**
```dart
1. Get user profile
2. Check gems >= 900
3. Deduct 900 gems (FIRST!)
4. currentPity = profile.pityCounter
5. Loop 10 times:
   a. Determine rarity (check currentPity)
   b. Get random card
   c. Update currentPity:
      - If UR: currentPity = 0
      - Else: currentPity++
   d. Add to inventory
   e. Add to results[]
6. Update final pity to DB
7. Return results[]
```

---

## 🎨 UI Components

### GachaPage Features:
- ✅ **Saldo Display:** Gems & Pity counter
- ✅ **Pity Warning:** Shows when pity <= 10
- ✅ **Animated Chest:** Breathing/pulsing animation
- ✅ **Pull Buttons:**
  - 1x Pull card (100 gems)
  - 10x Pull card (900 gems with discount badge)
  - Disabled if not enough gems
  - Shows "Need X more gems" if insufficient
- ✅ **Drop Rates:** Expandable info card
- ✅ **Loading State:** While pulling
- ✅ **Refresh Button:** Update profile

### Result Dialog Features:
- ✅ **Special Header:** Golden if Ultra Rare detected
- ✅ **Pity Badge:** Shows "PITY TRIGGERED" if applicable
- ✅ **Card Display:**
  - Card name
  - Rarity color border & glow
  - Rarity icon & badge
  - Different size for 1x vs 10x
- ✅ **Summary:** Rarity distribution (10x pull)
- ✅ **Close Button:** Returns to GachaPage

---

## 🎯 Pity System Examples

### Example 1: Normal Pulls
```
Pull 1: pity=0  → RNG → Elite    → pity=1
Pull 2: pity=1  → RNG → Normal   → pity=2
Pull 3: pity=2  → RNG → Rare     → pity=3
...
Pull 50: pity=49 → RNG → UR (lucky!) → pity=0
Pull 51: pity=0  → RNG → Normal  → pity=1
```

### Example 2: Hit Pity
```
Pull 1-69: No UR → pity increases to 69
Pull 70: pity=69 → FORCED UR → pity=0
Pull 71: pity=0  → RNG starts fresh
```

### Example 3: Ten Pull with Pity
```
Start: pity=65
Pull 1-4: No UR → pity = 69
Pull 5: pity=69 → FORCED UR → pity=0
Pull 6-10: Normal RNG → pity increases

Result: Got 1 guaranteed UR + 5 random pulls
```

---

## 🗄️ Database Operations

### During Pull:

```sql
-- 1. Deduct gems
UPDATE profiles
SET gems = gems - 100  -- or 900 for ten pull
WHERE id = user_id;

-- 2. Get random card by rarity
SELECT * FROM cards
WHERE rarity = 'Ultra Rare'
ORDER BY RANDOM()
LIMIT 1;

-- 3. Add/Update inventory
-- If card NOT in inventory:
INSERT INTO user_cards (user_id, card_id, quantity)
VALUES (user_id, card_id, 1);

-- If card ALREADY in inventory:
UPDATE user_cards
SET quantity = quantity + 1,
    updated_at = NOW()
WHERE user_id = user_id AND card_id = card_id;

-- 4. Update pity counter
UPDATE profiles
SET pity_counter = new_pity
WHERE id = user_id;
```

---

## 🎨 Rarity Colors & Icons

```dart
Ultra Rare (UR):
- Color: Yellow (Gold)
- Icon: auto_awesome
- Glow: Yellow shadow

Super Rare (SR):
- Color: Purple
- Icon: star
- Glow: Purple shadow

Rare (R):
- Color: Blue
- Icon: grade
- Glow: Blue shadow

Elite (E):
- Color: Green
- Icon: favorite
- Glow: Green shadow

Normal (N):
- Color: Grey
- Icon: circle
- Glow: Grey shadow
```

---

## 🧪 Testing Guide

### Test 1: Single Pull
```
1. Login user
2. Ensure gems >= 100
3. Go to Gacha
4. Click "1x Pull"
5. ✅ Should:
   - Deduct 100 gems
   - Show loading
   - Display result dialog
   - Show card with rarity color
   - Update pity +1 (or reset if UR)
   - Close dialog → back to GachaPage
```

### Test 2: Ten Pull
```
1. Ensure gems >= 900
2. Click "10x Pull"
3. ✅ Should:
   - Deduct 900 gems
   - Show loading
   - Display all 10 cards in grid
   - Show rarity summary
   - Update pity correctly
```

### Test 3: Insufficient Gems
```
1. User has 50 gems
2. Try 1x pull
3. ❌ Should show: "Gems tidak cukup!"
4. Button should be disabled
```

### Test 4: Pity System
```
Method 1: Manual SQL
UPDATE profiles SET pity_counter = 69 WHERE id = 'user-id';

Method 2: Pull 70 times
- Do 69 pulls without UR
- 70th pull MUST be UR

Method 3: Ten Pull near pity
- Set pity = 65
- Do 10x pull
- Should get guaranteed UR at pull #5
```

### Test 5: Duplicate Cards
```
1. Do multiple pulls
2. Get same card multiple times
3. ✅ Check inventory:
   - Quantity should increase
   - NOT create duplicate rows
```

---

## 📊 Analytics Examples

**After 10x pull, Result Dialog shows:**
```
🎉 10x Pull Results!

┌─────────────────┐
│ Cards Grid (10) │
│ [Card] [Card]   │
│ [Card] [Card]   │
│ ...             │
└─────────────────┘

Summary:
● Ultra Rare: 1
● Super Rare: 0
⬤ Rare: 2
⬤ Elite: 3
⬤ Normal: 4
```

---

## ⚙️ Configuration

### Change Pity Counter Max:
```dart
// lib/core/constants/app_constants.dart
static const int maxPityCounter = 69; // Change here
```

### Change Rates:
```dart
static const double ultraRareRate = 0.5;   // UR
static const double superRareRate = 4.5;   // SR
static const double rareRate = 15.0;       // R
static const double eliteRate = 30.0;      // E
static const double normalRate = 50.0;     // N
```

### Change Costs:
```dart
static const int singlePullCost = 100;
static const int tenPullCost = 900;
```

---

## 🐛 Troubleshooting

### Problem: Pull berhasil tapi gems tidak berkurang
**Solution:**
- Check ProfileService.updateGems()
- Verify Supabase connection
- Check console logs

### Problem: Pity tidak reset setelah dapat UR
**Solution:**
- Check logic di GachaService._determineRarity()
- Verify updatePityCounter() called
- Check database trigger

### Problem: Duplicate cards di inventory
**Solution:**
- Check InventoryService.addCardToInventory()
- Should use UPDATE ... SET quantity+1
- Not INSERT new row

### Problem: Result dialog tidak muncul
**Solution:**
- Check import GachaResultDialog
- Verify showDialog() called
- Check console errors

---

## 📈 Statistics & Probabilities

**Expected UR in 70 pulls (with pity):**
```
Without pity: ~30% chance (0.995^70 = 70% miss all)
With pity: 100% guaranteed at pull #70
```

**Average pulls to get UR:**
```
Pure RNG: ~200 pulls (1/0.005)
With pity: Max 70 pulls, Average ~35-40
```

**Expected 10x pull distribution:**
```
Normal: ~5 cards (50%)
Elite: ~3 cards (30%)
Rare: ~1.5 cards (15%)
Super Rare: ~0.45 cards (4.5%)
Ultra Rare: ~0.05 cards (0.5%)
```

---

## ✅ Implementation Checklist

- [x] Update AppConstants (pity = 69, rates)
- [x] GachaService logic (single & ten pull)
- [x] Pity system implementation
- [x] RNG with correct rates
- [x] Database updates (gems, pity, inventory)
- [x] GachaPage UI
- [x] Animated chest display
- [x] Pull buttons (1x & 10x)
- [x] Gems validation
- [x] Pity counter display
- [x] Drop rates info
- [x] GachaResultDialog
- [x] Card display with rarity colors
- [x] Pity triggered indicator
- [x] Summary for 10x pulls
- [x] Navigation from Lobby
- [x] Error handling
- [x] Loading states

---

## 🎉 Ready Features

### User Can:
- ✅ View pity counter & gems
- ✅ See drop rates
- ✅ Perform 1x pull (100 gems)
- ✅ Perform 10x pull (900 gems, 10% discount)
- ✅ Get guaranteed UR at pity
- ✅ See beautiful result display
- ✅ Know if pity was triggered
- ✅ View rarity distribution (10x)
- ✅ Cards auto-added to inventory
- ✅ Duplicate cards increase quantity

---

## 🚀 Next Steps

After gacha complete:

1. ✅ **Gacha System** - DONE
2. 🔜 **Inventory Display** - Show user cards
3. 🔜 **Recycle System** - Convert dupes to dust
4. 🔜 **Card Details** - View card stats
5. 🔜 **Animations** - Gacha pull VFX
6. 🔜 **Sound Effects** - Pull & reveal sounds

---

**🎰 TAHAP 4 COMPLETE!** 

Test gacha pulls dan siap untuk tahap selanjutnya! ✨
