---

# 🎬 Sistem Database Bioskop

### ⚡ Penerapan Trigger & View di Database Bioskop

---

## 👥 Team Members

| No Absen | Nama                 |
| -- | -------------------- |
| 6  | Aulia Bilqis Zahrani |
| 19  | Muhamad Adli Irawan  |
| 28 | Rafa Zulfahmi        |

---

## 📖 Overview

Project ini merupakan implementasi sistem database **pemesanan tiket bioskop** dengan fokus pada:

| Fitur     | Deskripsi                      |
| --------- | ------------------------------ |
| ⚡ Trigger | Otomatisasi perubahan data     |
| 👁️ View  | Menyederhanakan query kompleks |

---

# 🗂️ Struktur Tabel

| Tabel        | Fungsi         |
| ------------ | -------------- |
| film         | Data film      |
| studio       | Data studio    |
| kursi        | Data kursi     |
| jadwal       | Jadwal film    |
| pelanggan    | Data pelanggan |
| pembelian    | Transaksi      |
| detail_tiket | Detail tiket   |

---

# ⚡ TRIGGER

## 📌 Daftar Trigger

| Nama Trigger               | Event         | Tabel        | Fungsi                |
| -------------------------- | ------------- | ------------ | --------------------- |
| before_insert_pembelian    | BEFORE INSERT | pembelian    | Isi tanggal otomatis  |
| after_insert_detail_tiket  | AFTER INSERT  | detail_tiket | Kursi jadi terisi     |
| before_update_pembelian    | BEFORE UPDATE | pembelian    | Update waktu          |
| after_update_detail_tiket  | AFTER UPDATE  | detail_tiket | Sinkronisasi kursi    |
| before_delete_detail_tiket | BEFORE DELETE | detail_tiket | Simpan data sementara |
| after_delete_detail_tiket  | AFTER DELETE  | detail_tiket | Kursi jadi tersedia   |

---

## 🔥 Query Trigger

### 1. BEFORE INSERT (pembelian)

```sql
CREATE TRIGGER before_insert_pembelian
BEFORE INSERT ON pembelian
FOR EACH ROW
SET NEW.tanggal_beli = NOW();
```

---

### 2. AFTER INSERT (detail_tiket)

```sql
CREATE TRIGGER after_insert_detail_tiket
AFTER INSERT ON detail_tiket
FOR EACH ROW
UPDATE kursi
SET status = 'terisi'
WHERE id_kursi = NEW.id_kursi;
```

---

### 3. BEFORE UPDATE (pembelian)

```sql
CREATE TRIGGER before_update_pembelian
BEFORE UPDATE ON pembelian
FOR EACH ROW
SET NEW.tanggal_beli = NOW();
```

---

### 4. AFTER UPDATE (detail_tiket)

```sql
CREATE TRIGGER after_update_detail_tiket
AFTER UPDATE ON detail_tiket
FOR EACH ROW
UPDATE kursi
SET status = 'terisi'
WHERE id_kursi = NEW.id_kursi;
```

---

### 5. BEFORE DELETE (detail_tiket)

```sql
CREATE TRIGGER before_delete_detail_tiket
BEFORE DELETE ON detail_tiket
FOR EACH ROW
SET @id_kursi_hapus = OLD.id_kursi;
```

---

### 6. AFTER DELETE (detail_tiket)

```sql
CREATE TRIGGER after_delete_detail_tiket
AFTER DELETE ON detail_tiket
FOR EACH ROW
UPDATE kursi
SET status = 'tersedia'
WHERE id_kursi = OLD.id_kursi;
```

---

# 👁️ VIEW


## 📊 1. View Jadwal Lengkap

### 🔹 Query

```sql
CREATE VIEW view_jadwal_lengkap AS
SELECT 
    jadwal.id_jadwal,
    film.judul,
    film.genre,
    jadwal.tanggal,
    jadwal.jam_tayang,
    jadwal.harga,
    studio.nama_studio
FROM jadwal
JOIN film ON jadwal.id_film = film.id_film
JOIN studio ON jadwal.id_studio = studio.id_studio;
```

---

### 🔹 Output

