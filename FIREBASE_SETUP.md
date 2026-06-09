# Setup Firebase Firestore untuk aplikasi Flutter

File `lib` di zip ini sudah diubah agar memakai Cloud Firestore.
Bagian yang berubah:

1. `lib/main.dart`
   - Menambahkan `Firebase.initializeApp()`.

2. `lib/core/services/note_database_service.dart`
   - Penyimpanan `notes`, `tabungan`, dan `riwayat_tabungan` dipindahkan dari SQLite ke Firestore.

3. `lib/catatan/repository/catatan_repository.dart`
   - Penyimpanan catatan harian dipindahkan dari SharedPreferences ke Firestore.

## Dependency yang harus ditambahkan di pubspec.yaml

Tambahkan ini di bagian `dependencies:`:

```yaml
firebase_core: ^3.15.2
cloud_firestore: ^5.6.12
```

Kalau project kamu masih memakai `sqflite`, `path`, atau `shared_preferences` untuk fitur lain, jangan langsung hapus. Kalau sudah tidak dipakai sama sekali, baru boleh dihapus.

## Setup Firebase Console

1. Buka Firebase Console.
2. Buat project baru.
3. Tambahkan aplikasi Android.
4. Isi package name sesuai package Android project kamu.
5. Download file `google-services.json`.
6. Simpan file itu di:

```text
android/app/google-services.json
```

7. Aktifkan Firestore Database.
8. Pilih mode test dulu saat pengembangan.

## Setting Android Gradle

Di `android/build.gradle` bagian dependencies, pastikan ada:

```gradle
classpath 'com.google.gms:google-services:4.4.2'
```

Di `android/app/build.gradle`, bagian paling bawah tambahkan:

```gradle
apply plugin: 'com.google.gms.google-services'
```

Pada project Flutter versi baru yang memakai `plugins {}`, tambahkan ini di `android/app/build.gradle`:

```gradle
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'dev.flutter.flutter-gradle-plugin'
    id 'com.google.gms.google-services'
}
```

Jangan pakai dua cara sekaligus. Kalau sudah memakai `plugins {}`, tidak perlu `apply plugin`.

## Struktur database Firestore

```text
catatan_harian
  catatan_utama
    isi: string
    updatedAt: timestamp

notes
  2026-06-09
    date: string
    note: string
    updatedAt: timestamp

tabungan
  {id}
    id: number
    nama: string
    target: number
    terkumpul: number
    hari: number
    gambar: string/null
    createdAt: timestamp
    updatedAt: timestamp

riwayat_tabungan
  {id}
    id: number
    tabungan_id: number
    nominal: number
    tipe: string
    keterangan: string
    tanggal: string
    createdAt: timestamp
```

## Aturan Firestore sementara untuk testing

Gunakan ini hanya untuk tugas/pengembangan awal:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

Kalau aplikasi nanti sudah pakai login, rules harus diperketat.

## Catatan penting

Kode ini belum memasukkan `google-services.json` karena file itu harus dibuat dari Firebase Console milik kamu sendiri.
Kalau muncul error `Default FirebaseApp is not initialized`, cek lagi `Firebase.initializeApp()` dan lokasi `google-services.json`.
Kalau muncul error Firestore index pada `riwayat_tabungan`, klik link yang muncul di debug console untuk membuat index otomatis.
