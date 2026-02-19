# 🔍 DEBUGGING GUIDE - Recycle Still Failing

## 📋 Checklist untuk Debug

Saya sudah menambahkan **detailed logging** ke kode. Sekarang ikuti langkah berikut:

---

## ✅ **Step 1: Restart Flutter App**

Karena kode sudah diupdate dengan logging, restart app:

```bash
cd d:\animyst
flutter run -d chrome
```

---

## ✅ **Step 2: Buka Browser Console** (PENTING!)

Setelah app running:

1. **Buka Chrome DevTools:**
   - Tekan `F12` di browser
   - Atau klik kanan → "Inspect"

2. **Pilih tab "Console"**

3. **Clear console** (icon 🚫 atau Ctrl+L)

4. **Sekarang test recycle:**
   - Buka Inventory
   - Tap card "Rubah Merah"
   - Click "Recycle for Dust"
   - Confirm

5. **Lihat console output!** Akan ada log seperti:
   ```
   🔍 getUserCard - userId: xxx, cardId: yyy
   ✅ Parsed cardId to int: 123
   📦 Query response: {...}
   ✅ UserCard found: id=abc, quantity=1
   🔽 decreaseCardQuantity - ...
   📊 Current quantity: 1, New quantity: 0
   🗑️ Deleting user_card with id: abc
   ✅ Deleted successfully
   ```

   **ATAU jika error:**
   ```
   ❌ Error: ...
   Stack trace: ...
   ```

6. **Screenshot SEMUA console output** dan kirim ke saya!

---

## ✅ **Step 3: Check Database Structure di Supabase**

1. **Buka Supabase Dashboard:**
   - https://app.supabase.com
   - Pilih project Anda

2. **Ke Table Editor:**
   - Sidebar kiri → **Table Editor**
   - Pilih table **`user_cards`**

3. **Screenshot struktur table:**
   - Click icon ⚙️ (Settings) di pojok kanan atas table
   - Pilih "Edit table"
   - Screenshot semua kolom dan tipe datanya

4. **Check RLS (Row Level Security):**
   - Di table editor, lihat ikon 🔒 RLS status
   - **IMPORTANT:** RLS policies mungkin memblok DELETE/UPDATE!

---

## ✅ **Step 4: Run SQL Query untuk Test**

Di **Supabase SQL Editor**, jalankan:

### Query 1: Check struktur user_cards
```sql
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns
WHERE table_name = 'user_cards'
ORDER BY ordinal_position;
```

### Query 2: Check data user_cards untuk user Anda
```sql
-- Ganti dengan user_id Anda
SELECT 
  uc.*,
  c.name as card_name,
  c.rarity
FROM user_cards uc
JOIN cards c ON c.id = uc.card_id
WHERE uc.user_id = 'YOUR-USER-ID-HERE';
```

**Cara dapat user_id:**
```sql
SELECT id, email FROM auth.users;
```

### Query 3: Check RLS Policies
```sql
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'user_cards';
```

**Screenshot hasil ketiga query!**

---

## ✅ **Step 5: Manual Test DELETE** (Important!)

Untuk test apakah DELETE berfungsi di database:

```sql
-- 1. Get satu user_card ID
SELECT id, user_id, card_id, quantity 
FROM user_cards 
LIMIT 1;

-- 2. Copy ID-nya, lalu test DELETE
-- GANTI 'xxx' dengan ID yang didapat dari query atas
DELETE FROM user_cards 
WHERE id = 'xxx';

-- 3. Check apakah berhasil
SELECT COUNT(*) FROM user_cards WHERE id = 'xxx';
-- Should return 0 if deleted successfully
```

**Jika DELETE ini GAGAL → masalahnya ada di RLS Policy!**

---

## 🔒 **Step 6: Fix RLS Policy (Jika Perlu)**

Jika DELETE manual gagal, kemungkinan RLS memblok. Run SQL ini:

```sql
-- 1. Drop existing policies (if any)
DROP POLICY IF EXISTS "Users can delete own cards" ON user_cards;
DROP POLICY IF EXISTS "Users can update own cards" ON user_cards;

-- 2. Create new policies
CREATE POLICY "Users can delete own cards"
  ON user_cards
  FOR DELETE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own cards"
  ON user_cards
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 3. Ensure RLS is enabled
ALTER TABLE user_cards ENABLE ROW LEVEL SECURITY;
```

---

## 📊 **Kemungkinan Masalah & Solusi**

### Problem 1: getUserCard returns null
**Console log:**
```
⚠️ No user_card found for user xxx and card yyy
```

**Penyebab:**
- Card ID tidak cocok
- User tidak punya card tersebut
- Type mismatch masih ada

**Solusi:**
- Check query manual di Supabase
- Print card_id dari inventory page

---

### Problem 2: RLS Policy Blocks DELETE
**Console log:**
```
❌ Error decreasing card quantity: ...permission denied...
```

**Penyebab:**
- RLS policy tidak allow DELETE untuk user

**Solusi:**
- Run Step 6 di atas untuk fix RLS

---

### Problem 3: Column Type Mismatch
**Console log:**
```
❌ Error: column "card_id" is of type bigint but expression is of type text
```

**Penyebab:**
- int.tryParse gagal atau tidak jalan

**Solusi:**
- Check console log, pastikan ada: "✅ Parsed cardId to int: 123"

---

## 🎯 **Yang Saya Butuhkan dari Anda:**

Untuk fix masalah ini, tolong kirim:

1. ✅ **Screenshot Browser Console** (F12 → Console tab) setelah test recycle
2. ✅ **Screenshot hasil SQL Query** (3 queries di Step 4)
3. ✅ **Screenshot Table Structure** user_cards di Supabase
4. ✅ **Hasil Manual DELETE Test** (Step 5)

Dengan informasi ini, saya bisa langsung kasih solusi yang exact! 🎯

---

## 🚀 **Quick Start:**

```bash
# 1. Restart app dengan logging baru
flutter run -d chrome

# 2. F12 di browser → Console tab

# 3. Test recycle → Screenshot console

# 4. Run SQL queries di Supabase → Screenshot

# 5. Kirim semua screenshot ke saya!
```

---

**Saya tunggu screenshot-nya ya! Dengan log yang lengkap, saya pasti bisa fix masalah ini! 💪**
