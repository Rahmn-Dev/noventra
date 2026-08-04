# Instruksi kerja

Dokumen ini adalah panduan lengkap cara menggunakan aplikasi dari awal hingga akhir. 

---

## 1. Halaman Utama (Dashboard)
Saat pertama kali membuka aplikasi, Anda akan disambut oleh halaman **Dashboard**. Halaman ini adalah pusat kontrol utama.

**Fungsi di halaman ini:**
- **Ringkasan Aktivitas**: Melihat jumlah barang masuk dan keluar hari ini.
- **Peringatan Stok Menipis**: Memberitahu Anda jika ada barang yang jumlahnya kritis (hampir habis).
- **Menu Utama**: Akses cepat ke Daftar Barang, Barang Masuk, Barang Keluar, Input Barang Baru, dan Report Barang.
- **Tombol Scan Barang**: Tombol melayang (kamera) di pojok kanan bawah untuk masuk ke mode pemindai *barcode* / kode material.

![alt text](358shots_so.png)
---

## 2. Input Barang Baru
Sebelum Anda bisa mencatat transaksi masuk/keluar, Anda harus mendaftarkan barang terlebih dahulu jika barang tersebut belum ada di *database*.

**Langkah-langkah:**
1. Di Dashboard, tekan menu **Input Barang Baru**.
2. Masukkan **Kode Material** (Anda bisa mengetik manual atau menekan ikon *kamera* untuk scan kode/teks).
3. Masukkan **Nama Barang**.
4. Masukkan **Stok Awal** (Isi 0 jika barang belum ada fisiknya).
5. Masukkan **Lokasi Penyimpanan**.
6. Tekan tombol **Simpan**.

![alt text](661shots_so.png)
---

## 3. Daftar Barang & Pencarian
Menu ini digunakan untuk melihat semua stok barang yang tersedia.

**Langkah-langkah:**
1. Tekan menu **Daftar Barang** dari Dashboard.
2. Anda akan melihat daftar semua material.
3. Gunakan **Kolom Pencarian (Search)** di bagian atas untuk mencari berdasarkan nama barang atau kode material secara cepat.
4. Tekan salah satu barang untuk masuk ke halaman **Detail Barang** dan melihat riwayat (History) khusus barang tersebut, atau menghapusnya (ikon tempat sampah).

![alt text](128shots_so.png)
---

### 📦 Fitur Barcode Tambahan
- **Cetak Barcode Individu**: Di halaman Detail Barang, klik barcode untuk membuka dialog besar dengan tombol *Cetak Barcode*.
- **Cetak Barcode Massal**: Di halaman Daftar Barang, terdapat ikon **🖨️ Print** di pojok kanan atas. Klik untuk menghasilkan PDF berisi semua barcode dalam bentuk grid.
- **Pemindaian Barcode**: Tombol scan di Dashboard dapat membaca barcode langsung tanpa harus menulis kode secara manual.
- Pastikan **kode material** unik; barcode akan selalu di‑generate berdasarkan kode tersebut.

---

## 4. Barang Masuk (Menambah Stok)
Digunakan ketika ada pasokan barang baru yang datang ke gudang.

**Langkah-langkah:**
1. Pilih menu **Barang Masuk**.
2. **Pilih Barang**: Anda bisa memilih barang dari *Dropdown* (daftar) atau menggunakan **Tombol Scan Kode (Kamera)** untuk mendeteksi barang otomatis.
3. Setelah barang terpilih, masukkan **Jumlah (Qty)** barang yang masuk. Anda bisa menggunakan tombol cepat (10, 50, 100, 500) untuk mempermudah.
4. Opsional: Isi **Catatan** (misal: "Dari Supplier A").
5. Tekan **Konfirmasi**. Stok akan otomatis bertambah!

![alt text](449shots_so.png)

---

## 5. Barang Keluar (Mengurangi Stok)
Digunakan ketika barang diambil dari gudang untuk keperluan produksi atau dikirim.

**Langkah-langkah:**
1. Pilih menu **Barang Keluar**.
2. **Pilih Barang**: Lewat *Dropdown* atau *Scan Kamera*.
3. Masukkan **Jumlah (Qty)** yang akan dikeluarkan.
4. Opsional: Isi **Catatan** (misal: "Untuk proyek B").
5. Tekan **Konfirmasi**. Stok akan otomatis berkurang! *(Catatan: Anda tidak bisa mengeluarkan barang melebihi stok yang ada).*

![alt text](187shots_so.png)

---

## 6. Riwayat Transaksi (History) & Filter
Menu ini sangat berguna untuk audit, melacak siapa/kapan barang masuk dan keluar.

**Langkah-langkah:**
1. Buka halaman **History** dari navigasi bawah (tab bar).
2. Anda akan melihat riwayat transaksi lengkap beserta nama barang, jumlah (berwarna hijau untuk masuk, merah untuk keluar), dan catatan audit.
3. **Filter Tanggal**: Tekan ikon **Kalender** di pojok kanan atas untuk memfilter histori berdasarkan rentang tanggal tertentu (misalnya minggu ini saja).

![alt text](992shots_so.png)

---

## 7. Report Barang (Cetak PDF)
Fitur paling mutakhir untuk keperluan administrasi dan *reporting* harian/bulanan.

**Langkah-langkah:**
1. Buka menu **Report Barang** dari Dashboard.
2. **Pilih Jenis Laporan**:
   - **Kartu Stock**: Mencetak riwayat dan pergerakan saldo (Saldo Awal, Diterima, Dikeluarkan, Saldo Akhir) untuk *satu spesifik barang*. Format mengikuti standar PT. Pindad.
   - **Agenda Masuk**: Rekap semua barang yang masuk pada tanggal tertentu.
   - **Agenda Keluar**: Rekap semua barang yang keluar pada tanggal tertentu.
3. **Pilih Periode Tanggal**.
4. Khusus untuk Kartu Stock, pilih barang yang ingin dicetak dari daftar.
5. Tekan **Buat & Lihat PDF**.
6. Dokumen PDF akan muncul. Tekan ikon **Print** atau **Share** di pojok kanan atas layar untuk membagikannya ke WhatsApp atau menyimpannya.

![alt text](534shots_so.png)
![alt text](338shots_so.png)
---
*Buku panduan ini selesai.* 
