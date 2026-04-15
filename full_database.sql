-- =========================
-- DATABASE
-- =========================
CREATE DATABASE IF NOT EXISTS bioskop;
USE bioskop;

-- =========================
-- TABLE
-- =========================

CREATE TABLE film (
    id_film INT AUTO_INCREMENT PRIMARY KEY,
    judul VARCHAR(100),
    genre VARCHAR(50),
    durasi INT,
    rating_usia VARCHAR(10)
);

CREATE TABLE studio (
    id_studio INT AUTO_INCREMENT PRIMARY KEY,
    nama_studio VARCHAR(50),
    kapasitas INT
);

CREATE TABLE kursi (
    id_kursi INT AUTO_INCREMENT PRIMARY KEY,
    id_studio INT,
    nomor_kursi VARCHAR(10),
    status VARCHAR(10) DEFAULT 'tersedia',
    FOREIGN KEY (id_studio) REFERENCES studio(id_studio)
);

CREATE TABLE jadwal (
    id_jadwal INT AUTO_INCREMENT PRIMARY KEY,
    id_film INT,
    id_studio INT,
    tanggal DATE,
    jam_tayang TIME,
    harga INT,
    FOREIGN KEY (id_film) REFERENCES film(id_film),
    FOREIGN KEY (id_studio) REFERENCES studio(id_studio)
);

CREATE TABLE pelanggan (
    id_pelanggan INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100),
    no_telp VARCHAR(15)
);

CREATE TABLE pembelian (
    id_pembelian INT AUTO_INCREMENT PRIMARY KEY,
    id_pelanggan INT,
    id_jadwal INT,
    tanggal_beli DATETIME,
    total INT,
    FOREIGN KEY (id_pelanggan) REFERENCES pelanggan(id_pelanggan),
    FOREIGN KEY (id_jadwal) REFERENCES jadwal(id_jadwal)
);

CREATE TABLE detail_tiket (
    id_detail INT AUTO_INCREMENT PRIMARY KEY,
    id_pembelian INT,
    id_kursi INT,
    harga INT,
    FOREIGN KEY (id_pembelian) REFERENCES pembelian(id_pembelian),
    FOREIGN KEY (id_kursi) REFERENCES kursi(id_kursi)
);

-- =========================
-- TRIGGER
-- =========================

DELIMITER //

CREATE TRIGGER before_insert_pembelian
BEFORE INSERT ON pembelian
FOR EACH ROW
BEGIN
    SET NEW.tanggal_beli = NOW();
END //

CREATE TRIGGER after_insert_detail_tiket
AFTER INSERT ON detail_tiket
FOR EACH ROW
BEGIN
    UPDATE kursi
    SET status = 'terisi'
    WHERE id_kursi = NEW.id_kursi;
END //

CREATE TRIGGER before_update_pembelian
BEFORE UPDATE ON pembelian
FOR EACH ROW
BEGIN
    SET NEW.tanggal_beli = NOW();
END //

CREATE TRIGGER after_update_detail_tiket
AFTER UPDATE ON detail_tiket
FOR EACH ROW
BEGIN
    UPDATE kursi
    SET status = 'terisi'
    WHERE id_kursi = NEW.id_kursi;
END //

CREATE TRIGGER before_delete_detail_tiket
BEFORE DELETE ON detail_tiket
FOR EACH ROW
BEGIN
    SET @id_kursi_hapus = OLD.id_kursi;
END //

CREATE TRIGGER after_delete_detail_tiket
AFTER DELETE ON detail_tiket
FOR EACH ROW
BEGIN
    UPDATE kursi
    SET status = 'tersedia'
    WHERE id_kursi = OLD.id_kursi;
END //

DELIMITER ;

-- =========================
-- DATA
-- =========================

INSERT INTO film (judul, genre, durasi, rating_usia) VALUES
('Avengers', 'Action', 120, '13+'),
('Frozen', 'Animation', 100, 'SU'),
('Joker', 'Drama', 110, '17+'),
('Spider-Man', 'Action', 115, '13+'),
('Conjuring', 'Horror', 105, '17+');

INSERT INTO studio (nama_studio, kapasitas) VALUES
('Studio 1', 50),
('Studio 2', 40),
('Studio 3', 30),
('Studio 4', 25),
('Studio 5', 20);

INSERT INTO kursi (id_studio, nomor_kursi, status) VALUES
(1,'A1','tersedia'),(1,'A2','tersedia'),(1,'A3','tersedia'),(1,'A4','tersedia'),(1,'A5','tersedia'),
(1,'B1','tersedia'),(1,'B2','tersedia'),(1,'B3','tersedia'),(1,'B4','tersedia'),(1,'B5','tersedia'),
(2,'A1','tersedia'),(2,'A2','tersedia'),(2,'A3','tersedia'),(2,'A4','tersedia'),(2,'A5','tersedia'),
(3,'A1','tersedia'),(3,'A2','tersedia'),(3,'A3','tersedia'),(3,'A4','tersedia'),(3,'A5','tersedia');

INSERT INTO jadwal (id_film, id_studio, tanggal, jam_tayang, harga) VALUES
(1,1,'2026-04-10','14:00:00',50000),
(2,2,'2026-04-10','16:00:00',45000),
(3,3,'2026-04-11','18:00:00',55000),
(4,4,'2026-04-11','20:00:00',50000),
(5,5,'2026-04-12','19:00:00',60000);

INSERT INTO pelanggan (nama, no_telp) VALUES
('Aulia', '08123456789'),
('Budi', '08234567890'),
('Siti', '08111111111'),
('Rizky', '08222222222'),
('Dina', '08333333333');

INSERT INTO pembelian (id_pelanggan, id_jadwal, total) VALUES
(1,1,100000),
(2,2,45000),
(3,3,55000),
(4,4,50000),
(5,5,60000);

INSERT INTO detail_tiket (id_pembelian, id_kursi, harga) VALUES
(1,1,50000),
(1,2,50000),
(2,3,45000),
(3,11,55000),
(4,16,50000);

-- =========================
-- VIEW
-- =========================

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

CREATE VIEW view_kursi_studio AS
SELECT
    kursi.id_kursi,
    kursi.nomor_kursi,
    kursi.status,
    studio.nama_studio
FROM kursi
JOIN studio ON kursi.id_studio = studio.id_studio;