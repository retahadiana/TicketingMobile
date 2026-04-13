import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_controller.dart';
import 'ticket_detail_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    final notifications = controller.myNotifications;

    if (notifications.isEmpty) {
      return const Center(child: Text('Belum ada notifikasi.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final n = notifications[index];
        return Card(
          color: n.isRead ? null : Theme.of(context).colorScheme.primaryContainer,
          child: ListTile(
            title: Text(n.title),
            subtitle: Text(n.message),
            trailing: Text(
              '${n.createdAt.hour.toString().padLeft(2, '0')}:${n.createdAt.minute.toString().padLeft(2, '0')}',
            ),
            onTap: () {
              ref.read(appControllerProvider).markNotificationRead(n.id);
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => TicketDetailScreen(ticketId: n.ticketId),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
