# 🖼️ GUIDE: Menampilkan Gambar Kartu dari Supabase

Fitur gambar sekarang sudah **diaktifkan secara otomatis**! Aplikasi akan mencoba mengambil gambar langsung dari Supabase Storage.

## ✅ Cara Agar Gambar Tampil

Agar gambar hewan/kartu tampil (menggantikan icon), Anda perlu memastikan setup di Supabase Storage sudah benar.

### 1. Buat Bucket Storage
1. Login ke **Supabase Dashboard**.
2. Pilih menu **Storage** (icon folder di kiri).
3. Buat bucket baru dengan nama: **`card_images`** (PENTING: Nama harus persis sama!).
4. Pastikan bucket ini **Public** (agar bisa diakses tanpa login khusus storage).

### 2. Upload Gambar
Upload file gambar (PNG/JPG) ke bucket `card_images` tersebut.
Nama file yang diupload **HARUS SAMA PERSIS** dengan data di database.

Berikut daftar nama file yang diharapkan (sesuai SQL yang sudah diinsert):

**Ultra Rare:**
- `dragon.png`
- `phoenix.png`
- `unicorn.png`
- `griffin.png`
- `kraken.png`

**Super Rare:**
- `lion.png`
- `tiger.png`
- `eagle.png`
- `wolf.png`
- `bear.png`

**Rare:**
- `hawk.png`, `fox.png`, `deer.png`, `panther.png`, `cobra.png`...

**Elite & Normal:**
- `rabbit.png`, `squirrel.png`, `mouse.png`, `rat.png`...

### 3. Test Tampilan
Setelah upload:
1.  **Restart Aplikasi** (`R` di terminal).
2.  Buka **Inventory**.
3.  Tunggu sebentar, gambar seharusnya muncul!
4.  Jika masih loading lama, pastikan internet lancar.

---

### 🔍 Troubleshooting

**Q: Gambar masih icon / tidak muncul?**
1.  Cek nama bucket: Apakah benar `card_images`? (case sensitive).
2.  Cek nama file: Apakah `dragon.png` (huruf kecil semua) atau `Dragon.png`? Database kita pakai huruf kecil (lihat SQL).
3.  Cek apakah bucket **Public**?
4.  Cek Console Log (`F12`): Saya sudah menambahkan log `📸 Generated Image URL: ...`. Coba copy URL tersebut dan buka di browser. Jika `404 Not Found`, berarti file tidak ada atau nama salah.

**Q: Bagaimana jika bucket saya namanya bukan `card_images`?**
Anda perlu memberi tahu saya nama bucket Anda, atau mengganti nama bucket di kode `InventoryPage.dart`, `CardDetailDialog.dart`, dan `GachaResultDialog.dart`.

Cari baris ini di file-file tersebut:
```dart
final bucketName = 'card_images';
```
Dan ganti dengan nama bucket Anda.
