# 🔧 FIX: "Failed to perform ten pull" Error

## ❌ Error yang Muncul
```
Error: Exception: Failed to perform ten pull
```

**Screenshot:** Error muncul saat click "10x Pull" atau "1x Pull" di GachaPage.

---

## 🎯 Penyebab Utama

**Database `cards` table masih KOSONG!**

Gacha system tidak bisa pull karena tidak ada kartu untuk diambil dari database.

---

## ✅ Solusi Cepat

### Step 1: Check Database Cards

Buka **Supabase SQL Editor** dan jalankan:

```sql
SELECT rarity, COUNT(*) as jumlah
FROM cards
GROUP BY rarity;
```

**Jika hasilnya kosong (0 rows)**, lanjut ke Step 2.

---

### Step 2: Populate Database dengan 55 Cards

Copy-paste SQL berikut ke **Supabase SQL Editor**:

```sql
-- INSERT 5 Ultra Rare cards
INSERT INTO cards (id, name, rarity, image_url, recycle_dust_value) VALUES
  ('ur-dragon', 'Legendary Dragon', 'Ultra Rare', 'dragon.png', 150),
  ('ur-phoenix', 'Phoenix Rising', 'Ultra Rare', 'phoenix.png', 150),
  ('ur-unicorn', 'Mystic Unicorn', 'Ultra Rare', 'unicorn.png', 150),
  ('ur-griffin', 'Ancient Griffin', 'Ultra Rare', 'griffin.png', 150),
  ('ur-kraken', 'Deep Sea Kraken', 'Ultra Rare', 'kraken.png', 150);

-- INSERT 5 Super Rare cards
INSERT INTO cards (id, name, rarity, image_url, recycle_dust_value) VALUES
  ('sr-lion', 'Golden Lion', 'Super Rare', 'lion.png', 60),
  ('sr-tiger', 'Royal Tiger', 'Super Rare', 'tiger.png', 60),
  ('sr-eagle', 'Sky Eagle', 'Super Rare', 'eagle.png', 60),
  ('sr-wolf', 'Alpha Wolf', 'Super Rare', 'wolf.png', 60),
  ('sr-bear', 'Night Bear', 'Super Rare', 'bear.png', 60);

-- INSERT 10 Rare cards
INSERT INTO cards (id, name, rarity, image_url, recycle_dust_value) VALUES
  ('r-hawk', 'Swift Hawk', 'Rare', 'hawk.png', 30),
  ('r-fox', 'Cunning Fox', 'Rare', 'fox.png', 30),
  ('r-deer', 'Noble Deer', 'Rare', 'deer.png', 30),
  ('r-panther', 'Shadow Panther', 'Rare', 'panther.png', 30),
  ('r-cobra', 'Venom Cobra', 'Rare', 'cobra.png', 30),
  ('r-falcon', 'Wind Falcon', 'Rare', 'falcon.png', 30),
  ('r-leopard', 'Spotted Leopard', 'Rare', 'leopard.png', 30),
  ('r-cheetah', 'Speed Cheetah', 'Rare', 'cheetah.png', 30),
  ('r-jaguar', 'Forest Jaguar', 'Rare', 'jaguar.png', 30),
  ('r-lynx', 'Wild Lynx', 'Rare', 'lynx.png', 30);

-- INSERT 15 Elite cards
INSERT INTO cards (id, name, rarity, image_url, recycle_dust_value) VALUES
  ('e-rabbit', 'Swift Rabbit', 'Elite', 'rabbit.png', 15),
  ('e-squirrel', 'Tree Squirrel', 'Elite', 'squirrel.png', 15),
  ('e-raccoon', 'Clever Raccoon', 'Elite', 'raccoon.png', 15),
  ('e-badger', 'Brave Badger', 'Elite', 'badger.png', 15),
  ('e-otter', 'River Otter', 'Elite', 'otter.png', 15),
  ('e-beaver', 'Builder Beaver', 'Elite', 'beaver.png', 15),
  ('e-mole', 'Digging Mole', 'Elite', 'mole.png', 15),
  ('e-hedgehog', 'Spiky Hedgehog', 'Elite', 'hedgehog.png', 15),
  ('e-skunk', 'Stinky Skunk', 'Elite', 'skunk.png', 15),
  ('e-weasel', 'Sneaky Weasel', 'Elite', 'weasel.png', 15),
  ('e-ferret', 'Playful Ferret', 'Elite', 'ferret.png', 15),
  ('e-chipmunk', 'Cute Chipmunk', 'Elite', 'chipmunk.png', 15),
  ('e-porcupine', 'Spiny Porcupine', 'Elite', 'porcupine.png', 15),
  ('e-opossum', 'Night Opossum', 'Elite', 'opossum.png', 15),
  ('e-meerkat', 'Alert Meerkat', 'Elite', 'meerkat.png', 15);

-- INSERT 20 Normal cards
INSERT INTO cards (id, name, rarity, image_url, recycle_dust_value) VALUES
  ('n-mouse', 'Field Mouse', 'Normal', 'mouse.png', 5),
  ('n-rat', 'City Rat', 'Normal', 'rat.png', 5),
  ('n-hamster', 'Cute Hamster', 'Normal', 'hamster.png', 5),
  ('n-gerbil', 'Desert Gerbil', 'Normal', 'gerbil.png', 5),
  ('n-guinea', 'Guinea Pig', 'Normal', 'guinea.png', 5),
  ('n-bat', 'Night Bat', 'Normal', 'bat.png', 5),
  ('n-shrew', 'Tiny Shrew', 'Normal', 'shrew.png', 5),
  ('n-vole', 'Meadow Vole', 'Normal', 'vole.png', 5),
  ('n-lemming', 'Arctic Lemming', 'Normal', 'lemming.png', 5),
  ('n-dormouse', 'Sleepy Dormouse', 'Normal', 'dormouse.png', 5),
  ('n-pigeon', 'City Pigeon', 'Normal', 'pigeon.png', 5),
  ('n-sparrow', 'Common Sparrow', 'Normal', 'sparrow.png', 5),
  ('n-crow', 'Black Crow', 'Normal', 'crow.png', 5),
  ('n-raven', 'Dark Raven', 'Normal', 'raven.png', 5),
  ('n-magpie', 'Shiny Magpie', 'Normal', 'magpie.png', 5),
  ('n-jay', 'Blue Jay', 'Normal', 'jay.png', 5),
  ('n-robin', 'Red Robin', 'Normal', 'robin.png', 5),
  ('n-finch', 'Yellow Finch', 'Normal', 'finch.png', 5),
  ('n-canary', 'Singing Canary', 'Normal', 'canary.png', 5),
  ('n-budgie', 'Green Budgie', 'Normal', 'budgie.png', 5);
```

