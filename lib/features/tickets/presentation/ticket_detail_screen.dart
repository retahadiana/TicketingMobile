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

  String _formatDate(DateTime raw) {
    final dt = raw.toLocal();
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

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
    try {
      await ref
          .read(appControllerProvider)
          .addComment(ticketId: widget.ticketId, message: message);
      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim komentar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _saveSupportUpdate() async {
    final selectedStatus = _selectedStatus;
    if (selectedStatus == null) {
      return;
    }

    setState(() => _isBusy = true);

    try {
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan perubahan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _setStatus(TicketStatus status) async {
    setState(() => _selectedStatus = status);
    await _saveSupportUpdate();
  }

  Future<void> _openSupportActionsSheet() async {
    final ticket = ref.read(appControllerProvider).getTicketById(widget.ticketId);
    if (ticket == null) {
      return;
    }

    _assignedController.text = ticket.assignedTo ?? _assignedController.text;
    _selectedStatus ??= ticket.status;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        TicketStatus selected = _selectedStatus ?? ticket.status;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Aksi Helpdesk/Admin', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TicketStatus>(
                    initialValue: selected,
                    decoration: const InputDecoration(labelText: 'Update Status'),
                    items: TicketStatus.values
                        .map(
                          (status) => DropdownMenuItem<TicketStatus>(
                            value: status,
                            child: Text(status.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => selected = value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _assignedController,
                    decoration: const InputDecoration(labelText: 'Assign Ticket Ke'),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _isBusy
                        ? null
                        : () async {
                            setState(() => _selectedStatus = selected);
                            Navigator.pop(context);
                            await _saveSupportUpdate();
                          },
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan Perubahan'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusStep(
    BuildContext context,
    TicketStatus status,
    int currentStatusIndex,
    bool isLast,
    bool canEdit,
    VoidCallback? onTap,
  ) {
    final statusIndex = TicketStatus.values.indexOf(status);
    final isDone = statusIndex <= currentStatusIndex;
    final isCurrent = statusIndex == currentStatusIndex;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrent ? colorScheme.primaryContainer.withValues(alpha: 0.35) : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCurrent
                ? colorScheme.primary.withValues(alpha: 0.6)
                : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 26,
              child: Column(
                children: <Widget>[
                  Icon(
                    isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isCurrent
                        ? colorScheme.primary
                        : isDone
                            ? Colors.green
                            : Colors.grey,
                    size: 20,
                  ),
                  if (!isLast)
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 2,
                      height: 34,
                      color: isDone
                          ? Colors.green.withValues(alpha: 0.6)
                          : colorScheme.outlineVariant,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(status.label, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      isCurrent
                          ? 'Status aktif saat ini'
                          : canEdit
                              ? 'Ketuk untuk ubah status'
                              : 'Menunggu progres',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            if (canEdit) const Icon(Icons.chevron_right, size: 18),
          ],
        ),
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
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 450),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(offset: Offset(0, (1 - value) * 10), child: child),
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
            ),
          ),
          if (_isSupport(profile)) ...<Widget>[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isBusy ? null : _openSupportActionsSheet,
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Aksi Helpdesk/Admin'),
            ),
          ],
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
          Text('Tracking Status', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...TicketStatus.values.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final canEdit = _isSupport(profile);
            return _buildStatusStep(
              context,
              status,
              currentStatusIndex,
              index == TicketStatus.values.length - 1,
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
                    subtitle: Text('${trace.actorName} • ${_formatDate(trace.createdAt)}'),
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 16),
          Text('Komentar / Reply', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...ticket.comments
              .map(
                (comment) => Card(
                  child: ListTile(
                    title: Text(comment.message),
                    subtitle: Text(
                      '${comment.authorName} (${comment.authorRole.value}) • ${_formatDate(comment.createdAt)}',
                    ),
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
