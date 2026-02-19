# Animyst - Gacha Game dengan Supabase

Game Gacha sederhana yang dibangun dengan Flutter dan Supabase.

## 📁 Struktur Folder

```
lib/
├── core/
│   ├── enums/
│   │   ├── rarity.dart          # Enum untuk tingkat kelangkaan kartu
│   │   └── enums.dart           # Barrel export file
│   └── models/
│       ├── profile.dart         # Model untuk profil user
│       ├── card.dart            # Model untuk kartu gacha
│       ├── user_card.dart       # Model untuk inventory user
│       └── models.dart          # Barrel export file
├── features/
│   ├── auth/                    # Fitur autentikasi
│   ├── gacha/                   # Fitur mekanisme gacha
│   ├── shop/                    # Fitur toko in-app
│   └── inventory/               # Fitur manajemen inventory
└── main.dart                    # Entry point aplikasi
```

## 🗄️ Database Schema (Supabase)

### Table: `profiles`
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  username TEXT NOT NULL,
  gems INTEGER DEFAULT 0,
  dust INTEGER DEFAULT 0,
  pity_counter INTEGER DEFAULT 0,
  last_login TIMESTAMP WITH TIME ZONE
);
```

### Table: `cards`
```sql
CREATE TABLE cards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  image_url TEXT NOT NULL,
  rarity TEXT NOT NULL,
  recycle_dust_value INTEGER DEFAULT 0
);
```

### Table: `user_cards`
```sql
CREATE TABLE user_cards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  card_id UUID REFERENCES cards(id) ON DELETE CASCADE,
  quantity INTEGER DEFAULT 1
);
```

## 🎯 Rarity Levels

- **Normal** - Kartu biasa
- **Elite** - Kartu elite
- **Rare** - Kartu langka
- **Super Rare** - Kartu super langka
- **Ultra Rare** - Kartu paling langka

## 🚀 Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Konfigurasi Supabase

Buka `lib/main.dart` dan ganti placeholder dengan kredensial Supabase Anda:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL_HERE',        // Ganti dengan URL Supabase
  anonKey: 'YOUR_SUPABASE_ANON_KEY_HERE', // Ganti dengan Anon Key
);
```

### 3. Jalankan Aplikasi
```bash
flutter run
```

## 📦 Data Models

### Profile Model
```dart
Profile profile = Profile(
  id: 'user-uuid',
  username: 'player123',
  gems: 1000,
  dust: 500,
  pityCounter: 5,
  lastLogin: DateTime.now(),
);
```

### Card Model
```dart
Card card = Card(
  id: 'card-uuid',
  name: 'Dragon Knight',
  imageUrl: 'https://...',
  rarity: Rarity.ultraRare,
  recycleDustValue: 100,
);
```

### UserCard Model
```dart
UserCard userCard = UserCard(
  id: 'usercard-uuid',
  userId: 'user-uuid',
  cardId: 'card-uuid',
  quantity: 3,
);
```

## 🔧 Fitur yang Akan Diimplementasi

- [ ] Sistem autentikasi
- [ ] Mekanisme gacha (pull)
- [ ] Sistem pity counter
- [ ] Inventory management
- [ ] Shop untuk beli gems
- [ ] Recycle kartu menjadi dust
- [ ] Daily login rewards

## 📝 To-Do

1. ✅ Setup `supabase_flutter`
2. ✅ Buat struktur folder
3. ✅ Buat data models
4. ⏳ Implementasi autentikasi
5. ⏳ Buat UI gacha
6. ⏳ Implementasi mekanisme pull
7. ⏳ Buat sistem inventory
8. ⏳ Buat shop

## 🛠️ Dependencies

- `flutter` - Framework UI
- `supabase_flutter: ^2.5.0` - Backend integration dengan Supabase

## 📄 License

MIT License
