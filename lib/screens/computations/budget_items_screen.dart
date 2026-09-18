import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/supabase_service.dart';
import '../../models/event.dart';
import '../../models/event_budget.dart';

class BudgetItemsScreen extends StatefulWidget {
  const BudgetItemsScreen({super.key, required this.event});
  final Event event;

  @override
  State<BudgetItemsScreen> createState() => _BudgetItemsScreenState();
}

class _BudgetItemsScreenState extends State<BudgetItemsScreen> {
  late Future<List<EventBudget>> _future;
  final _currencyFmt =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _future = SupabaseService.instance.getBudgets(widget.event.id);
  }

  void _load() {
    setState(() {
      _future = SupabaseService.instance.getBudgets(widget.event.id);
    });
  }

  Future<void> _showBudgetDialog({EventBudget? budget}) async {
    final nameCtrl =
        TextEditingController(text: budget?.itemName ?? '');
    final qtyCtrl = TextEditingController(
        text: budget != null ? budget.quantity.toString() : '1');
    final estCtrl = TextEditingController(
        text: budget != null ? budget.estimatedCost.toStringAsFixed(0) : '');
    final actCtrl = TextEditingController(
        text: budget != null ? budget.actualCost.toStringAsFixed(0) : '');
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(budget == null ? 'Tambah Item Anggaran' : 'Edit Item Anggaran'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nama Item',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama item wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah (Qty)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return (n == null || n < 1) ? 'Qty minimal 1' : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: estCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Estimasi Biaya (per unit)',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    return (n == null || n < 0) ? 'Masukkan angka valid' : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: actCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Realisasi Biaya (per unit)',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    return (n == null || n < 0) ? 'Masukkan angka valid' : null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('Simpan')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final svc = SupabaseService.instance;
      if (budget == null) {
        final now = DateTime.now();
        await svc.insertBudget(EventBudget(
          id: '',
          eventId: widget.event.id,
          itemName: nameCtrl.text.trim(),
          quantity: int.parse(qtyCtrl.text),
          estimatedCost: double.parse(estCtrl.text),
          actualCost: double.parse(actCtrl.text),
          createdAt: now,
        ));
      } else {
        await svc.updateBudget(budget.copyWith(
          itemName: nameCtrl.text.trim(),
          quantity: int.parse(qtyCtrl.text),
          estimatedCost: double.parse(estCtrl.text),
          actualCost: double.parse(actCtrl.text),
        ));
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    }
  }

  Future<void> _delete(EventBudget budget) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Item'),
        content: Text('Hapus "${budget.itemName}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await SupabaseService.instance.deleteBudget(budget.id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title, overflow: TextOverflow.ellipsis),
      ),
      body: FutureBuilder<List<EventBudget>>(
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
          final items = snapshot.data ?? [];
          final totalEst =
              items.fold(0.0, (sum, b) => sum + b.totalEstimated);
          final totalAct = items.fold(0.0, (sum, b) => sum + b.totalActual);
          final selisih = totalEst - totalAct;

          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _SummaryCard(
                    totalEst: totalEst,
                    totalAct: totalAct,
                    selisih: selisih,
                    fmt: _currencyFmt,
                  ),
                ),
                if (items.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Belum ada item anggaran.\nTekan + untuk menambahkan.',
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    sliver: SliverList.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, i) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) => _BudgetItemCard(
                        budget: items[i],
                        fmt: _currencyFmt,
                        onEdit: () => _showBudgetDialog(budget: items[i]),
                        onDelete: () => _delete(items[i]),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBudgetDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalEst,
    required this.totalAct,
    required this.selisih,
    required this.fmt,
  });
  final double totalEst;
  final double totalAct;
  final double selisih;
  final NumberFormat fmt;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: scheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ringkasan Anggaran',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer)),
              const SizedBox(height: 12),
              _SummaryRow(
                  label: 'Total Estimasi',
                  value: fmt.format(totalEst),
                  color: Colors.blue.shade700),
              const SizedBox(height: 6),
              _SummaryRow(
                  label: 'Total Realisasi',
                  value: fmt.format(totalAct),
                  color: Colors.orange.shade700),
              const Divider(height: 16),
              _SummaryRow(
                label: selisih >= 0 ? 'Sisa Anggaran' : 'Kelebihan',
                value: fmt.format(selisih.abs()),
                color: selisih >= 0
                    ? Colors.green.shade700
                    : Colors.red.shade700,
                bold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });
  final String label;
  final String value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                color: color,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }
}

class _BudgetItemCard extends StatelessWidget {
  const _BudgetItemCard({
    required this.budget,
    required this.fmt,
    required this.onEdit,
    required this.onDelete,
  });
  final EventBudget budget;
  final NumberFormat fmt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(budget.itemName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                ),
                Text('x${budget.quantity}',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estimasi',
                          style: TextStyle(
                              fontSize: 11, color: Colors.blue.shade700)),
                      Text(fmt.format(budget.totalEstimated),
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Realisasi',
                          style: TextStyle(
                              fontSize: 11, color: Colors.orange.shade700)),
                      Text(fmt.format(budget.totalActual),
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline,
                      size: 16, color: Colors.red),
                  label: const Text('Hapus',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
