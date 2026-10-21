
import 'package:flutter/material.dart';

import '../models/calculation_history_item.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.service,
    required this.onSelect,
  });

  final HistoryService service;
  final ValueChanged<CalculationHistoryItem> onSelect;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<CalculationHistoryItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await widget.service.loadHistory();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text(
          'This permanently removes saved calculations from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await widget.service.clearHistory();
    if (!mounted) return;
    setState(() => _items = []);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CalculatorColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculation history'),
        actions: [
          IconButton(
            tooltip: 'Clear history',
            onPressed: _items.isEmpty ? null : _clear,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 56,
                          color: colors.secondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No calculations yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your successful calculations will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.secondary),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      title: Text(
                        item.result,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${item.expression}\n'
                        '${item.timestamp.toLocal()}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.arrow_upward),
                      onTap: () => widget.onSelect(item),
                    );
                  },
                ),
    );
  }
}
