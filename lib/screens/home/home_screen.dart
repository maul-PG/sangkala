import 'package:flutter/material.dart';
import '../computations/budget_event_picker_screen.dart';
import '../conversions/hijri_age_screen.dart';
import '../conversions/weton_screen.dart';
import '../events/events_screen.dart';
import '../members/members_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _menus = [
    _MenuItem(
      icon: Icons.group_outlined,
      title: 'Daftar Anggota',
      subtitle: 'Lihat data tim pengembang',
    ),
    _MenuItem(
      icon: Icons.calculate_outlined,
      title: 'Kalkulator Anggaran',
      subtitle: 'Komputasi estimasi & realisasi acara',
    ),
    _MenuItem(
      icon: Icons.event_outlined,
      title: 'Kelola Kegiatan',
      subtitle: 'CRUD kegiatan kampus',
    ),
    _MenuItem(
      icon: Icons.calendar_month_outlined,
      title: 'Konversi Hijriah & Umur',
      subtitle: 'Konversi tanggal & hitung umur lengkap',
    ),
    _MenuItem(
      icon: Icons.auto_stories_outlined,
      title: 'Kalender Tradisional',
      subtitle: 'Weton Jawa & Saka Bali',
    ),
  ];

  void _navigate(BuildContext context, int index) {
    final destinations = [
      const MembersScreen(),
      const BudgetEventPickerScreen(),
      const EventsScreen(),
      const HijriAgeScreen(),
      const WetonScreen(),
    ];
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destinations[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sangkala'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _menus.length,
        separatorBuilder: (context, i) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final menu = _menus[i];
          return Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: Icon(menu.icon,
                    color: Theme.of(context).colorScheme.primary),
              ),
              title: Text(menu.title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(menu.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _navigate(context, i),
            ),
          );
        },
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
