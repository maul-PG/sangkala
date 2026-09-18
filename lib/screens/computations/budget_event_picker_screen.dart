import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/supabase_service.dart';
import '../../models/event.dart';
import 'budget_items_screen.dart';

class BudgetEventPickerScreen extends StatefulWidget {
  const BudgetEventPickerScreen({super.key});

  @override
  State<BudgetEventPickerScreen> createState() =>
      _BudgetEventPickerScreenState();
}

class _BudgetEventPickerScreenState extends State<BudgetEventPickerScreen> {
  late Future<List<Event>> _future;

  @override
  void initState() {
    super.initState();
    _future = SupabaseService.instance.getEvents();
  }

  void _load() {
    setState(() {
      _future = SupabaseService.instance.getEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kegiatan'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Event>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Gagal memuat: ${snapshot.error}',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                      onPressed: _load, child: const Text('Coba Lagi')),
                ],
              ),
            );
          }
          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_busy_outlined,
                      size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Belum ada kegiatan.\nTambahkan kegiatan terlebih dahulu.',
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: events.length,
              separatorBuilder: (context, i) => const SizedBox(height: 10),
              itemBuilder: (context, i) =>
                  _EventPickerCard(event: events[i]),
            ),
          );
        },
      ),
    );
  }
}

class _EventPickerCard extends StatelessWidget {
  const _EventPickerCard({required this.event});
  final Event event;

  Color _statusColor(String status) => switch (status) {
        'Planning' => Colors.orange,
        'Ongoing' => Colors.blue,
        'Completed' => Colors.green,
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('dd MMM yyyy', 'id_ID').format(event.eventDate);
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(Icons.event,
              color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(event.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Row(
          children: [
            Text(dateStr,
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(width: 8),
            Chip(
              label: Text(event.status,
                  style: const TextStyle(
                      fontSize: 10, color: Colors.white)),
              backgroundColor: _statusColor(event.status),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => BudgetItemsScreen(event: event)),
        ),
      ),
    );
  }
}
