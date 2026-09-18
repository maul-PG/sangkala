# SETUP_ENV.md — Sangkala (SI-EVENT)

Panduan cepat untuk anggota tim yang baru melakukan `git clone` proyek ini.

---

## Prasyarat

Pastikan tools berikut sudah terpasang di komputer kamu:

| Tool | Versi Minimum | Cek dengan |
|---|---|---|
| Flutter SDK | 3.13.x | `flutter --version` |
| Dart SDK | 3.1.x (bundled dengan Flutter) | `dart --version` |
| Android Studio / VS Code | Terbaru | — |
| Android Emulator / Device fisik | API 21+ | — |

---

## Langkah Setup

### 1. Clone & Masuk ke Direktori

```bash
git clone <url-repo>
cd sangkala
```

### 2. Install Semua Package

```bash
flutter pub get
```

Perintah ini akan mengunduh semua dependency yang terdaftar di `pubspec.yaml`, termasuk:
- `supabase_flutter` — koneksi ke Supabase
- `provider` — state management
- `intl` — format tanggal dan angka
- `hijri` — konversi kalender Hijriah

### 3. Verifikasi Konfigurasi Supabase

Buka file `lib/main.dart` dan pastikan nilai berikut sudah terisi:

```dart
await Supabase.initialize(
  url: 'https://twbzzzpawrvhxagyzmbh.supabase.co',
  anonKey: 'sb_publishable_gps4MtFHUdoBq4FD-YP1SQ_I8g81od6',
);
```

> **Catatan keamanan:** `anonKey` di atas adalah **publishable key** (aman untuk client-side Flutter).
> Jangan pernah memasukkan `service_role` key ke dalam kode Flutter.

### 4. Cek Flutter Doctor

```bash
flutter doctor
```

Pastikan tidak ada masalah kritis (tanda ✗ merah). Tanda ⚠️ kuning pada tools yang tidak digunakan (Xcode, Chrome) bisa diabaikan jika kamu hanya develop untuk Android.

### 5. Jalankan Aplikasi

```bash
# Cek device yang tersedia
flutter devices

# Jalankan di device/emulator yang terpilih
flutter run

# Atau spesifik ke device tertentu
flutter run -d <device-id>
```

---

## Struktur Folder Penting

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart   ← nama tabel, opsi role & status
│   ├── services/
│   │   └── supabase_service.dart ← semua akses Supabase di sini
│   └── theme/
│       └── app_theme.dart       ← ThemeData Material 3
├── models/
│   ├── profile.dart
│   ├── event.dart
│   ├── event_budget.dart
│   └── team_member.dart
├── screens/
│   ├── auth/                    ← login & register
│   ├── home/                    ← halaman utama (5 menu)
│   ├── events/                  ← CRUD kegiatan kampus
│   ├── computations/            ← kalkulator anggaran
│   ├── conversions/             ← konversi hijriah, weton, saka
│   ├── members/                 ← daftar anggota tim
│   └── help/                    ← panduan + logout
├── widgets/
│   └── main_scaffold.dart       ← BottomNavigationBar 3 tab
└── main.dart                    ← entry point + AuthGate
```

---

## Troubleshooting Umum

| Masalah | Solusi |
|---|---|
| `flutter pub get` gagal | Cek koneksi internet; jalankan `flutter clean` lalu coba lagi |
| Emulator tidak muncul di `flutter devices` | Buka Android Studio → AVD Manager → Start emulator |
| Error `CERTIFICATE_VERIFY_FAILED` | Jalankan `flutter run` dengan flag `--no-sound-null-safety` (jarang terjadi) |
| App crash saat login/register | Pastikan nilai `url` dan `anonKey` di `main.dart` sudah benar |
| Data tidak muncul padahal sudah ada di DB | Cek RLS Supabase — pastikan user sudah login sebelum query |

---

## Referensi

- [Dokumentasi Backend & API](./DOCS_BACKEND.md)
- [Pembagian Tugas Tim](./TASK_TRACKING.md)
- [Supabase Flutter Docs](https://supabase.com/docs/reference/dart/introduction)
- [Flutter Docs](https://docs.flutter.dev)
