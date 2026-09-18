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

  void _startPause() {
    if (_sw.isRunning) {
      _sw.stop();
      _timer?.cancel();
    } else {
      _sw.start();
      _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
        setState(() {});
      });
    }
    setState(() {});
  }

  void _reset() {
    _sw.stop();
    _sw.reset();
    _timer?.cancel();
    setState(() => _laps.clear());
  }

  void _lap() {
    if (!_sw.isRunning) return;
    setState(() => _laps.insert(0, _sw.elapsed));
  }

  String _format(Duration d) {
    final ms = d.inMilliseconds;
    final min = (ms ~/ 60000).toString().padLeft(2, '0');
    final sec = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
    final cent = ((ms % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$min:$sec.$cent';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = _sw.isRunning;
    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch'), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            _format(_sw.elapsed),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w300,
                ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: _sw.elapsed == Duration.zero ? null : _reset,
                child: const Text('Reset'),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: _startPause,
                child: Text(isRunning ? 'Pause' : 'Mulai'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: isRunning ? _lap : null,
                child: const Text('Lap'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_laps.isNotEmpty) ...[
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
    );
  }
}
