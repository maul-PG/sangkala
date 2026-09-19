import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _sw = Stopwatch();
  Timer? _timer;
  final List<Duration> _laps = [];
  Duration _initialDuration = Duration.zero;

  void _startPause() {
    if (_sw.isRunning) {
      _sw.stop();
      _timer?.cancel();
    } else {
      _sw.start();
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (mounted) setState(() {});
      });
    }
    if (mounted) setState(() {});
  }

  void _reset() {
    _sw.stop();
    _sw.reset();
    _timer?.cancel();
    _laps.clear();
    // Keep _initialDuration
    if (mounted) setState(() {});
  }

  void _showTimeInput() async {
    final result = await showDialog<Duration>(
      context: context,
      builder: (ctx) => SetInitialTimeDialog(
        initialHours: _initialDuration.inHours,
        initialMinutes: (_initialDuration.inMinutes % 60),
        initialSeconds: (_initialDuration.inSeconds % 60),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _initialDuration = result;
        _sw.stop();
        _sw.reset();
        _timer?.cancel();
        _laps.clear();
      });
    }
  }

  void _lap() {
    if (!_sw.isRunning) return;
    _laps.insert(0, _sw.elapsed);
    if (mounted) setState(() {});
  }

  String _format(Duration d) {
    final hours = d.inHours;
    final minutes = (d.inMinutes % 60);
    final seconds = (d.inSeconds % 60);
    final ms = (d.inMilliseconds % 1000) ~/ 10;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${ms.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = _sw.isRunning;
    final elapsed = _sw.elapsed;
    final total = _initialDuration + elapsed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time_outlined),
            onPressed: _showTimeInput,
            tooltip: 'Set Waktu Awal',
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              _format(total),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontWeight: FontWeight.w300,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              _initialDuration > Duration.zero
                  ? 'Waktu Awal: ${_format(_initialDuration)}'
                  : 'Waktu Awal: 00:00:00',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _sw.elapsed == Duration.zero && _laps.isEmpty ? null : _reset,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Reset'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: _startPause,
                  icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(isRunning ? 'Pause' : 'Mulai'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: isRunning ? _lap : null,
                  icon: const Icon(Icons.timer_outlined),
                  label: const Text('Lap'),
                ),
              ],
            ),
            if (_laps.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _laps.length,
                  itemBuilder: (context, i) => ListTile(
                    dense: true,
                    leading: Text(
                      'Lap ${_laps.length - i}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(_format(_laps[i])),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SetInitialTimeDialog extends StatefulWidget {
  final int initialHours;
  final int initialMinutes;
  final int initialSeconds;

  const SetInitialTimeDialog({
    super.key,
    required this.initialHours,
    required this.initialMinutes,
    required this.initialSeconds,
  });

  @override
  State<SetInitialTimeDialog> createState() => _SetInitialTimeDialogState();
}

class _SetInitialTimeDialogState extends State<SetInitialTimeDialog> {
  late int _hours;
  late int _minutes;
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialHours;
    _minutes = widget.initialMinutes;
    _seconds = widget.initialSeconds;
  }

  Widget _buildTimeColumn(String label, int value, int maxValue, void Function(int) onChange) {
    return SizedBox(
      width: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          IconButton(
            onPressed: value < maxValue ? () => onChange(value + 1) : null,
            icon: const Icon(Icons.keyboard_arrow_up),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          IconButton(
            onPressed: value > 0 ? () => onChange(value - 1) : null,
            icon: const Icon(Icons.keyboard_arrow_down),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Set Waktu Awal'),
      content: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimeColumn('Jam', _hours, 23, (v) => setState(() => _hours = v)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            _buildTimeColumn('Menit', _minutes, 59, (v) => setState(() => _minutes = v)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            _buildTimeColumn('Detik', _seconds, 59, (v) => setState(() => _seconds = v)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              Duration(hours: _hours, minutes: _minutes, seconds: _seconds),
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
