# Struktur Folder Rinci Project Flutter

Struktur ini dibuat agar setiap kode diletakkan sesuai fungsinya. Jadi, kalau nanti ada bagian yang mau diubah, kamu bisa langsung tahu file mana yang harus dibuka.

## 1. Struktur Utama

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── main_page.dart
│   └── splash_page.dart
├── core/
│   ├── constants/
│   ├── helpers/
│   ├── services/
│   └── widgets/
├── home/
│   ├── view/
│   ├── widgets/
│   ├── model/
│   ├── repository/
│   └── bloc/
├── catatan/
│   ├── view/
│   ├── widgets/
│   ├── model/
│   ├── repository/
│   └── bloc/
├── kakulator/
│   ├── view/
│   ├── widgets/
│   ├── model/
│   ├── repository/
│   └── bloc/
├── tabungan/
│   ├── view/
│   ├── widgets/
│   ├── model/
│   ├── repository/
│   └── bloc/
└── tanggal/
    ├── view/
    ├── widgets/
    ├── model/
    ├── repository/
    └── bloc/
```

## 2. Fungsi Folder Global

### `lib/main.dart`
File pertama yang dijalankan Flutter. Di sini hanya memanggil `MyApp`.

### `lib/app/`
Folder khusus pengaturan aplikasi utama.

- `app.dart`: berisi `MaterialApp`, tema warna, dan halaman awal.
- `main_page.dart`: berisi halaman utama yang mengatur menu drawer dan perpindahan halaman.

Kalau ingin mengubah tema aplikasi, buka:

```text
lib/app/app.dart
```

Kalau ingin mengubah urutan menu halaman, buka:

```text
lib/app/main_page.dart
```

### `lib/core/`
Folder untuk kode umum yang dipakai oleh banyak fitur.

- `core/services/`: kode yang berhubungan dengan database, permission, penggunaan data, atau service native.
- `core/widgets/`: widget umum yang bisa dipakai banyak halaman, contohnya drawer.
- `core/constants/`: tempat konstanta umum seperti warna, teks tetap, atau endpoint jika nanti diperlukan.
- `core/helpers/`: tempat fungsi bantuan umum seperti formatter tanggal atau rupiah jika nanti ingin dipusatkan.

## 3. Aturan Isi Folder pada Setiap Fitur

Setiap fitur dibuat dengan pola yang sama:

```text
nama_fitur/
├── view/
├── widgets/
├── model/
├── repository/
└── bloc/
```

Penjelasan:

### `view/`
Berisi halaman utama atau screen. Contohnya `home_page.dart`, `catatan_page.dart`, `tanggal_page.dart`.

Gunakan folder ini kalau ingin mengubah susunan halaman secara besar, misalnya posisi card, tombol utama, atau alur saat tombol ditekan.

### `widgets/`
Berisi potongan tampilan kecil yang dipakai oleh halaman. Contohnya speedometer, tombol kalkulator, editor catatan, kartu tabungan, dan row nama hari.

Gunakan folder ini kalau ingin mengubah bentuk komponen kecil tanpa mengacak halaman utama.

### `model/`
Berisi bentuk data. Contohnya data kalkulator, data tabungan, data riwayat tabungan, dan data hari libur.

Gunakan folder ini kalau ingin mengubah struktur data.

### `repository/`
Berisi kode pengambilan, penyimpanan, update, dan hapus data.

Gunakan folder ini kalau ingin mengubah sumber data, misalnya dari database lokal ke API, atau mengubah cara simpan data.

### `bloc/`
Disiapkan untuk state management BLoC. Untuk project ini beberapa fitur masih memakai `StatefulWidget`, jadi folder `bloc` masih disiapkan agar struktur tetap rapi kalau nanti ingin diubah ke BLoC.

## 4. Detail Per Fitur

## Home

```text
lib/home/
├── view/
│   └── home_page.dart
├── widgets/
│   └── speedometer_gauge.dart
├── model/
├── repository/
└── bloc/
```

Fungsi file:

- `view/home_page.dart`: halaman Home, proses speed test, cek koneksi, load data usage, tombol refresh, tombol start test, dan menu website.
- `widgets/speedometer_gauge.dart`: tampilan speedometer, animasi jarum/progress, painter speedometer, angka speed, skala 0 sampai 100+.

Kalau ingin mengubah gerakan speedometer, buka:

```text
lib/home/widgets/speedometer_gauge.dart
```

Kalau ingin mengubah tombol START TEST atau data download/upload, buka:

```text
lib/home/view/home_page.dart
```

## Catatan

```text
lib/catatan/
├── view/
│   └── catatan_page.dart
├── widgets/
│   └── catatan_editor.dart
├── repository/
│   └── catatan_repository.dart
├── model/
└── bloc/
```

Fungsi file:

- `view/catatan_page.dart`: halaman catatan, controller text, load catatan saat halaman dibuka, dan simpan otomatis saat halaman ditutup.
- `widgets/catatan_editor.dart`: tampilan kotak input catatan.
- `repository/catatan_repository.dart`: ambil, simpan, dan hapus catatan dari `SharedPreferences`.

Kalau ingin mengubah desain kotak catatan, buka:

```text
lib/catatan/widgets/catatan_editor.dart
```

Kalau ingin mengubah cara catatan disimpan, buka:

```text
lib/catatan/repository/catatan_repository.dart
```

## Kalkulator

```text
lib/kakulator/
├── view/
│   └── kakulator_view.dart
├── widgets/
│   └── kalkulator_button.dart
├── model/
│   └── kalkulator_model.dart
├── repository/
│   └── kalkulator_repository.dart
└── bloc/
```

Fungsi file:

- `view/kakulator_view.dart`: halaman kalkulator, susunan tombol, input angka, dan tampilan hasil.
- `widgets/kalkulator_button.dart`: desain tombol kalkulator.
- `model/kalkulator_model.dart`: menyimpan data `input` dan `hasil` kalkulator.
- `repository/kalkulator_repository.dart`: logika perhitungan tambah, kurang, kali, dan bagi.

Kalau ingin mengubah warna/tampilan tombol kalkulator, buka:

```text
lib/kakulator/widgets/kalkulator_button.dart
```

Kalau ingin mengubah rumus atau logika hitung, buka:

```text
lib/kakulator/repository/kalkulator_repository.dart
```

## Tabungan

```text
lib/tabungan/
├── view/
│   ├── tabungan_page.dart
│   ├── tambah_page.dart
│   └── detail_page.dart
├── widgets/
│   ├── tabungan_card.dart
│   └── tabungan_format_helper.dart
├── model/
│   ├── tabungan_model.dart
│   └── riwayat_tabungan_model.dart
├── repository/
│   └── tabungan_repository.dart
└── bloc/
```

Fungsi file:

- `view/tabungan_page.dart`: halaman daftar tabungan/celengan.
- `view/tambah_page.dart`: halaman tambah dan edit tabungan.
- `view/detail_page.dart`: halaman detail tabungan, tambah nominal, kurangi nominal, riwayat, edit, dan hapus.
- `widgets/tabungan_card.dart`: tampilan card tabungan di halaman daftar.
- `widgets/tabungan_format_helper.dart`: helper format rupiah, nominal, dan tanggal.
- `model/tabungan_model.dart`: bentuk data tabungan.
- `model/riwayat_tabungan_model.dart`: bentuk data riwayat tabungan.
- `repository/tabungan_repository.dart`: semua proses ambil, tambah, update, hapus tabungan, update nominal terkumpul, dan ambil riwayat.

Kalau ingin mengubah tampilan card tabungan, buka:

```text
lib/tabungan/widgets/tabungan_card.dart
```

Kalau ingin mengubah form tambah/edit tabungan, buka:

```text
lib/tabungan/view/tambah_page.dart
```

Kalau ingin mengubah halaman detail tabungan, buka:

```text
lib/tabungan/view/detail_page.dart
```

Kalau ingin mengubah database tabungan, buka:

```text
lib/tabungan/repository/tabungan_repository.dart
lib/core/services/note_database_service.dart
```

## Tanggal

```text
lib/tanggal/
├── view/
│   └── tanggal_page.dart
├── widgets/
│   └── day_name_row.dart
├── model/
│   └── holiday_info.dart
├── repository/
│   └── tanggal_repository.dart
└── bloc/
```

Fungsi file:

- `view/tanggal_page.dart`: halaman kalender, pindah bulan, klik tanggal, dialog catatan tanggal, dan tampilan daftar catatan bulan tersebut.
- `widgets/day_name_row.dart`: tampilan nama hari Senin sampai Minggu.
- `model/holiday_info.dart`: bentuk data hari libur nasional dan cuti bersama.
- `repository/tanggal_repository.dart`: ambil data libur dari API dan ambil/simpan/hapus catatan tanggal dari database lokal.

Kalau ingin mengubah tampilan kalender, buka:

```text
lib/tanggal/view/tanggal_page.dart
```

Kalau ingin mengubah sumber data hari libur, buka:

```text
lib/tanggal/repository/tanggal_repository.dart
```

Kalau ingin mengubah model data hari libur, buka:

```text
lib/tanggal/model/holiday_info.dart
```

## 5. Ringkasan Cepat Kalau Mau Edit

```text
Ubah tema aplikasi              -> lib/app/app.dart
Ubah menu drawer                -> lib/core/widgets/app_drawer.dart
Ubah perpindahan halaman        -> lib/app/main_page.dart
Ubah speedometer                -> lib/home/widgets/speedometer_gauge.dart
Ubah halaman Home               -> lib/home/view/home_page.dart
Ubah kotak catatan              -> lib/catatan/widgets/catatan_editor.dart
Ubah penyimpanan catatan        -> lib/catatan/repository/catatan_repository.dart
Ubah tombol kalkulator          -> lib/kakulator/widgets/kalkulator_button.dart
Ubah logika hitung kalkulator   -> lib/kakulator/repository/kalkulator_repository.dart
Ubah daftar tabungan            -> lib/tabungan/view/tabungan_page.dart
Ubah card tabungan              -> lib/tabungan/widgets/tabungan_card.dart
Ubah tambah/edit tabungan       -> lib/tabungan/view/tambah_page.dart
Ubah detail tabungan            -> lib/tabungan/view/detail_page.dart
Ubah database tabungan/tanggal  -> lib/core/services/note_database_service.dart
Ubah API hari libur             -> lib/tanggal/repository/tanggal_repository.dart
Ubah kalender                   -> lib/tanggal/view/tanggal_page.dart
```
