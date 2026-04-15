import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_controller.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  String _formatDate(DateTime raw) {
    final dt = raw.toLocal();
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(appControllerProvider).activityHistory;

    final colorScheme = Theme.of(context).colorScheme;

    if (history.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat & Tracking Aktivitas')),
        body: Center(
          child: Card(
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.history_toggle_off, size: 34),
                  SizedBox(height: 8),
                  Text('Belum ada riwayat aktivitas.'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat & Tracking Aktivitas')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 220 + (index * 45)),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(offset: Offset(0, (1 - value) * 8), child: child),
            ),
            child: Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.timeline, color: colorScheme.onPrimaryContainer),
                ),
                title: Text(item.message),
                subtitle: Text('${item.actorName} • ${_formatDate(item.createdAt)}'),
              ),
            ),
          );
        },
      ),
    );
  }
}
