# 🔧 TROUBLESHOOTING - Import Path Fix

## ❌ Error yang Terjadi

```
lib/features/auth/screens/login_page.dart:3:8: Error: Error when reading
'lib/features/core/providers/auth_provider.dart': The system cannot find the path
```

## ✅ Solusi

**Problem:** Import path salah karena struktur folder:
```
lib/
├── core/                    ← auth_provider ada di sini
│   └── providers/
│       └── auth_provider.dart
└── features/
    └── auth/
        └── screens/
            └── login_page.dart  ← File yang import
```

**Path yang SALAH:**
```dart
import '../../core/providers/auth_provider.dart';
// Ini akan mencari: lib/features/core/providers/ ❌
```

**Path yang BENAR:**
```dart
import '../../../core/providers/auth_provider.dart';
// Naik 3 level: screens → auth → features → lib
// Kemudian turun ke: core/providers/ ✅
```

## 📝 Cara Hitung Relative Import

Dari `lib/features/auth/screens/login_page.dart` → `lib/core/providers/auth_provider.dart`

```
login_page.dart location: lib/features/auth/screens/
├── ../ → lib/features/auth/
├── ../ → lib/features/
├── ../ → lib/
└── core/providers/auth_provider.dart
   
Total: ../../../core/providers/auth_provider.dart
```

## 🛠️ Fix yang Dilakukan

File: `lib/features/auth/screens/login_page.dart`

```diff
- import '../../core/providers/auth_provider.dart';
+ import '../../../core/providers/auth_provider.dart';
```

## ✅ Hasil

Aplikasi berhasil running! 🎉

```bash
flutter run -d chrome
# ✅ Success!
```

## 💡 Tips untuk Avoid Import Errors

### 1. Use Absolute Imports (Recommended)
```dart
// Instead of relative:
import '../../../core/providers/auth_provider.dart';

// Use package import:
import 'package:animyst/core/providers/auth_provider.dart';
```

### 2. Barrel Exports
Create `lib/core/core.dart`:
```dart
export 'providers/auth_provider.dart';
export 'models/models.dart';
export 'services/services.dart';
```

Then import:
```dart
import 'package:animyst/core/core.dart';
```

## 🎯 Quick Commands

### If error persists:
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run
flutter run -d chrome
```

---

**✅ Fixed! Aplikasi sekarang running dengan baik!**
