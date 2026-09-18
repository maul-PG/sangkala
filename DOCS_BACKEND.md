# DOCS_BACKEND.md — Sangkala (SI-EVENT)

Dokumentasi backend Supabase untuk tim pengembang.

---

## Skema Database

### 1. `profiles`
Menyimpan metadata pengguna yang teregistrasi.

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | `uuid` | PK, referensi `auth.users.id` (on delete cascade) |
| `name` | `text` | Nama lengkap pengguna |
| `nim` | `text` | Nomor Induk Mahasiswa |
| `role` | `text` | Peran dalam kepanitiaan |
| `created_at` | `timestamptz` | Otomatis diisi Supabase |

**Catatan:** Insert dilakukan manual dari Flutter setelah `signUp` berhasil menggunakan `response.user!.id`.

---

### 2. `events`
Menyimpan data kegiatan/acara kampus.

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | `uuid` | PK, default `gen_random_uuid()` |
| `user_id` | `uuid` | FK ke `profiles.id` (pemilik event) |
| `title` | `text` | Judul acara |
| `description` | `text` | Deskripsi acara |
| `event_date` | `date` | Tanggal pelaksanaan |
| `location` | `text` | Lokasi acara |
| `status` | `text` | `'Planning'` \| `'Ongoing'` \| `'Completed'` |
| `created_at` | `timestamptz` | Otomatis diisi Supabase |

**Relasi:** Satu `profiles` → banyak `events`.

---

### 3. `event_budgets`
Menyimpan item anggaran per acara.

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | `uuid` | PK, default `gen_random_uuid()` |
| `event_id` | `uuid` | FK ke `events.id` (on delete cascade) |
| `item_name` | `text` | Nama item anggaran |
| `estimated_cost` | `numeric` | Estimasi biaya per unit |
| `actual_cost` | `numeric` | Realisasi biaya per unit |
| `quantity` | `int` | Jumlah unit |
| `created_at` | `timestamptz` | Otomatis diisi Supabase |

**Relasi:** Satu `events` → banyak `event_budgets` (cascade delete).

---

### 4. `team_members`
Menyimpan data anggota tim pengembang aplikasi (statis).

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | `serial` | PK, auto-increment |
| `nim` | `text` | NIM anggota |
| `name` | `text` | Nama lengkap |
| `role_in_app` | `text` | Peran dalam pengembangan aplikasi |
| `photo_url` | `text` | URL foto profil (nullable) |

---

## Row Level Security (RLS)

RLS **aktif** pada semua tabel. Kebijakan yang berlaku:

| Tabel | Policy | Kondisi |
|---|---|---|
| `profiles` | SELECT, UPDATE | `auth.uid() = id` |
| `events` | SELECT, INSERT, UPDATE, DELETE | `auth.uid() = user_id` |
| `event_budgets` | SELECT, INSERT, UPDATE, DELETE | Via join ke `events` (`user_id = auth.uid()`) |
| `team_members` | SELECT | Semua user terotentikasi (read-only) |

**Penting:** Setiap `INSERT` ke tabel `events` **wajib** menyertakan `user_id: supabase.auth.currentUser!.id`.

---

## SupabaseService API Reference

File: `lib/core/services/supabase_service.dart`

```dart
// Singleton accessor
final svc = SupabaseService.instance;
```

### Auth

```dart
// Register + insert profil manual
await svc.signUp(
  email: 'user@email.com',
  password: 'secret',
  name: 'Budi Santoso',
  nim: '12345678',
  role: 'Ketua Panitia',
);

// Login
await svc.signIn(email: 'user@email.com', password: 'secret');

// Logout
await svc.signOut();

// Cek user aktif
final user = svc.currentUser; // nullable
```

### Events

```dart
// Ambil semua event milik user yang login
final List<Event> events = await svc.getEvents();

// Tambah event baru (user_id otomatis dari currentUser)
await svc.insertEvent(event);

// Update event
await svc.updateEvent(event);

// Hapus event
await svc.deleteEvent(eventId);
```

### Event Budgets

```dart
// Ambil semua budget item milik sebuah event
final List<EventBudget> items = await svc.getBudgets(eventId);

// Tambah item anggaran
await svc.insertBudget(budget);

// Update item anggaran
await svc.updateBudget(budget);

// Hapus item anggaran
await svc.deleteBudget(budgetId);
```

### Team Members

```dart
// Ambil semua anggota tim (read-only)
final List<TeamMember> members = await svc.getTeamMembers();
```

---

## Koneksi Supabase

Konfigurasi ada di `lib/main.dart`:

```dart
await Supabase.initialize(
  url: 'https://twbzzzpawrvhxagyzmbh.supabase.co',
  anonKey: '<anon_key>',
);
```

Nilai lengkap `anonKey` lihat di `SETUP_ENV.md`.
