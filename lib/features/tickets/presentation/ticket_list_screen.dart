import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_controller.dart';
import '../../../models/ticket_model.dart';
import 'ticket_detail_screen.dart';

class TicketListScreen extends ConsumerWidget {
  const TicketListScreen({super.key});

  Color _statusColor(BuildContext context, TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return const Color(0xFF0F766E);
      case TicketStatus.inProgress:
        return const Color(0xFFEA580C);
      case TicketStatus.resolved:
        return const Color(0xFF16A34A);
      case TicketStatus.closed:
        return Theme.of(context).colorScheme.outline;
    }
  }

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
        final color = _statusColor(context, ticket.status);

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => TicketDetailScreen(ticketId: ticket.id),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ticket.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _MetaPill(label: ticket.status.label, color: color),
                      _MetaPill(label: ticket.userName),
                      _MetaPill(label: '${ticket.comments.length} komentar'),
                    ],
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

class _MetaPill extends StatelessWidget {
  final String label;
  final Color? color;

  const _MetaPill({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? Theme.of(context).colorScheme.outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: resolvedColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: resolvedColor, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
