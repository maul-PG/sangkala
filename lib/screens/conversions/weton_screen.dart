import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    setState(() => _result = _WetonResult.from(_selected));
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        DateFormat('dd MMMM yyyy', 'id_ID').format(_selected);

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

// ── Algoritma ──────────────────────────────────────────────────────────────

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
    const namaHari = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    const neptHari = [4, 3, 7, 8, 6, 9, 5]; // index sesuai weekday 1–7

    const namaPasaran = ['Legi', 'Pahing', 'Pon', 'Wage', 'Kliwon'];
    const neptPasaran = [5, 9, 7, 4, 8];

    // Epoch: Sabtu 1 Jan 2000 = Kliwon (index 4 dari namaPasaran)
    // Julian day number digunakan agar akurat lintas abad.
    final epochPasaran = DateTime(2000, 1, 1); // Kliwon → index 4
    const epochPasaranIndex = 4;
    final diffDays = date.difference(epochPasaran).inDays;
    final pasaranIndex =
        ((diffDays % 5) + epochPasaranIndex + 5 * 10) % 5;

    final hariIdx = date.weekday - 1; // weekday: Mon=1 → idx 0
    final hariNasional = namaHari[hariIdx];
    final nHari = neptHari[hariIdx];
    final hariPasaran = namaPasaran[pasaranIndex];
    final nPasaran = neptPasaran[pasaranIndex];

    // ── Saka Bali ───────────────────────────────────────────────────────────
    // Tahun Saka: Masehi - 78; kurangi 1 jika sebelum 22 Maret (awal tahun Saka)
    int tahunSaka = date.year - 78;
    if (date.month < 3 || (date.month == 3 && date.day < 22)) {
      tahunSaka--;
    }

    // Sasih (bulan Saka Bali): bulan 1 Sasih ≈ bulan 3 Masehi (Maret)
    // sasihIndex 0 = Kasa (Juli–Agst), urutan mengikuti kalender Bali umum
    const namaSasihList = [
      'Kasa', 'Karo', 'Katiga', 'Kapat', 'Kalima',
      'Kanem', 'Kapitu', 'Kawolu', 'Kasanga', 'Kadasa',
      'Jyestha', 'Saddha',
    ];
    // Bulan Masehi 7 (Juli) ≈ Sasih Kasa (0), offset = (bulan - 7 + 12) % 12
    final sasihIndex = (date.month - 7 + 12) % 12;
    final namaSasih = namaSasihList[sasihIndex];

    // Wuku: siklus 210 hari (30 wuku × 7 hari)
    // Epoch referensi: 6 Jan 2019 = awal Wuku Sinta (wuku ke-1, index 0)
    const namaWukuList = [
      'Sinta', 'Landep', 'Ukir', 'Kulantir', 'Tolu',
      'Gumbreg', 'Wariga', 'Warigadean', 'Julungwangi', 'Sungsang',
      'Dungulan', 'Kuningan', 'Langkir', 'Medangsia', 'Pujut',
      'Pahang', 'Krulut', 'Merakih', 'Tambir', 'Medangkungan',
      'Matal', 'Uye', 'Menail', 'Prangbakat', 'Bala',
      'Ugu', 'Wayang', 'Kelawu', 'Dukut', 'Watugunung',
    ];
    final epochWuku = DateTime(2019, 1, 6);
    final diffWuku = date.difference(epochWuku).inDays;
    final wukuIndex = ((diffWuku % 210) + 210 * 100) % 210 ~/ 7;
    final namaWuku = namaWukuList[wukuIndex % 30];

    return _WetonResult(
      hariNasional: hariNasional,
      neptWHari: nHari,
      hariPasaran: hariPasaran,
      neptWPasaran: nPasaran,
      totalNeptu: nHari + nPasaran,
      tahunSaka: tahunSaka,
      namaSasih: namaSasih,
      namaWuku: namaWuku,
    );
  }
}

// ── Result Cards ───────────────────────────────────────────────────────────

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
