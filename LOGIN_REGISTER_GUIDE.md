# 🔑 LOGIN & REGISTER - Setup Guide

## 📋 Jawaban untuk Pertanyaan Anda

### 1. Di mana Email & Password?
**Sudah ada!** Di screenshot Anda sudah terlihat field Email dan Password.

### 2. Kenapa Login Anonim Tidak Bisa?
Anonymous login perlu **diaktifkan dulu di Supabase**.

### 3. Kenapa Email/Password Tidak Bisa Login?
Anda perlu **REGISTER dulu** atau punya akun existing.

---

## ✅ SOLUSI: 3 Cara Login

### CARA 1: Register Akun Baru (RECOMMENDED) ✨

1. **Di login page**, klik tombol:
   ```
   "Belum punya akun? Daftar di sini"
   ```

2. **Isi form register:**
   - Username: `TestUser`
   - Email: `test@animyst.com`
   - Password: `test123456`

3. **Klik "Register"**

4. **Kembali ke login** dan masukkan:
   - Email: `test@animyst.com`
   - Password: `test123456`

5. **Klik "Login with Email"** ✅

---

### CARA 2: Buat Test Account di Supabase

1. **Buka Supabase Dashboard:**
   ```
   https://supabase.com/dashboard
   ```

2. **Pilih project Anda**

3. **Klik Authentication** (di sidebar kiri)

4. **Klik Users**

5. **Klik "Add user"** (tombol hijau kanan atas)

6. **Isi form:**
   - Email: `test@animyst.com`
   - Password: `test123456`
   - **✅ CENTANG** "Auto Confirm User"

7. **Klik "Create user"**

8. **Kembali ke app**, login dengan:
   - Email: `test@animyst.com`
   - Password: `test123456`

---

### CARA 3: Enable Anonymous Login

1. **Buka Supabase Dashboard**

2. **Klik Authentication** → **Providers**

3. **Scroll cari "Anonymous Sign-ins"**

4. **Toggle ON** (aktifkan)

5. **Kembali ke app**

6. **Klik "Login Anonim (Guest)"** ✅

---

## 🔧 Setup Database Field (PENTING!)

Sebelum login, jalankan SQL ini di **Supabase SQL Editor**:

```sql
-- Add free_dust column
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS free_dust INTEGER DEFAULT 3000 CHECK (free_dust >= 0);

-- Update existing profiles
UPDATE profiles SET free_dust = 3000 WHERE free_dust IS NULL;
```

**Cara run:**
1. Buka Supabase Dashboard
2. Klik **SQL Editor** (di sidebar)
3. Klik **New Query**
4. Paste SQL di atas
5. Klik **Run** atau tekan `Ctrl+Enter`

---

## 🎯 Testing Flow Recommended

### Flow 1: Register → Login
```
1. Buka app
2. Klik "Belum punya akun? Daftar di sini"
3. Register dengan:
   - Username: YourName
   - Email: your@email.com
   - Password: minimal 6 karakter
4. Kembali ke login
5. Login dengan email & password tadi
6. ✅ Berhasil! Lihat profile info muncul
```

### Flow 2: Anonymous Login
```
1. Enable anonymous di Supabase (lihat CARA 3)
2. Buka app
3. Klik "Login Anonim (Guest)"
4. ✅ Berhasil! Profile auto-created
```

### Flow 3: Test Account
```
1. Buat user di Supabase Dashboard (CARA 2)
2. Login dengan:
   Email: test@animyst.com
   Password: test123456
3. ✅ Berhasil!
```

---

## 📱 UI Update

Sekarang Login Page punya:
- ✅ Email field
- ✅ Password field
- ✅ "Login with Email" button
- ✅ "Login Anonim (Guest)" button
- ✅ **"Belum punya akun? Daftar di sini"** link (BARU!)

Register Page punya:
- ✅ Username field
- ✅ Email field  
- ✅ Password field
- ✅ "Register" button
- ✅ "Sudah punya akun? Login di sini" link

---

## 🐛 Troubleshooting

### Error: "Invalid login credentials"
**Solusi:**
- Pastikan email & password benar
- Atau register akun baru dulu

### Error: "User already registered"
**Solusi:**
- Email sudah terdaftar
- Gunakan email lain atau login langsung

### Error: "Email not confirmed"
**Solusi:**
- Di Supabase Dashboard → Authentication → Settings
- Cari "Enable email confirmations"
- **DISABLE** untuk testing (atau centang "Auto Confirm" saat buat user)

### Anonymous login tidak bisa
**Solusi:**
- Enable di Supabase: Authentication → Providers → Anonymous Sign-ins → ON
- Atau gunakan email login saja

### Profile tidak muncul setelah login
**Solusi:**
1. Check database trigger:
```sql
-- Check if trigger exists
SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';

-- If not exists, run trigger creation dari supabase_setup.sql
```

2. Atau create profile manual:
```sql
INSERT INTO profiles (id, username, gems, dust, free_dust, pity_counter)
VALUES (
  'your-user-id-here',  -- Get from Authentication > Users
  'TestUser',
  100,
  0,
  3000,
  0
);
```

---

## ✅ Checklist Setup

Sebelum test login, pastikan:

- [ ] Supabase project created
- [ ] Database schema sudah dirun (`supabase_setup.sql`)
- [ ] Field `free_dust` sudah ditambahkan (`database_updates.sql`)
- [ ] App credentials sudah di-update di `main.dart`
- [ ] App sudah di-run (`flutter run`)
- [ ] (Opsional) Anonymous login enabled di Supabase
- [ ] (Opsional) Test user created di Supabase Dashboard

---

## 🎉 Expected Result

Setelah login berhasil, Anda akan lihat:

```
✅ Login Berhasil!
─────────────────
Username: TestUser
Gems: 100
Dust: 0
Free Dust: 3000 ✨
Pity Counter: 0
Last Login: 2/2/2026 02:14

[Logout]

🎁 Daily Bonus!  (jika hari baru)
Free Dust reset to 3000!
```

---

**💪 Silakan coba salah satu dari 3 cara di atas!**

Recommended: **CARA 1 (Register)** - paling mudah dan proper flow.
