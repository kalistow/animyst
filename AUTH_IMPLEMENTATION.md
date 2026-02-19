# 🔐 AUTH & DAILY RESET - Implementation Guide

## ✅ Yang Sudah Diimplementasi

### 1. Database Schema Update
- ✅ Field `free_dust` ditambahkan ke tabel `profiles`
- ✅ Default value: 3000
- ✅ Constraint: CHECK (free_dust >= 0)

**File:** `database_updates.sql`

### 2. Profile Model Update
- ✅ `freeDust` property ditambahkan
- ✅ `fromJson()` updated untuk parse `free_dust`
- ✅ `toJson()` updated untuk save `free_dust`
- ✅ `copyWith()` support `freeDust` parameter

**File:** `lib/core/models/profile.dart`

### 3. Auth Service
Fitur lengkap untuk autentikasi:
- ✅ Login anonim (guest)
- ✅ Login dengan email & password
- ✅ Register dengan email & password & username
- ✅ Logout
- ✅ **Daily reset logic** (`checkDailyReset()`)
- ✅ Get profile with auto daily reset check

**File:** `lib/core/services/auth_service.dart`

### 4. Auth Provider (Riverpod)
State management untuk autentikasi:
- ✅ `AuthState` - tracking user, profile, loading, error
- ✅ `AuthNotifier` - mengelola auth operations
- ✅ Auto-load profile setelah login
- ✅ Auto-check daily reset setelah login
- ✅ Track jika daily reset terjadi (untuk notifikasi)

**File:** `lib/core/providers/auth_provider.dart`

### 5. Login Page
UI sederhana untuk testing:
- ✅ Email & password login
- ✅ Anonymous login (guest)
- ✅ Form validation
- ✅ Loading states
- ✅ Error handling
- ✅ Daily reset notification (SnackBar)
- ✅ Display profile info after login
- ✅ Logout button

**File:** `lib/features/auth/screens/login_page.dart`

---

## 🎯 Daily Reset Logic

### Cara Kerja:

1. **User login** (email atau anonim)
2. **AuthService.getProfileAndCheckDailyReset()** dipanggil
3. **checkDailyReset()** logic:
   ```dart
   // Get last_login dari database
   final lastLogin = profile.lastLogin;
   
   // Get tanggal hari ini
   final today = DateTime(now.year, now.month, now.day);
   
   // Bandingkan tanggal (ignore time)
   if (today != lastLoginDate) {
     // RESET! Update free_dust ke 3000
     await supabase.update({
       'free_dust': 3000,
       'last_login': DateTime.now(),
     });
   } else {
     // Same day, no reset
     // Just update last_login timestamp
   }
   ```

4. **Profile loaded** dengan value terbaru
5. Jika reset occurred, **show notification** di UI

### Testing Daily Reset:

#### Scenario 1: First Login Today
```
1. User belum login hari ini
2. Login → free_dust = 3000 ✅
3. Notification: "🎁 Daily Bonus! Free Dust reset to 3000!"
```

#### Scenario 2: Second Login Same Day
```
1. User sudah login tadi pagi (free_dust = 2500)
2. Login lagi sore hari → free_dust tetap 2500 ❌
3. No notification
```

#### Scenario 3: Next Day Login
```
1. User login kemarin (free_dust = 100)
2. Login besok → free_dust = 3000 ✅
3. Notification shown
```

---

## 🚀 Setup & Usage

### 1. Run Database Update

Jalankan di Supabase SQL Editor:
```bash
# Copy isi file database_updates.sql
# Paste & Run di SQL Editor
```

Atau manual:
```sql
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS free_dust INTEGER DEFAULT 3000 CHECK (free_dust >= 0);

UPDATE profiles SET free_dust = 3000 WHERE free_dust IS NULL;
```

### 2. Run Aplikasi

```bash
flutter run
```

### 3. Test Login

#### Anonymous Login:
1. Tap "Login Anonim (Guest)"
2. Profile auto-created
3. Check free_dust = 3000

#### Email Login:
1. Input email & password
2. Tap "Login with Email"
3. Jika hari baru → notification muncul
4. Check profile info di bawah

---

## 📝 Code Snippets

### Using Auth Provider

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animyst/core/providers/auth_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    // Check if logged in
    if (!authState.isAuthenticated) {
      return LoginPage();
    }
    
    // Show profile data
    final profile = authState.profile;
    return Text('Free Dust: ${profile?.freeDust}');
  }
}
```

### Login Actions

```dart
// Login anonim
ref.read(authProvider.notifier).signInAnonymously();

// Login email
ref.read(authProvider.notifier).signInWithEmail(
  'user@example.com',
  'password123',
);

// Register
ref.read(authProvider.notifier).signUpWithEmail(
  'new@example.com',
  'password123',
  'Username',
);

// Logout
ref.read(authProvider.notifier).signOut();
```

### Listen to Auth Changes

```dart
ref.listen<AuthState>(authProvider, (previous, next) {
  if (next.dailyResetOccurred) {
    // Show notification
    print('Daily reset! Free dust: ${next.profile?.freeDust}');
  }
  
  if (next.error != null) {
    // Show error
    print('Error: ${next.error}');
  }
});
```

### Quick Access Providers

```dart
// Get current user
final user = ref.watch(currentUserProvider);

// Get current profile
final profile = ref.watch(currentProfileProvider);

// Check if authenticated
final isAuth = ref.watch(isAuthenticatedProvider);
```

---

## 🔧 Customization

### Change Daily Reset Amount

Update di `auth_service.dart`:
```dart
await _supabase
    .from('profiles')
    .update({
      'free_dust': 5000, // Change amount here
      'last_login': now.toIso8601String(),
    })
    .eq('id', userId);
```

### Change Reset Notification

Update di `login_page.dart`:
```dart
if (next.dailyResetOccurred && next.profile != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Custom message here!'),
      backgroundColor: Colors.purple, // Custom color
    ),
  );
}
```

### Add Additional Login Methods

Tambahkan di `auth_service.dart`:
```dart
// Google Sign In
Future<User?> signInWithGoogle() async {
  // Implementation
}

// Apple Sign In
Future<User?> signInWithApple() async {
  // Implementation
}
```

---

## 🧪 Testing Checklist

- [ ] Login anonim works
- [ ] Login email works
- [ ] Register works
- [ ] Logout works
- [ ] Daily reset triggers on first login of the day
- [ ] Daily reset doesn't trigger on same day login
- [ ] Notification shows when reset occurs
- [ ] Profile data loads correctly
- [ ] free_dust value is correct after reset
- [ ] Error handling works (wrong password, etc)

---

## 🐛 Troubleshooting

### Problem: free_dust column not found
**Solution:** Run `database_updates.sql` di Supabase

### Problem: Profile not created after anonymous login
**Solution:** Check database trigger `handle_new_user()` exists

### Problem: Daily reset not working
**Solution:** 
- Check `last_login` field is updating
- Check timezone settings
- Add debug prints in `checkDailyReset()`

### Problem: Login not working
**Solution:**
- Check Supabase credentials in main.dart
- Check RLS policies allow user operations
- Check auth email settings in Supabase dashboard

---

## 🎯 Next Steps

After auth is working:
1. Create persistent login (stay logged in after app restart)
2. Add register screen
3. Add forgot password flow
4. Implement protected routes (redirect if not logged in)
5. Add profile edit functionality
6. Track daily login streaks
7. Add rewards for consecutive logins

---

**✅ Auth & Daily Reset Complete!**

Test dengan login hari ini dan besok untuk verify daily reset works! 🎉
