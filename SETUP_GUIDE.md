# 🎯 SETUP GUIDE - Animyst Gacha Game

Panduan lengkap untuk setup aplikasi Animyst Gacha Game dengan Flutter dan Supabase.

---

## 📋 Prerequisites

Pastikan Anda sudah install:
- ✅ Flutter SDK (versi 3.0 atau lebih baru)
- ✅ Dart SDK
- ✅ Android Studio / VS Code
- ✅ Akun Supabase (gratis di [supabase.com](https://supabase.com))

---

## 🚀 Langkah-langkah Setup

### 1. Setup Supabase Project

#### A. Buat Project Baru
1. Login ke [supabase.com](https://supabase.com)
2. Klik "New Project"
3. Isi nama project: `animyst-gacha`
4. Pilih region terdekat (Southeast Asia)
5. Buat password database yang kuat
6. Tunggu project selesai dibuat (~2 menit)

#### B. Copy Credentials
1. Buka project dashboard
2. Klik icon Settings (⚙️) di sidebar
3. Pilih "API"
4. Copy:
   - **Project URL** (contoh: `https://xxxxx.supabase.co`)
   - **anon/public key** (key yang panjang)

#### C. Setup Database
1. Buka SQL Editor di dashboard Supabase
2. Buka file `supabase_setup.sql` di project ini
3. Copy seluruh isi file
4. Paste ke SQL Editor
5. Klik "Run" atau tekan Ctrl+Enter
6. Tunggu hingga query selesai (✅ Success)

Jika berhasil, Anda akan punya:
- ✅ 3 Tables: `profiles`, `cards`, `user_cards`
- ✅ Row Level Security (RLS) enabled
- ✅ Policies untuk security
- ✅ Triggers untuk auto-create profile
- ✅ Functions untuk update timestamps

---

### 2. Setup Flutter Project

#### A. Install Dependencies
```bash
cd d:\animyst
flutter pub get
```

#### B. Konfigurasi Supabase
1. Buka file `lib/main.dart`
2. Cari baris:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL_HERE',
  anonKey: 'YOUR_SUPABASE_ANON_KEY_HERE',
);
```
3. Ganti dengan credentials Anda:
```dart
await Supabase.initialize(
  url: 'https://xxxxx.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);
```

**OPSIONAL:** Update juga di `lib/core/constants/app_constants.dart`

---

### 3. Insert Sample Data (Opsional)

Untuk testing, Anda bisa insert sample cards:

```sql
-- Jalankan di SQL Editor Supabase
INSERT INTO cards (name, image_url, rarity, recycle_dust_value) VALUES
  ('Common Sword', 'https://via.placeholder.com/300/808080/FFFFFF/?text=Common+Sword', 'normal', 5),
  ('Steel Shield', 'https://via.placeholder.com/300/808080/FFFFFF/?text=Steel+Shield', 'normal', 5),
  ('Magic Bow', 'https://via.placeholder.com/300/4169E1/FFFFFF/?text=Magic+Bow', 'elite', 15),
  ('Fire Staff', 'https://via.placeholder.com/300/4169E1/FFFFFF/?text=Fire+Staff', 'elite', 15),
  ('Dragon Blade', 'https://via.placeholder.com/300/9370DB/FFFFFF/?text=Dragon+Blade', 'rare', 30),
  ('Phoenix Staff', 'https://via.placeholder.com/300/9370DB/FFFFFF/?text=Phoenix+Staff', 'rare', 30),
  ('Legendary Armor', 'https://via.placeholder.com/300/FFD700/000000/?text=Legendary+Armor', 'superRare', 60),
  ('Mystic Crown', 'https://via.placeholder.com/300/FFD700/000000/?text=Mystic+Crown', 'superRare', 60),
  ('Godly Sword', 'https://via.placeholder.com/300/FF1493/FFFFFF/?text=Godly+Sword', 'ultraRare', 150),
  ('Divine Shield', 'https://via.placeholder.com/300/FF1493/FFFFFF/?text=Divine+Shield', 'ultraRare', 150);
```

---

### 4. Run Aplikasi

```bash
# Check devices
flutter devices

# Run di emulator/device
flutter run

# Atau dengan hot reload
flutter run -d chrome  # Untuk web
flutter run -d windows # Untuk Windows desktop
```

---

## 📁 Struktur Project

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart      # Constants untuk app & game config
│   ├── enums/
│   │   ├── rarity.dart             # Enum untuk rarity
│   │   └── enums.dart              # Barrel export
│   ├── models/
│   │   ├── profile.dart            # Model profil user
│   │   ├── card.dart               # Model kartu
│   │   ├── user_card.dart          # Model inventory
│   │   └── models.dart             # Barrel export
│   └── services/
│       ├── profile_service.dart    # Service untuk profil
│       ├── card_service.dart       # Service untuk kartu
│       ├── inventory_service.dart  # Service untuk inventory
│       ├── gacha_service.dart      # Service untuk gacha logic
│       └── services.dart           # Barrel export
├── features/
│   ├── auth/                       # Feature autentikasi
│   ├── gacha/                      # Feature gacha
│   ├── shop/                       # Feature shop
│   └── inventory/                  # Feature inventory
└── main.dart                       # Entry point
```

---

## 🎮 Fitur yang Sudah Dibuat

### ✅ Backend Setup
- [x] Supabase configuration
- [x] Database schema dengan RLS
- [x] Auto-create profile trigger
- [x] Policies untuk security

### ✅ Data Models
- [x] Profile model (gems, dust, pity_counter)
- [x] Card model (dengan rarity enum)
- [x] UserCard model (inventory)

### ✅ Services
- [x] ProfileService - CRUD profil user
- [x] CardService - Query kartu
- [x] InventoryService - Manage inventory
- [x] GachaService - Mekanisme pull dengan pity system

### ✅ Game Mechanics (Configured)
- [x] Single Pull (100 gems)
- [x] Ten Pull (900 gems, 10% discount)
- [x] Pity System (guaranteed Ultra Rare at 90 pulls)
- [x] Probability rates untuk setiap rarity
- [x] Recycle system (kartu → dust)

---

## ⏭️ Next Steps - Yang Perlu Dibangun

### 1. Authentication UI
- [ ] Login screen
- [ ] Register screen
- [ ] Forgot password
- [ ] Auto-create profile after register

### 2. Gacha UI
- [ ] Gacha animation screen
- [ ] Single pull button
- [ ] Ten pull button
- [ ] Result display dengan animation
- [ ] Pity counter indicator

### 3. Inventory UI
- [ ] Grid view untuk kartu
- [ ] Filter by rarity
- [ ] Card detail modal
- [ ] Recycle button & confirmation

### 4. Shop UI
- [ ] Gem packages
- [ ] Purchase flow
- [ ] (Opsional) In-app purchase integration

### 5. Profile UI
- [ ] User stats
- [ ] Gems & dust display
- [ ] Edit profile
- [ ] Logout

---

## 🧪 Testing

### Test Database Connection
```dart
// Add this to main.dart untuk test connection
Future<void> testConnection() async {
  try {
    final response = await supabase.from('cards').select().limit(1);
    print('✅ Connection successful: ${response.length} cards');
  } catch (e) {
    print('❌ Connection failed: $e');
  }
}
```

### Test Gacha Service
```dart
// Test gacha pull
final gachaService = GachaService();
final result = await gachaService.performSinglePull('user-id-here');
if (result != null) {
  print('Got card: ${result.card.name} (${result.card.rarity.displayName})');
}
```

---

## 🎨 UI Design Recommendations

### Color Scheme berdasarkan Rarity
- **Normal**: Gray (#808080)
- **Elite**: Blue (#4169E1)
- **Rare**: Purple (#9370DB)
- **Super Rare**: Gold (#FFD700)
- **Ultra Rare**: Pink/Magenta (#FF1493)

### Animations
- Pull animation (spinning, glowing)
- Card reveal animation (flip, fade in)
- Particle effects untuk rare cards
- Confetti untuk Ultra Rare

---

## 📚 Resources

- [Supabase Docs](https://supabase.com/docs)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Flutter Animation Guide](https://docs.flutter.dev/development/ui/animations)

---

## ❓ Troubleshooting

### Problem: "Invalid API key"
**Solution:** 
- Pastikan anon key sudah benar
- Jangan gunakan service_role key di client
- Check apakah ada typo

### Problem: "Row Level Security policy violation"
**Solution:**
- Pastikan RLS policies sudah dibuat
- Check apakah user sudah authenticated
- Review policies di Supabase dashboard

### Problem: "No cards returned"
**Solution:**
- Insert sample data dulu
- Check query dengan SQL Editor
- Pastikan RLS policy untuk cards allow public read

---

## 🎯 Game Balance

Current drop rates:
- Normal: 50%
- Elite: 30%
- Rare: 15%
- Super Rare: 4%
- Ultra Rare: 1%

Anda bisa adjust rates di `app_constants.dart`:
```dart
static const double normalRate = 50.0;
static const double eliteRate = 30.0;
// ... dst
```

---

## 📞 Support

Jika ada masalah atau pertanyaan, silakan:
1. Check troubleshooting section di atas
2. Review Supabase dashboard logs
3. Check Flutter console untuk error messages

---

**Selamat coding! 🚀**
