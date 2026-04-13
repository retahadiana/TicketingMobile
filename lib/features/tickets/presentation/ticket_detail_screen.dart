import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_controller.dart';
import '../../../core/permissions.dart';
import '../../../models/ticket_model.dart';
import '../../../models/profile_model.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final _assignedController = TextEditingController();
  final _commentController = TextEditingController();
  TicketStatus? _selectedStatus;
  bool _isBusy = false;

  bool _isSupport(Profile? profile) {
    if (profile == null) {
      return false;
    }
    return PermissionGuard.hasPermission(
      profile.role,
      AppPermission.updateTicketStatus,
    );
  }

  @override
  void initState() {
    super.initState();
    final ticket = ref.read(appControllerProvider).getTicketById(widget.ticketId);
    if (ticket != null) {
      _selectedStatus = ticket.status;
      _assignedController.text = ticket.assignedTo ?? '';
    }
  }

  Future<void> _submitComment() async {
    final message = _commentController.text.trim();
    if (message.isEmpty) {
      return;
    }

    setState(() => _isBusy = true);
    await ref
        .read(appControllerProvider)
        .addComment(ticketId: widget.ticketId, message: message);
    _commentController.clear();
    if (mounted) {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _saveSupportUpdate() async {
    final selectedStatus = _selectedStatus;
    if (selectedStatus == null) {
      return;
    }

    setState(() => _isBusy = true);

    await ref.read(appControllerProvider).updateTicketStatus(
          ticketId: widget.ticketId,
          newStatus: selectedStatus,
        );

    final assignee = _assignedController.text.trim();
    if (assignee.isNotEmpty) {
      await ref
          .read(appControllerProvider)
          .assignTicket(ticketId: widget.ticketId, assigneeName: assignee);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan tiket berhasil disimpan.')),
      );
      setState(() => _isBusy = false);
    }
  }

  Future<void> _setStatus(TicketStatus status) async {
    setState(() => _selectedStatus = status);
    await _saveSupportUpdate();
  }

  Widget _buildStatusStep(
    BuildContext context,
    TicketStatus status,
    int currentStatusIndex,
    bool canEdit,
    VoidCallback? onTap,
  ) {
    final statusIndex = TicketStatus.values.indexOf(status);
    final isDone = statusIndex <= currentStatusIndex;
    final isCurrent = statusIndex == currentStatusIndex;
    final colorScheme = Theme.of(context).colorScheme;

    final backgroundColor = isCurrent
        ? colorScheme.primaryContainer
        : isDone
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerHighest;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(
          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCurrent
              ? colorScheme.primary
              : isDone
                  ? Colors.green
                  : Colors.grey,
        ),
        tileColor: backgroundColor,
        title: Text(status.label),
        subtitle: Text(
          isCurrent
              ? 'Status saat ini'
              : canEdit
                  ? 'Ketuk untuk mengubah status'
                  : 'Tracking status',
        ),
        trailing: canEdit
            ? const Icon(Icons.chevron_right)
            : isCurrent
                ? const Icon(Icons.flag, size: 18)
                : null,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(appControllerProvider);
    final profile = controller.currentUser;
    final ticket = controller.getTicketById(widget.ticketId);

    if (ticket == null) {
      return const Scaffold(body: Center(child: Text('Tiket tidak ditemukan.')));
    }

    final currentStatusIndex = TicketStatus.values.indexOf(ticket.status);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tiket')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(ticket.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(ticket.description),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Chip(label: Text('Status: ${ticket.status.label}')),
              Chip(label: Text('Reporter: ${ticket.userName}')),
              Chip(label: Text('Assigned: ${ticket.assignedTo ?? '-'}')),
            ],
          ),
          if (ticket.imageUrl != null && ticket.imageUrl!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image.network(
                    ticket.imageUrl!,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 240,
                        width: double.infinity,
                        alignment: Alignment.center,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Text('Lampiran gambar tidak dapat ditampilkan'),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Lampiran: ${ticket.imageUrl}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (_isSupport(profile)) ...<Widget>[
            Text(
              'Panel Helpdesk/Admin',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _assignedController,
              decoration: const InputDecoration(labelText: 'Assign Ticket Ke'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<TicketStatus>(
              initialValue: _selectedStatus ?? ticket.status,
              decoration: const InputDecoration(labelText: 'Update Status'),
              items: TicketStatus.values
                  .map(
                    (status) => DropdownMenuItem<TicketStatus>(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: _isBusy ? null : _saveSupportUpdate,
              child: const Text('Simpan Perubahan'),
            ),
            const SizedBox(height: 20),
          ],
          Text('Tracking Status', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...TicketStatus.values.map((status) {
            final canEdit = _isSupport(profile);
            return _buildStatusStep(
              context,
              status,
              currentStatusIndex,
              canEdit,
              canEdit ? () => _setStatus(status) : null,
            );
          }),
          const SizedBox(height: 16),
          Text('Riwayat Aktivitas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...ticket.tracking
              .map(
                (trace) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.timeline),
                    title: Text(trace.message),
                    subtitle: Text('${trace.actorName} • ${trace.createdAt}'),
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 16),
          Text('Komentar / Reply', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...ticket.comments
              .map(
                (comment) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(comment.message),
                  subtitle: Text(
                    '${comment.authorName} (${comment.authorRole.value}) • ${comment.createdAt}',
                  ),
                ),
              )
              .toList(),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Tulis komentar',
              border: OutlineInputBorder(),
            ),
            minLines: 1,
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _isBusy ? null : _submitComment,
            icon: const Icon(Icons.send),
            label: const Text('Kirim Reply'),
          ),
        ],
      ),
    );
  }
}
