import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _guides = [
    _GuideItem(
      icon: Icons.person_outline,
      title: 'Akun & Profil',
      steps: [
        'Daftar akun dengan email, password, nama, NIM, dan peran kepanitiaan.',
        'Login menggunakan email dan password yang sudah terdaftar.',
        'Logout tersedia di bagian bawah halaman Bantuan ini.',
        'Data profil (nama, NIM, peran) disimpan otomatis setelah registrasi.',
      ],
    ),
    _GuideItem(
      icon: Icons.event_outlined,
      title: 'Manajemen Event (CRUD)',
      steps: [
        'Buka menu "Kelola Kegiatan" dari halaman utama.',
        'Tekan tombol + untuk menambahkan kegiatan baru.',
        'Isi judul, deskripsi, lokasi, tanggal, dan status kegiatan.',
        'Tekan "Edit" pada kartu event untuk mengubah data.',
        'Tekan "Hapus" dan konfirmasi untuk menghapus kegiatan beserta anggarannya.',
        'Tarik layar ke bawah (pull-to-refresh) untuk memperbarui daftar.',
      ],
    ),
    _GuideItem(
      icon: Icons.calculate_outlined,
      title: 'Anggaran Acara',
      steps: [
        'Buka menu "Kalkulator Anggaran" dari halaman utama.',
        'Pilih salah satu kegiatan dari daftar.',
        'Ringkasan total estimasi vs realisasi ditampilkan di bagian atas.',
        'Tekan + untuk menambahkan item anggaran baru.',
        'Isi nama item, jumlah (qty), estimasi biaya, dan realisasi biaya per unit.',
        'Total dihitung otomatis: estimasi × qty dan realisasi × qty.',
        'Selisih positif berarti masih ada sisa anggaran; negatif berarti kelebihan.',
      ],
    ),
    _GuideItem(
      icon: Icons.calendar_month_outlined,
      title: 'Konversi Kalender',
      steps: [
        'Buka menu "Konversi Hijriah & Umur" untuk dua fitur sekaligus.',
        'Tab Konversi Hijriah: pilih tanggal Masehi, tekan "Konversi" untuk mendapatkan tanggal Hijriah lengkap.',
        'Tab Hitung Umur: pilih tanggal lahir, tekan "Hitung Umur" untuk melihat umur real-time (tahun, bulan, hari, jam, menit, detik).',
        'Buka menu "Kalender Tradisional" untuk Weton Jawa & Saka Bali.',
        'Pilih tanggal, tekan "Hitung" untuk melihat hari pasaran, neptu, total neptu, tahun Saka, Sasih, dan Wuku.',
      ],
    ),
    _GuideItem(
      icon: Icons.timer_outlined,
      title: 'Stopwatch',
      steps: [
        'Buka tab Stopwatch dari navigasi bawah.',
        'Tekan "Mulai" untuk memulai pencatatan waktu.',
        'Tekan "Lap" untuk mencatat waktu putaran saat stopwatch berjalan.',
        'Tekan "Pause" untuk menjeda, lanjutkan dengan "Mulai" kembali.',
        'Tekan "Reset" untuk mereset waktu dan menghapus semua data lap.',
      ],
    ),
  ];

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await SupabaseService.instance.signOut();
    // AuthGate (StreamBuilder di main.dart) mendeteksi signOut
    // dan otomatis redirect ke LoginScreen.
  }

  @override
  Widget build(BuildContext context) {
    final email =
        SupabaseService.instance.currentUser?.email ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Info akun aktif
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primary,
                child: Icon(Icons.person,
                    color:
                        Theme.of(context).colorScheme.onPrimary),
              ),
              title: const Text('Akun Aktif',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(email),
            ),
          ),
          const SizedBox(height: 16),
          Text('Panduan Penggunaan',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Panduan per fitur
          ..._guides.map((g) => _GuideTile(item: g)),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Tombol logout
          FilledButton.tonal(
            onPressed: () => _logout(context),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout),
                SizedBox(width: 8),
                Text('Keluar dari Akun',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideTile extends StatelessWidget {
  const _GuideTile({required this.item});
  final _GuideItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(item.icon,
            color: Theme.of(context).colorScheme.primary),
        title: Text(item.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        childrenPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: item.steps
            .asMap()
            .entries
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${e.key + 1}. ',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                              fontWeight: FontWeight.bold)),
                      Expanded(child: Text(e.value)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _GuideItem {
  final IconData icon;
  final String title;
  final List<String> steps;
  const _GuideItem(
      {required this.icon, required this.title, required this.steps});
}
