import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_controller.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(appControllerProvider).activityHistory;

    if (history.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Belum ada riwayat aktivitas.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat & Tracking Aktivitas')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return ListTile(
            leading: const Icon(Icons.timeline),
            title: Text(item.message),
            subtitle: Text('${item.actorName} • ${item.createdAt}'),
          );
        },
      ),
    );
  }
}
