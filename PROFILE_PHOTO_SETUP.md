# Setup Foto Profile

Fitur foto profile sudah ditambahkan di:

- `lib/profile/view/profile_page.dart`
- `lib/profile/repository/profile_repository.dart`
- `lib/core/widgets/app_drawer.dart`

Tambahkan dependency ini di `pubspec.yaml` kalau belum ada:

```yaml
dependencies:
  image_picker: ^1.1.2
  path_provider: ^2.1.5
```

Lalu jalankan:

```bash
flutter clean
flutter pub get
flutter run
```

Catatan:

- Foto profile disimpan ke penyimpanan lokal aplikasi di HP.
- Path foto juga disimpan di Firestore collection `users` field `photoPath`.
- Kalau aplikasi dihapus dari HP, foto lokal juga ikut hilang.
- Kalau ingin foto profile bisa muncul di HP lain juga, perlu menambahkan Firebase Storage.
