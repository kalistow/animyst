# 🏠 LOBBY & EKONOMI SYSTEM - Implementation Guide

## ✅ Yang Sudah Diimplementasi - Tahap 3

### 1. LobbyPage dengan BottomNavigation ✅

**File:** `lib/features/home/screens/lobby_page.dart`

**Features:**
- ✅ Welcome message dengan username
- ✅ Card saldo menampilkan:
  - 💎 Gems (dari provider)
  - ✨ Dust (dari provider)
  - 🎁 Free Dust (daily reset)
- ✅ Stats card dengan Pity Counter & Last Login
- ✅ Quick Actions buttons (Gacha, Refresh)
- ✅ BottomNavigationBar dengan 3 tabs:
  - Home (Lobby)
  - Shop
  - Inventory
- ✅ Logout button di AppBar

---

### 2. LoginPage - Auto Navigate ke Lobby ✅

**File:** `lib/features/auth/screens/login_page.dart`

**Changes:**
- ✅ Setelah login berhasil → **Navigator.pushReplacement** ke LobbyPage
- ✅ Debug info section dihapus (tidak perlu lagi)
- ✅ Daily reset notification tetap muncul sebelum navigate

**Flow:**
```
Login berhasil
   ↓
Daily reset check & notification
   ↓
Navigate to LobbyPage (replace route)
   ↓
User masuk lobby dengan saldo terupdate
```

---

### 3. ShopPage dengan Exchange System ✅

**File:** `lib/features/shop/screens/shop_page.dart`

**Features:**

#### A. Saldo Display
- ✅ Menampilkan Gems & Dust current user
- ✅ Real-time dari provider

#### B. Exchange Feature
- ✅ Kurs: **250 Dust = 100 Gems**
- ✅ Visual display exchange rate dengan icons
- ✅ Validasi saldo Dust sebelum exchange
- ✅ Update ke Supabase (gems & dust)
- ✅ Auto-refresh profile setelah exchange
- ✅ Success/Error notifications

**Logic Exchange:**
```dart
if (dust >= 250) {
  newDust = currentDust - 250;
  newGems = currentGems + 100;
  
  // Update to Supabase
  await updateDust(newDust);
  await updateGems(newGems);
  
  // Refresh profile
  await refreshProfile();
  
  // Show success
  ✅ "Exchange berhasil! -250 Dust, +100 Gems"
} else {
  ❌ "Dust tidak cukup!"
}
```

#### C. Top Up Feature (Testing)
- ✅ Tombol "Top Up 1000 Gems"
- ✅ Menambah 1000 gems ke saldo
- ✅ Update ke Supabase
- ✅ Auto-refresh profile

**Logic Top Up:**
```dart
newGems = currentGems + 1000;
await updateGems(newGems);
await refreshProfile();
✅ "Top Up berhasil! +1000 Gems"
```

#### D. Info Card
- ✅ Menjelaskan cara kerja exchange
- ✅ Tips untuk user

---

### 4. InventoryPage ✅

**File:** `lib/features/inventory/screens/inventory_page.dart`

**Status:** Placeholder - Coming Soon
- ✅ UI placeholder dengan "Coming Soon" message
- ✅ Link ke gacha (untuk future implementation)

---

## 🎯 User Flow Lengkap

### Flow 1: Login → Lobby
```
1. User di LoginPage
2. Input email & password
3. Click "Login with Email"
4. ✅ Auth berhasil
5. 🎁 Daily reset notification (jika hari baru)
6. → Navigate to LobbyPage
7. Lihat welcome message & saldo
```

### Flow 2: Exchange Dust → Gems
```
1. User di LobbyPage
2. Click tab "Shop" di bottom nav
3. Lihat saldo: Gems & Dust
4. Scroll ke section "Exchange"
5. Click "Tukar Sekarang"
6. ✅ Jika cukup dust:
   - Dust -250
   - Gems +100
   - Profile auto-refresh
   - Notification "Exchange berhasil!"
7. ❌ Jika tidak cukup:
   - Notification "Dust tidak cukup!"
```

### Flow 3: Top Up Gems (Testing)
```
1. Di ShopPage
2. Scroll ke section "Top Up"
3. Click "Top Up 1000 Gems (Test)"
4. ✅ Gems +1000
5. Profile auto-refresh
6. Notification "Top Up berhasil!"
```

---

## 📁 File Structure Update

```
lib/
├── core/
│   ├── providers/
│   │   └── auth_provider.dart         ✅ (existing)
│   └── services/
│       └── profile_service.dart       ✅ (existing - has update methods)
└── features/
    ├── auth/
    │   └── screens/
    │       ├── login_page.dart        ✅ UPDATED (navigate to Lobby)
    │       └── register_page.dart     ✅ (existing)
    ├── home/
    │   └── screens/
    │       └── lobby_page.dart        ✅ NEW (main lobby)
    ├── shop/
    │   └── screens/
    │       └── shop_page.dart         ✅ NEW (exchange & top up)
    └── inventory/
        └── screens/
            └── inventory_page.dart    ✅ NEW (placeholder)
```

