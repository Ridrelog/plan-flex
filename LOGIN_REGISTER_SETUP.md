# Setup Login & Register Firebase

Fitur yang ditambahkan:

- Login menggunakan email dan password.
- Register menggunakan nama, email, dan password.
- Auto-check login: kalau user sudah login, langsung masuk ke `MainPage`.
- Logout dari drawer.
- Profil user tersimpan di Firestore collection `users`.
- Data aplikasi tetap memakai konsep local first: simpan lokal HP dulu, lalu sync ke Firebase.

## 1. Tambahkan dependency di pubspec.yaml

```yaml
dependencies:
  firebase_core: ^3.15.2
  firebase_auth: ^5.7.0
  cloud_firestore: ^5.6.12
  sqflite: ^2.3.3
  path: ^1.9.0
```

Lalu jalankan:

```bash
flutter pub get
```

## 2. Aktifkan Email/Password di Firebase Console

Masuk ke Firebase Console:

Authentication → Sign-in method → Email/Password → Enable → Save

## 3. Pastikan Google Services benar

File ini harus ada:

```text
android/app/google-services.json
```

Di `android/app/build.gradle.kts`, bagian plugins harus seperti ini:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}
```

## 4. Jalankan ulang

```bash
flutter clean
flutter pub get
flutter run
```
