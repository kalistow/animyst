# 🔧 ERROR FIX - Postgrest `.in_()` Method Deprecated

## ❌ Error yang Muncul

```
lib/core/services/card_service.dart:68:12: Error: The method 'in_' isn't defined
for the class 'PostgrestFilterBuilder<List<Map<String, dynamic>>>'.
Try correcting the name to the name of an existing method, or defining a method   
named 'in_'.
          .in_('id', cardIds);
           ^^^
```

---

## 🎯 Penyebab

**Method `.in_()` sudah deprecated** di `postgrest` package version 2.6.0 yang Anda gunakan.

Di versi lama (< 2.0):
```dart
.in_('id', cardIds)  // ❌ Tidak tersedia lagi
```

Di versi baru (>= 2.0):
```dart
.filter('id', 'in', '(${cardIds.join(',')})')  // ✅ Syntax baru
```

---

## ✅ Solusi yang Diterapkan

### Before (Error):
```dart
// lib/core/services/card_service.dart line 65-68
final response = await _supabase
    .from(AppConstants.cardsTable)
    .select()
    .in_('id', cardIds);  // ❌ ERROR!
```

### After (Fixed):
```dart
// lib/core/services/card_service.dart line 65-68
final response = await _supabase
    .from(AppConstants.cardsTable)
    .select()
    .filter('id', 'in', '(${cardIds.join(',')})');  // ✅ FIXED!
```

---

## 📋 Penjelasan

### Syntax `.filter()`

```dart
.filter(column, operator, value)
```

**Parameters:**
- `column`: Nama kolom (`'id'`)
- `operator`: Operator filter (`'in'`, `'eq'`, `'gt'`, dll)
- `value`: Value yang difilter

**Untuk operator `in`:**
- Value harus dalam format: `'(value1,value2,value3)'`
- Contoh: `'(abc123,def456,ghi789)'`

**Implementation:**
```dart
// cardIds = ['abc123', 'def456', 'ghi789']
cardIds.join(',')  // → 'abc123,def456,ghi789'
'(${cardIds.join(',')})' // → '(abc123,def456,ghi789)'
```

---

## 🔄 Alternatif Syntax (Postgrest 2.6.0+)

### Option 1: `.filter()` (Yang digunakan)
```dart
.filter('id', 'in', '(${cardIds.join(',')})')
```

### Option 2: Raw query string
```dart
.or(cardIds.map((id) => "id.eq.$id").join(','))
```

### Option 3: Multiple `.eq()` with `.or()`
```dart
// Untuk kasus simple dengan sedikit IDs
.or('id.eq.${cardIds[0]},id.eq.${cardIds[1]},...')
```

**Kesimpulan:** Option 1 paling clean dan mudah dibaca.

---

## 🧪 Testing

Setelah fix, test fungsi yang menggunakan `getCardsByIds()`:

### Test Case:
```dart
final cardService = CardService();
final cardIds = ['card-1-id', 'card-2-id', 'card-3-id'];
final cards = await cardService.getCardsByIds(cardIds);

print('Found ${cards.length} cards');
// Should return 3 cards (or however many exist in DB)
```

**Expected SQL:**
```sql
SELECT * FROM cards 
WHERE id IN ('card-1-id', 'card-2-id', 'card-3-id');
```

---

## 📦 Version Info

**Package:** `postgrest`  
**Your Version:** 2.6.0 (via supabase_flutter dependency)

**Breaking Changes:**
- Version 1.x → 2.0: `.in_()` removed
- New syntax: `.filter()` for all operators

**Check your version:**
```bash
flutter pub deps | grep postgrest
```

Output:
```
postgrest 2.6.0
```

---

## 🐛 Troubleshooting

### Error persists after fix?
```bash
flutter clean
flutter pub get
flutter run
```

### Different postgrest version?
Check documentation:
- v2.x+: Use `.filter()`
- v1.x: Use `.in_()` (deprecated)

**Docs:** https://pub.dev/packages/postgrest

---

## 📝 Other Breaking Changes to Watch

If you upgrade supabase_flutter, these might also break:

### 1. `.eq()` still works ✅
```dart
.eq('column', 'value')  // Still supported
```

### 2. `.neq()` → `.filter()`
```dart
// Old
.neq('status', 'deleted')

// New
.filter('status', 'neq', 'deleted')
```

### 3. `.gt()`, `.lt()` → `.filter()`
```dart
// Old
.gt('score', 100)

// New  
.filter('score', 'gt', '100')
```

### 4. `.contains()` → `.filter()`
```dart
// Old
.contains('tags', ['tag1', 'tag2'])

// New
.filter('tags', 'cs', '{tag1,tag2}')
```

---

## ✅ Fixed Files

```
✅ lib/core/services/card_service.dart (line 68)
   - Changed: .in_('id', cardIds)
   - To: .filter('id', 'in', '(${cardIds.join(',')})')
```

---

## 🚀 App Status

After fix:
- ✅ Compile successful
- ✅ No more errors
- ✅ Ready to run

Run command:
```bash
flutter run -d chrome
```

---

**🎉 ERROR FIXED!** 

App sekarang bisa compile dan run tanpa masalah! ✨
