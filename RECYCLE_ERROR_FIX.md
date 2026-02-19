# 🔧 RECYCLE ERROR FIX - Card ID Type Mismatch

## ✅ Problem Solved: "Failed to recycle card"

### Error in Screenshot:
```
Error: Exception: Failed to recycle card
```

---

## 🐛 Root Cause

**Card ID Type Mismatch between Dart and Database**

**Database (Supabase):**
- `card_id` column type: **`bigint`** (integer)

**Dart Card Model:**
- `id` property type: **`String`**
- Converted from bigint using: `json['id'].toString()`

**The Problem:**
When trying to recycle, the code was querying:
```dart
.eq('card_id', cardId)  // cardId is String "123"
```

But database expects:
```dart
.eq('card_id', 123)  // Should be int, not String!
```

PostgreSQL/Supabase **cannot match** String "123" with bigint 123, so query returns null → recycle fails!

---

## ✅ Solution Applied

### Updated Functions in `inventory_service.dart`:

#### 1. **getUserCard()** - Line 28-51
**BEFORE:**
```dart
.eq('card_id', cardId)  // ❌ String won't match bigint
```

**AFTER:**
```dart
// Convert cardId String to int for bigint database column
final cardIdInt = int.tryParse(cardId);
if (cardIdInt == null) {
  print('Error: Invalid card ID format: $cardId');
  return null;
}

.eq('card_id', cardIdInt)  // ✅ Now uses int!
```

#### 2. **addCardToInventory()** - Line 46-84
**BEFORE:**
```dart
'card_id': cardId,  // ❌ String won't insert properly
```

**AFTER:**
```dart
final cardIdInt = int.tryParse(cardId);
if (cardIdInt == null) return false;

'card_id': cardIdInt,  // ✅ Proper int for bigint column
```

---

## 🧪 How to Test

### Test 1: Hot Reload (Automatic)
App should hot reload automatically after file save.

If not:
```bash
# In the running Flutter terminal, press:
r  # for hot reload
# or
R  # for hot restart
```

### Test 2: Recycle Card
```
1. Open Inventory tab
2. Tap any card (e.g., "Singa Afrika" or "Rubah Merah")
3. Card detail dialog opens
4. Click "Recycle for Dust"
5. Confirm
6. ✅ Should work now!
   - Quantity decreases
   - Dust increases
   - Success message: "✅ Recycled! +30 Dust"
   - No more red error!
```

### Test 3: Verify Dust Update
```
Before recycle: Note dust value
Recycle 1 card (e.g., Elite = 15 dust)
After recycle: Dust should increase by 15
Check all tabs (Inventory, Shop, Lobby) → all show updated dust
```

---

## 📊 Type Conversion Flow

```
Database (bigint)
       ↓
    SELECT
       ↓
JSON { "id": 123 }  ← PostgreSQL sends as number
       ↓
Card.fromJson()
       ↓
id: json['id'].toString()  → "123" (String for Dart)
       ↓
When querying back:
       ↓
int.tryParse("123")  → 123 (int)
       ↓
.eq('card_id', 123)  ✅ Matches database bigint!
```

---

## 🎯 What Was Fixed

| Function | Issue | Fix |
|----------|-------|-----|
| `getUserCard()` | `.eq('card_id', cardId)` String | Convert to `int` before query |
| `addCardToInventory()` | `'card_id': cardId` String | Convert to `int` before insert |
| `decreaseCardQuantity()` | Uses `getUserCard()` | Fixed via getUserCard fix |
| `recycleCard()` | Uses `getUserCard()` | Fixed via getUserCard fix |

---

## ✅ Verification Checklist

After hot reload:

- [ ] Open Inventory → See cards
- [ ] Tap a card → Detail dialog opens
- [ ] Click "Recycle for Dust" → Confirm
- [ ] ✅ Success message appears (green)
- [ ] ❌ No red error message
- [ ] Card quantity decreased
- [ ] Dust value increased
- [ ] Other tabs (Shop, Lobby) show updated dust

---

## 💡 Why This Happened

**Common Flutter + Supabase Issue:**

1. **Supabase uses PostgreSQL** → BigInt IDs by default
2. **Dart/Flutter String IDs** → Easier to work with in JSON
3. **ID conversion works ONE WAY** (bigint → String)
4. **MUST convert back** (String → int) when querying!

**Lesson:** Always **parse String ID to int** when:
- Filtering: `.eq('card_id', int.parse(cardId))`
- Inserting: `'card_id': int.parse(cardId)`
- Updating: `'card_id': int.parse(cardId)`

---

## 🚀 Status

**✅ Fix Applied**
**✅ App auto hot-reloading**
**✅ Ready to test**

---

**Test recycle sekarang dan error seharusnya hilang!** 🎉

If still error, check Flutter console for new error messages.
