import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/calendar_helper.dart';

class WetonScreen extends StatefulWidget {
  const WetonScreen({super.key});

  @override
  State<WetonScreen> createState() => _WetonScreenState();
}

class _WetonScreenState extends State<WetonScreen> {
  DateTime _selected = DateTime.now();
  _WetonResult? _result;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (picked != null) {
      setState(() {
        _selected = picked;
        _result = null;
      });
    }
  }

  void _calculate() {
    _result = _WetonResult.from(_selected);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd MMMM yyyy', 'id_ID').format(_selected);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Tradisional'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Tanggal Masehi'),
                subtitle: Text(dateLabel),
                trailing: TextButton(
                  onPressed: _pickDate,
                  child: const Text('Ubah'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Hitung'),
            ),
            if (_result != null) ...[
              const SizedBox(height: 20),
              _WetonCard(result: _result!),
              const SizedBox(height: 12),
              _SakaCard(result: _result!),
            ],
          ],
        ),
      ),
    );
  }
}

class _WetonResult {
  final String hariNasional;
  final int neptWHari;
  final String hariPasaran;
  final int neptWPasaran;
  final int totalNeptu;
  final int tahunSaka;
  final String namaSasih;
  final String namaWuku;

  const _WetonResult({
    required this.hariNasional,
    required this.neptWHari,
    required this.hariPasaran,
    required this.neptWPasaran,
    required this.totalNeptu,
    required this.tahunSaka,
    required this.namaSasih,
    required this.namaWuku,
  });

  factory _WetonResult.from(DateTime date) {
    // ── Weton Jawa ──────────────────────────────────────────────────────────
    final weton = CalendarHelper.convertToWeton(date);
    final hariNasional = weton['hari'] as String;
    final neptWHari = weton['neptuHari'] as int;
    final hariPasaran = weton['pasaran'] as String;
    final neptWPasaran = weton['neptuPasaran'] as int;

    // ── Saka Bali ───────────────────────────────────────────────────────────
    final tahunSaka = CalendarHelper.convertToSakaYear(date);
    final namaSasih = CalendarHelper.convertToSasih(date);
    final namaWuku = CalendarHelper.convertToWuku(date);

    return _WetonResult(
      hariNasional: hariNasional,
      neptWHari: neptWHari,
      hariPasaran: hariPasaran,
      neptWPasaran: neptWPasaran,
      totalNeptu: neptWHari + neptWPasaran,
      tahunSaka: tahunSaka,
      namaSasih: namaSasih,
      namaWuku: namaWuku,
    );
  }
}

class _WetonCard extends StatelessWidget {
  const _WetonCard({required this.result});
  final _WetonResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_stories_outlined, color: scheme.primary),
                const SizedBox(width: 8),
                Text('Weton Jawa',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                        fontSize: 16)),
              ],
            ),
            const Divider(height: 20),
            _InfoRow(
              label: 'Hari',
              value: result.hariNasional,
              badge: 'Neptu ${result.neptWHari}',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Hari Pasaran',
              value: result.hariPasaran,
              badge: 'Neptu ${result.neptWPasaran}',
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Weton',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '${result.hariNasional} ${result.hariPasaran}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: scheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Neptu',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${result.totalNeptu}',
                    style: TextStyle(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SakaCard extends StatelessWidget {
  const _SakaCard({required this.result});
  final _WetonResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.temple_hindu_outlined, color: scheme.tertiary),
                const SizedBox(width: 8),
                Text('Kalender Saka Bali',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.tertiary,
                        fontSize: 16)),
              ],
            ),
            const Divider(height: 20),
            _InfoRow(
                label: 'Tahun Saka', value: '${result.tahunSaka} Saka'),
            const SizedBox(height: 8),
            _InfoRow(label: 'Sasih (Bulan)', value: result.namaSasih),
            const SizedBox(height: 8),
            _InfoRow(label: 'Wuku', value: result.namaWuku),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.badge});
  final String label;
  final String value;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Row(
          children: [
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(badge!,
                    style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer)),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
