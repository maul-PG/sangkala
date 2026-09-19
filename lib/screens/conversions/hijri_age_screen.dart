import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/calendar_helper.dart';

class HijriAgeScreen extends StatefulWidget {
  const HijriAgeScreen({super.key});

  @override
  State<HijriAgeScreen> createState() => _HijriAgeScreenState();
}

class _HijriAgeScreenState extends State<HijriAgeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Hijriah & Umur'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('Konversi Hijriah'),
                  icon: Icon(Icons.calendar_month_outlined),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Hitung Umur'),
                  icon: Icon(Icons.cake_outlined),
                ),
              ],
              selected: {_tabIndex},
              onSelectionChanged: (s) =>
                  setState(() => _tabIndex = s.first),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: const [
                _HijriConversionTab(),
                _AgeCalculatorTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab 1: Konversi Hijriah ────────────────────────────────────────────────

class _HijriConversionTab extends StatefulWidget {
  const _HijriConversionTab();

  @override
  State<_HijriConversionTab> createState() => _HijriConversionTabState();
}

class _HijriConversionTabState extends State<_HijriConversionTab> {
  DateTime _selected = DateTime.now();
  Map<String, dynamic>? _result;

  static const _dayNames = [
    '', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  @override
  void initState() {
    super.initState();
    _convert();
  }

  void _convert() {
    _result = CalendarHelper.convertToHijri(_selected);
    setState(() {});
  }

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

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        DateFormat('dd MMMM yyyy', 'id_ID').format(_selected);
    final dayName = _dayNames[_selected.weekday];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Tanggal Masehi'),
              subtitle: Text('$dayName, $dateLabel'),
              trailing: TextButton(
                onPressed: _pickDate,
                child: const Text('Ubah'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _convert,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Konversi ke Hijriah'),
          ),
           if (_result != null) ...[
             const SizedBox(height: 20),
             _ResultCard(
               title: 'Hasil Konversi Hijriah',
               icon: Icons.mosque_outlined,
               rows: [
                 _Row('Hari', dayName),
                 _Row('Tanggal', '${_result!['day']}'),
                 _Row('Bulan Hijriah', _result!['monthName']),
                 _Row('Tahun Hijriah', '${_result!['year']} H'),
                 _Row('Format Singkat', '${_result!['day']}/${_result!['month']}/${_result!['year']}'),
               ],
             ),
           ],
        ],
      ),
    );
  }
}

// ── Tab 2: Hitung Umur ────────────────────────────────────────────────────

class _AgeCalculatorTab extends StatefulWidget {
  const _AgeCalculatorTab();

  @override
  State<_AgeCalculatorTab> createState() => _AgeCalculatorTabState();
}

class _AgeCalculatorTabState extends State<_AgeCalculatorTab> {
  DateTime _birthDate = DateTime(2000, 1, 1);
  bool _calculating = false;
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _stopCalculating();
      });
    }
  }

  void _startCalculating() {
    setState(() {
      _calculating = true;
      _elapsed = DateTime.now().difference(_birthDate);
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed = DateTime.now().difference(_birthDate));
    });
  }

  void _stopCalculating() {
    _ticker?.cancel();
    _ticker = null;
    _calculating = false;
    _elapsed = Duration.zero;
  }

  /// Hitung komponen umur (tahun, bulan, hari) secara kalender.
  ({int years, int months, int days}) _calendarAge() {
    final now = DateTime.now();
    int years = now.year - _birthDate.year;
    int months = now.month - _birthDate.month;
    int days = now.day - _birthDate.day;

    if (days < 0) {
      months--;
      final prevMonth = DateTime(now.year, now.month, 0);
      days += prevMonth.day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }
    return (years: years, months: months, days: days);
  }

  @override
  Widget build(BuildContext context) {
    final birthLabel =
        DateFormat('dd MMMM yyyy', 'id_ID').format(_birthDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.cake_outlined),
              title: const Text('Tanggal Lahir'),
              subtitle: Text(birthLabel),
              trailing: TextButton(
                onPressed: _pickDate,
                child: const Text('Ubah'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _calculating
              ? OutlinedButton.icon(
                  onPressed: () => setState(() => _stopCalculating()),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                )
              : FilledButton.icon(
                  onPressed: _startCalculating,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Hitung Umur'),
                ),
          if (_calculating) ...[
            const SizedBox(height: 20),
            Builder(builder: (context) {
              final age = _calendarAge();
              final totalSeconds = _elapsed.inSeconds;
              final jam = totalSeconds ~/ 3600;
              final menit = (totalSeconds % 3600) ~/ 60;
              final detik = totalSeconds % 60;
              return _ResultCard(
                title: 'Umur Saat Ini',
                icon: Icons.hourglass_bottom_outlined,
                rows: [
                  _Row('Tahun', '${age.years} tahun'),
                  _Row('Bulan', '${age.months} bulan'),
                  _Row('Hari', '${age.days} hari'),
                  _Row('Jam', '$jam jam'),
                  _Row('Menit', '$menit menit'),
                  _Row('Detik', '$detik detik',
                      highlight: true),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.title,
    required this.icon,
    required this.rows,
  });
  final String title;
  final IconData icon;
  final List<_Row> rows;

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
                Icon(icon, color: scheme.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary)),
              ],
            ),
            const Divider(height: 20),
            ...rows.map((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r.label,
                          style: const TextStyle(color: Colors.grey)),
                      Text(r.value,
                          style: TextStyle(
                              fontWeight: r.highlight
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: r.highlight ? 18 : 14,
                              color: r.highlight
                                  ? Theme.of(context).colorScheme.primary
                                  : null)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _Row {
  final String label;
  final String value;
  final bool highlight;
  const _Row(this.label, this.value, {this.highlight = false});
}