---

## 🎨 UI Components

### LobbyPage Home Tab:
- 🎨 Welcome Card - glassmorphism style
- 💎 Saldo Card - displays Gems, Dust, Free Dust
- 📊 Stats Card - Pity counter, Last login
- ⚡ Quick Actions - Gacha pull, Refresh buttons
- 🚪 Logout - di AppBar

### ShopPage:
- 💰 Saldo Display - large icons, current balance
- 🔄 Exchange Section:
  - Visual rate display (250 Dust → 100 Gems)
  - Orange card with border
  - Exchange button
- 💎 Top Up Section:
  - Blue card
  - Test top up button (1000 gems)
- ℹ️ Info Card - tips & explanation

### InventoryPage:
- 📦 Placeholder UI
- "Coming Soon" message
- Link to gacha

---

## 🧪 Testing Guide

### Test Exchange Feature:

**Scenario 1: Cukup Dust**
```
1. Login
2. Top up 1000 gems (dapat di shop)
3. Gunakan gems untuk gacha
4. Recycle kartu duplikat → dapat dust
5. Pastikan dust >= 250
6. Go to Shop → Exchange
7. ✅ Should succeed
8. Check saldo: dust -250, gems +100
```

**Scenario 2: Tidak Cukup Dust**
```
1. Login dengan akun baru
2. Initial dust = 0
3. Go to Shop → Exchange
4. ❌ Error: "Dust tidak cukup!"
```

### Test Top Up:
```
1. Login
2. Note current gems (misal: 100)
3. Go to Shop
4. Click "Top Up 1000 Gems"
5. ✅ Success notification
6. Check saldo: gems = 100 + 1000 = 1100
7. Refresh page → saldo tetap (persistent)
```

### Test Navigation:
```
1. Login → Auto ke Lobby ✅
2. Click Shop tab → ShopPage ✅
3. Click Inventory tab → InventoryPage ✅
4. Click Home tab → Back to Lobby ✅
5. Logout → Back to LoginPage ✅
```

---

## 🔧 Configuration

### Exchange Rate (Customizable):
```dart
// In shop_page.dart
static const int dustPerExchange = 250;  // Change this
static const int gemsPerExchange = 100;  // Change this
```

### Top Up Amount:
```dart
// In _handleTopUp()
final newGems = profile.gems + 1000;  // Change amount here
```

---

## 📝 Code Snippets

### Get Current Profile (anywhere):
```dart
final profile = ref.watch(currentProfileProvider);

// Access values
int gems = profile?.gems ?? 0;
int dust = profile?.dust ?? 0;
int freeDust = profile?.freeDust ?? 0;
```

### Refresh Profile After Changes:
```dart
await ref.read(authProvider.notifier).refreshProfile();
```

### Navigate to Lobby:
```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const LobbyPage()),
);
```

### Update Gems Manually:
```dart
final profileService = ProfileService();
await profileService.updateGems(userId, newAmount);
```

---

## 🐛 Troubleshooting

### Problem: Exchange tidak update saldo
**Solution:**
- Check Supabase connection
- Verify ProfileService.updateGems() & updateDust() working
- Check console for errors
- Try manual refresh

### Problem: Navigation tidak jalan setelah login
**Solution:**
- Check import LobbyPage di login_page.dart
- Verify auth state listener logic
- Check console for navigation errors

### Problem: Bottom nav tidak switch tabs
**Solution:**
- Verify ShopPage & InventoryPage imported correctly
- Check _selectedIndex state updating

---

## 🎯 Next Steps

After this tahap:

1. ✅ **Lobby & Economy** - DONE
2. 🔄 **Gacha System Implementation**
   - Single pull UI
   - Ten pull UI
   - Pity system integration
   - Rarity display
3. 🔄 **Inventory System**
   - Display user cards
   - Recycle feature
   - Card details
4. 🔄 **Animations & Polish**
   - Gacha pull animation
   - Card reveal animation
   - Smooth transitions

---

## ✅ Checklist Completion

- [x] LobbyPage dengan welcome & saldo
- [x] BottomNavigationBar (Home, Shop, Inventory)
- [x] LoginPage navigate ke Lobby after login
- [x] ShopPage dengan saldo display
- [x] Exchange feature (250 Dust = 100 Gems)
- [x] Exchange validation & update to DB
- [x] Top Up 1000 Gems (testing)
- [x] InventoryPage placeholder
- [x] Logout functionality
- [x] Profile auto-refresh
- [x] Error handling & notifications

---

**🎉 Tahap 3 Complete! UI Lobby & Ekonomi System fully functional!**

Test semua fitur dan ready untuk tahap selanjutnya: Gacha Implementation! 🎰
