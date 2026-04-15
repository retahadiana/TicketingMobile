import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_controller.dart';
import '../../../core/permissions.dart';
import '../../../models/profile_model.dart';
import '../../../models/ticket_model.dart';
import 'create_ticket_screen.dart';
import 'history_screen.dart';
import 'ticket_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    final stats = controller.dashboardStats;
    final tickets = controller.visibleTickets;
    final user = controller.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: <Color>[
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Halo, ${user.fullName}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text('Role aktif: ${user.role.value}'),
                const SizedBox(height: 2),
                Text('Pantau ringkasan performa tiket helpdesk Anda hari ini.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text('Ringkasan Tiket', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        _StatsGrid(stats: stats, total: tickets.length),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
                  );
                },
                icon: const Icon(Icons.timeline),
                label: const Text('Riwayat'),
              ),
            ),
            const SizedBox(width: 8),
            if (PermissionGuard.hasPermission(user.role, AppPermission.createTicket))
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (_) => const CreateTicketScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Create Ticket'),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Tiket Terbaru', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (tickets.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Belum ada tiket aktif.'),
            ),
          )
        else
          ...tickets.take(5).map(
                (ticket) => Card(
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
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.confirmation_number),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(ticket.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text('${ticket.status.label} • ${ticket.userName}'),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<TicketStatus, int> stats;
  final int total;

  const _StatsGrid({required this.stats, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _StatCard(
              title: 'Open',
              value: stats[TicketStatus.open] ?? 0,
              color: const Color(0xFF005F73),
            ),
            const SizedBox(width: 10),
            _StatCard(
              title: 'In Progress',
              value: stats[TicketStatus.inProgress] ?? 0,
              color: const Color(0xFFCA6702),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            _StatCard(
              title: 'Resolved',
              value: stats[TicketStatus.resolved] ?? 0,
              color: const Color(0xFF0A9396),
            ),
            const SizedBox(width: 10),
            _StatCard(
              title: 'Closed',
              value: stats[TicketStatus.closed] ?? 0,
              color: const Color(0xFF6C757D),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.summarize),
            title: const Text('Total tiket'),
            trailing: Text(
              '$total',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title),
              const SizedBox(height: 8),
              Text(
                '$value',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
