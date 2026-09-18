# TASK_TRACKING.md — Sangkala (SI-EVENT)

Matriks pembagian tugas tim pengembangan aplikasi Sangkala.

---

## Anggota Tim & Pembagian Tugas

| No | Nama | NIM | Tanggung Jawab | Status |
|---|---|---|---|---|
| 1 | *(Anggota 1)* | *(NIM)* | **Backend / Auth / CRUD** — Supabase setup, skema DB, RLS, `SupabaseService`, Auth (login/register), CRUD Events | 🔄 In Progress |
| 2 | *(Anggota 2)* | *(NIM)* | **Komputasi Anggaran** — `BudgetScreen`, `BudgetItemsScreen`, kalkulator estimasi vs realisasi | 📋 To Do |
| 3 | *(Anggota 3)* | *(NIM)* | **Konversi Kalender** — `HijriAgeScreen` (konversi Hijriah + hitung umur), `WetonScreen` (Weton Jawa & Saka Bali) | 📋 To Do |
| 4 | *(Anggota 4)* | *(NIM)* | **Stopwatch / Help / UI Polish** — `StopwatchScreen`, `HelpScreen`, `MainScaffold` (BottomNav), `HomeScreen`, tema & styling | 📋 To Do |

---

## Detail Tugas per Anggota

### Anggota 1 — Backend / Auth / CRUD

| Tugas | File | Status |
|---|---|---|
| Setup Supabase project & skema tabel | Supabase Dashboard | ✅ Done |
| Konfigurasi RLS semua tabel | Supabase Dashboard | ✅ Done |
| Model data Dart | `lib/models/*.dart` | ✅ Done |
| `SupabaseService` singleton | `lib/core/services/supabase_service.dart` | ✅ Done |
| `LoginScreen` | `lib/screens/auth/login_screen.dart` | 📋 To Do |
| `RegisterScreen` | `lib/screens/auth/register_screen.dart` | 📋 To Do |
| `EventsScreen` (list + delete) | `lib/screens/events/events_screen.dart` | 📋 To Do |
| `EventFormScreen` (add/edit) | `lib/screens/events/event_form_screen.dart` | 📋 To Do |
| `MembersScreen` | `lib/screens/members/members_screen.dart` | 📋 To Do |
| Dokumentasi backend | `DOCS_BACKEND.md` | ✅ Done |

---

### Anggota 2 — Komputasi Anggaran

| Tugas | File | Status |
|---|---|---|
| Halaman perantara "Pilih Event" untuk budget | `lib/screens/computations/budget_event_picker_screen.dart` | 📋 To Do |
| `BudgetItemsScreen` (CRUD item + summary) | `lib/screens/computations/budget_items_screen.dart` | 📋 To Do |
| Kalkulasi total estimasi vs realisasi | Logic di `BudgetItemsScreen` | 📋 To Do |
| Dialog add/edit budget item | Widget di `BudgetItemsScreen` | 📋 To Do |

---

### Anggota 3 — Konversi Kalender

| Tugas | File | Status |
|---|---|---|
| `HijriAgeScreen` — konversi tanggal Masehi → Hijriah | `lib/screens/conversions/hijri_age_screen.dart` | 📋 To Do |
| `HijriAgeScreen` — hitung umur (tahun, bulan, hari, jam, menit, detik) | `lib/screens/conversions/hijri_age_screen.dart` | 📋 To Do |
| `WetonScreen` — Weton Jawa (hari pasaran + neptu) | `lib/screens/conversions/weton_screen.dart` | 📋 To Do |
| `WetonScreen` — Saka Bali (tahun Saka + Sasih + Wuku) | `lib/screens/conversions/weton_screen.dart` | 📋 To Do |
| Tambah package `hijri` ke pubspec | `pubspec.yaml` | ✅ Done |

---

### Anggota 4 — Stopwatch / Help / UI

| Tugas | File | Status |
|---|---|---|
| `MainScaffold` (BottomNavigationBar 3 tab) | `lib/widgets/main_scaffold.dart` | 📋 To Do |
| `HomeScreen` (5 menu vertikal) | `lib/screens/home/home_screen.dart` | 📋 To Do |
| `StopwatchScreen` (start/pause/reset/lap) | `lib/screens/stopwatch/stopwatch_screen.dart` | 📋 To Do |
| `HelpScreen` (panduan + tombol logout) | `lib/screens/help/help_screen.dart` | 📋 To Do |
| `AuthGate` + `main.dart` entry point | `lib/main.dart` | 📋 To Do |
| `AppTheme` Material 3 | `lib/core/theme/app_theme.dart` | ✅ Done |

---

## Legenda Status

| Simbol | Arti |
|---|---|
| ✅ Done | Selesai dan siap digunakan |
| 🔄 In Progress | Sedang dikerjakan |
| 📋 To Do | Belum dimulai |
| ⚠️ Blocked | Menunggu dependensi lain |

---

## Catatan Kolaborasi

- Setiap anggota bekerja di **branch terpisah**: `feat/auth`, `feat/budget`, `feat/konversi`, `feat/ui`
- Merge ke `main` setelah fitur selesai dan tidak ada error linter
- Gunakan `SETUP_ENV.md` untuk onboarding awal
- Lihat `DOCS_BACKEND.md` untuk referensi API `SupabaseService`
