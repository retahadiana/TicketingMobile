import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_controller.dart';
import '../../../models/ticket_model.dart';
import 'ticket_detail_screen.dart';

class TicketListScreen extends ConsumerWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    final tickets = controller.visibleTickets;

    if (tickets.isEmpty) {
      return const Center(
        child: Text('Belum ada tiket. Buat tiket pertama Anda dari tombol Create Ticket.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(ticket.status.label.characters.first),
            ),
            title: Text(ticket.title),
            subtitle: Text(
              '${ticket.userName} • ${ticket.status.label} • ${ticket.comments.length} komentar',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => TicketDetailScreen(ticketId: ticket.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
