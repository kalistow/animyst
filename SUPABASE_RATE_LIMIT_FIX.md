# 🔧 Fix: Supabase Rate Limit Error

## ❌ Error yang Muncul

```
AuthApiException(message: For security purposes, you can only request 
this after 17 seconds (rate limit), code over_email_send_rate_limit)
```

## 🎯 Penyebab

Supabase membatasi **berapa kali email konfirmasi** bisa dikirim dalam waktu singkat.
Ini terjadi saat:
- Register terlalu cepat/berulang kali
- Email confirmation masih ENABLED (default)

## ✅ SOLUSI

### Solusi 1: Disable Email Confirmation (RECOMMENDED)

**Best untuk development/testing:**

1. **Buka Supabase Dashboard:**
   ```
   https://supabase.com/dashboard
   ```

2. **Pilih project Anda**

3. **Klik Authentication** (sidebar kiri)

4. **Klik Settings** (di bawah Authentication)

5. **Scroll ke "Email" section**

6. **DISABLE/UNCHECK:**
   - "Enable email confirmations"
   - "Confirm email"

7. **Save changes**

8. **Tunggu 1-2 menit** untuk changes apply

9. **Coba register lagi!** ✅

---

### Solusi 2: Tunggu Rate Limit Reset

**Paling simple:**

1. **Tunggu 30-60 detik**
2. **Coba register lagi**
3. Gunakan **email berbeda** jika perlu

---

### Solusi 3: Buat User Manual

**Tercepat untuk quick testing:**

1. **Supabase Dashboard** → **Authentication** → **Users**

2. **Click "Add user"**

3. **Isi form:**
   - Email: `cosmos1@gmail.com`
   - Password: `your-password`
   - ✅ **CENTANG "Auto Confirm User"**

4. **Click "Create user"**

5. **Kembali ke app** → Login dengan email/password tadi

---

## 📋 Settings yang Recommended untuk Testing

Di **Supabase** → **Authentication** → **Settings**:

```
Email Auth Settings:
├─ Enable email signups: ✅ ON
├─ Confirm email: ❌ OFF  ← Disable untuk testing!
├─ Secure email change: ❌ OFF
└─ Enable email confirmations: ❌ OFF  ← Disable!

Rate Limits (tidak bisa diubah di free tier):
├─ Email send rate limit: ~60 seconds
└─ Password reset rate limit: ~60 seconds
```

---

## 🎯 Flow Setelah Fix

**Jika email confirmation DISABLED:**

```
1. User register
   ↓
2. Account langsung ACTIVE (no email needed)
   ↓
3. Auto-login atau redirect ke login
   ↓
4. User bisa langsung login ✅
```

**Jika email confirmation ENABLED (default):**

```
1. User register
   ↓
2. Supabase kirim email konfirmasi
   ↓
3. User harus click link di email
   ↓
4. Account active
   ↓
5. Baru bisa login
```

---

## 💡 Best Practices

### Development/Testing:
- ✅ Disable email confirmation
- ✅ Use "Auto Confirm User" saat buat manual
- ✅ Test dengan email dummy

### Production:
- ✅ Enable email confirmation
- ✅ Setup SMTP provider (Sendgrid, etc)  
- ✅ Customize email templates
- ✅ Add rate limiting di app level

---

## 🐛 Troubleshooting

### Error masih muncul setelah disable?
**Solusi:**
- Clear browser cache/cookies
- Tunggu 2-3 menit untuk settings propagate
- Restart app

### User created tapi tidak bisa login?
**Solusi:**
- Check user status di Dashboard: should be "confirmed"
- If not confirmed, manually confirm:
  - Dashboard → Users → Click user → "Confirm email"

### Register berhasil tapi profile tidak dibuat?
**Solusi:**
Check database trigger exists:
```sql
SELECT * FROM pg_trigger 
WHERE tgname = 'on_auth_user_created';
```

If tidak ada, run `supabase_setup.sql` untuk create trigger.

---

## ✅ Verification

Setelah fix, test register:

1. Register dengan data:
   - Username: TestUser2
   - Email: test2@example.com
   - Password: test123456

2. **Success indicators:**
   - ✅ No red error
   - ✅ Redirect ke login atau auto-login
   - ✅ Bisa login langsung

3. **Check database:**
```sql
-- Check user created
SELECT * FROM auth.users WHERE email = 'test2@example.com';

-- Check profile created
SELECT * FROM profiles WHERE username = 'TestUser2';
```

---

**🚀 Setelah disable email confirmation, register akan smooth tanpa rate limit!**