**Klik "Run"** atau **Ctrl+Enter**.

---

### Step 3: Verify Data

```sql
SELECT rarity, COUNT(*) as total
FROM cards
GROUP BY rarity
ORDER BY 
  CASE rarity
    WHEN 'Ultra Rare' THEN 1
    WHEN 'Super Rare' THEN 2
    WHEN 'Rare' THEN 3
    WHEN 'Elite' THEN 4
    WHEN 'Normal' THEN 5
  END;
```

**Expected Result:**
```
Ultra Rare:  5 cards
Super Rare:  5 cards
Rare:       10 cards
Elite:      15 cards
Normal:     20 cards
-------------------
TOTAL:      55 cards ✅
```

---

### Step 4: Test Gacha Again

1. Refresh app (hot reload: press `r` in terminal)
2. Go to Gacha page
3. Click "1x Pull" atau "10x Pull"
4. ✅ Should work now!

---

## 📊 Cards Distribution

Setelah insert 55 cards:

| Rarity | Count | Rate | Dust Value |
|--------|-------|------|------------|
| Ultra Rare | 5 | 0.5% | 150 |
| Super Rare | 5 | 4.5% | 60 |
| Rare | 10 | 15% | 30 |
| Elite | 15 | 30% | 15 |
| Normal | 20 | 50% | 5 |

**Balanced untuk testing:**
- Cukup UR untuk complete collection (5 UR needed)
- Variety untuk test duplicates
- Different recycle values

---

## 🐛 Troubleshooting

### Problem: "duplicate key value violates unique constraint"

**Cause:** Cards sudah diinsert sebelumnya.

**Solution:** Delete dulu, lalu insert ulang:
```sql
DELETE FROM cards;
-- Then run INSERT statements again
```

### Problem: Still getting error after insert

**Check:**
1. Verify cards exist: `SELECT COUNT(*) FROM cards;`
2. Check console log untuk error spesifik
3. Restart Flutter app completely:
   ```bash
   # Stop app (Ctrl+C or 'q')
   flutter clean
   flutter run -d chrome
   ```

### Problem: "No cards available for this rarity"

**Cause:** Specific rarity kosong.

**Check:**
```sql
SELECT rarity, COUNT(*) FROM cards GROUP BY rarity;
```

Make sure SEMUA rarity ada cards (minimal 1).

---

## 🎯 Quick Commands

**Copy file SQL yang sudah dibuat:**
```
d:\animyst\fix_empty_cards_database.sql
```

**Atau langsung di Supabase:**
1. Login ke https://app.supabase.com
2. Select project
3.  SQL Editor (left sidebar)
4. "+ New query"
5. Paste INSERT statements
6. Run (Ctrl+Enter)

---

## ✅ After Fix

**What will work:**
- ✅ 1x Pull (100 gems)
- ✅ 10x Pull (900 gems)
- ✅ Pity system
- ✅ Rarity distribution
- ✅ Card details
- ✅ Inventory display
- ✅ Recycle system
- ✅ Collection complete (when get 5 UR)

**Test sequence:**
1. Top up gems di Shop (1000 gems button)
2. Go to Gacha
3. Do 10x pull
4. Check hasil di result dialog
5. Check inventory untuk verify cards saved
6. Test recycle di inventory

---

**🎰 DATABASE NOW READY FOR GACHA!**

Silakan coba pull lagi setelah insert cards! ✨