| id_jadwal | judul      | genre     | tanggal    | jam_tayang | harga | nama_studio |
| --------- | ---------- | --------- | ---------- | ---------- | ----- | ----------- |
| 1         | Avengers   | Action    | 2026-04-10 | 14:00:00   | 50000 | Studio 1    |
| 2         | Frozen     | Animation | 2026-04-10 | 16:00:00   | 45000 | Studio 2    |
| 3         | Joker      | Drama     | 2026-04-11 | 18:00:00   | 55000 | Studio 3    |
| 4         | Spider-Man | Action    | 2026-04-11 | 20:00:00   | 50000 | Studio 4    |
| 5         | Conjuring  | Horror    | 2026-04-12 | 19:00:00   | 60000 | Studio 5    |

---

## 🎟️ 2. View Detail Tiket

### 🔹 Query

```sql
CREATE VIEW view_detail_tiket AS
SELECT
    pembelian.id_pembelian,
    pelanggan.nama AS nama_pelanggan,
    film.judul,
    jadwal.tanggal,
    jadwal.jam_tayang,
    kursi.nomor_kursi,
    detail_tiket.harga
FROM pembelian
JOIN pelanggan ON pembelian.id_pelanggan = pelanggan.id_pelanggan
JOIN jadwal ON pembelian.id_jadwal = jadwal.id_jadwal
JOIN film ON jadwal.id_film = film.id_film
JOIN detail_tiket ON pembelian.id_pembelian = detail_tiket.id_pembelian
JOIN kursi ON detail_tiket.id_kursi = kursi.id_kursi;
```

---

### 🔹 Output

| id_pembelian | nama_pelanggan | judul      | tanggal    | jam_tayang | nomor_kursi | harga |
| ------------ | -------------- | ---------- | ---------- | ---------- | ----------- | ----- |
| 1            | Aulia          | Avengers   | 2026-04-10 | 14:00:00   | A1          | 50000 |
| 1            | Aulia          | Avengers   | 2026-04-10 | 14:00:00   | A2          | 50000 |
| 2            | Budi           | Frozen     | 2026-04-10 | 16:00:00   | A3          | 45000 |
| 3            | Siti           | Joker      | 2026-04-11 | 18:00:00   | A1          | 55000 |
| 4            | Rizky          | Spider-Man | 2026-04-11 | 20:00:00   | A1          | 50000 |

---

## 💺 3. View Kursi Studio

### 🔹 Query

```sql
CREATE VIEW view_kursi_studio AS
SELECT
    kursi.id_kursi,
    kursi.nomor_kursi,
    kursi.status,
    studio.nama_studio
FROM kursi
JOIN studio ON kursi.id_studio = studio.id_studio;
```

---

### 🔹 Output

| id_kursi | nomor_kursi | status   | nama_studio |
| -------- | ----------- | -------- | ----------- |
| 1        | A1          | terisi   | Studio 1    |
| 2        | A2          | terisi   | Studio 1    |
| 3        | A3          | terisi   | Studio 1    |
| 4        | A4          | tersedia | Studio 1    |
| 5        | A5          | tersedia | Studio 1    |
| 6        | B1          | tersedia | Studio 1    |
| 7        | B2          | tersedia | Studio 1    |
| 8        | B3          | tersedia | Studio 1    |
| 9        | B4          | tersedia | Studio 1    |
| 10       | B5          | tersedia | Studio 1    |
| 11       | A1          | terisi   | Studio 2    |
| 12       | A2          | tersedia | Studio 2    |
| 13       | A3          | tersedia | Studio 2    |
| 14       | A4          | tersedia | Studio 2    |
| 15       | A5          | tersedia | Studio 2    |
| 16       | A1          | terisi   | Studio 3    |
| 17       | A2          | tersedia | Studio 3    |
| 18       | A3          | tersedia | Studio 3    |
| 19       | A4          | tersedia | Studio 3    |
| 20       | A5          | tersedia | Studio 3    |

---

# 🚀 Kesimpulan

| Fitur   | Manfaat               |
| ------- | --------------------- |
| Trigger | Otomatisasi sistem    |
| View    | Query lebih sederhana |
| Relasi  | Data konsisten        |

---

# ⭐ Highlight

* ⚡ Update kursi otomatis
* 🔄 Sistem real-time sederhana
* 👁️ View mempermudah analisis
* 📊 Struktur siap dikembangkan

---

