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
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              ref.read(appControllerProvider).markNotificationRead(n.id);
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => TicketDetailScreen(ticketId: n.ticketId),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: n.isRead
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: n.isRead
                          ? Theme.of(context).colorScheme.outlineVariant
                          : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(n.title, style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text(n.message),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${n.createdAt.hour.toString().padLeft(2, '0')}:${n.createdAt.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
