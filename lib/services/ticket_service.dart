import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/permissions.dart';
import '../models/profile_model.dart';
import '../models/ticket_model.dart';

class TicketService {
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<List<Ticket>> fetchTicketsForRole(Profile actor) async {
    dynamic query = _supabase.from('tickets').select();

    if (PermissionGuard.hasPermission(actor.role, AppPermission.viewAllTickets)) {
      query = query.order('updated_at', ascending: false);
    } else {
      query = query.eq('user_id', actor.id).order('updated_at', ascending: false);
    }

    final rawTickets = await query;
    final tickets = (rawTickets as List<dynamic>)
        .map((row) => Ticket.fromJson(row as Map<String, dynamic>))
        .toList();

    if (tickets.isEmpty) {
      return tickets;
    }

    final ticketIds = tickets.map((ticket) => ticket.id).toList();

    final commentsRaw = await _supabase
        .from('ticket_comments')
        .select()
        .inFilter('ticket_id', ticketIds)
        .order('created_at', ascending: true);

    final trackingRaw = await _supabase
        .from('ticket_tracking')
        .select()
        .inFilter('ticket_id', ticketIds)
        .order('created_at', ascending: true);

    final commentsByTicket = <String, List<TicketComment>>{};
    for (final row in commentsRaw as List<dynamic>) {
      final comment = TicketComment.fromJson(row as Map<String, dynamic>);
      commentsByTicket.putIfAbsent(comment.ticketId, () => <TicketComment>[]).add(comment);
    }

    final trackingByTicket = <String, List<TicketTrackingEvent>>{};
    for (final row in trackingRaw as List<dynamic>) {
      final event = TicketTrackingEvent.fromJson(row as Map<String, dynamic>);
      trackingByTicket.putIfAbsent(event.ticketId, () => <TicketTrackingEvent>[]).add(event);
    }

    return tickets
        .map(
          (ticket) => ticket.copyWith(
            comments: commentsByTicket[ticket.id] ?? const <TicketComment>[],
            tracking: trackingByTicket[ticket.id] ?? const <TicketTrackingEvent>[],
          ),
        )
        .toList();
  }

  Future<List<TicketNotification>> fetchNotificationsForRole(Profile actor) async {
    final orFilter = 'target_user_id.eq.${actor.id},target_role.eq.${actor.role.value}';
    final data = await _supabase
        .from('ticket_notifications')
        .select()
        .or(orFilter)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((row) => TicketNotification.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<String?> uploadImage(File imageFile, {required String userId}) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('\\').last}';
    final path = '$userId/$fileName';

    await _supabase.storage.from('ticket-attachments').upload(path, imageFile);
    return _supabase.storage.from('ticket-attachments').getPublicUrl(path);
  }

  Future<String?> uploadImageBytes(
    Uint8List bytes, {
    required String userId,
    String? fileName,
  }) async {
    final resolvedName = fileName ?? 'web_image.jpg';
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}_$resolvedName';

    await _supabase.storage.from('ticket-attachments').uploadBinary(path, bytes);
    return _supabase.storage.from('ticket-attachments').getPublicUrl(path);
  }

  Future<void> createTicket({
    required Profile actor,
    required String title,
    required String description,
    String? imageUrl,
  }) async {
    PermissionGuard.require(actor.role, AppPermission.createTicket);

    final now = DateTime.now().toIso8601String();
    final inserted = await _supabase
        .from('tickets')
        .insert({
          'user_id': actor.id,
          'user_name': actor.fullName,
          'title': title,
          'description': description,
          'image_url': imageUrl,
          'status': TicketStatus.open.label,
          'created_at': now,
          'updated_at': now,
        })
        .select('id')
        .single();

    final ticketId = parseString(inserted['id']);

    await _supabase.from('ticket_tracking').insert({
      'ticket_id': ticketId,
      'actor_name': actor.fullName,
      'message': 'Tiket dibuat oleh pelapor.',
      'created_at': now,
    });

    await _supabase.from('ticket_notifications').insert([
      {
        'title': 'Tiket baru masuk',
        'message': '$title menunggu tindak lanjut helpdesk/admin.',
        'ticket_id': ticketId,
        'target_role': UserRole.helpdesk.value,
        'is_read': false,
        'created_at': now,
      },
      {
        'title': 'Tiket baru masuk',
        'message': '$title menunggu tindak lanjut helpdesk/admin.',
        'ticket_id': ticketId,
        'target_role': UserRole.admin.value,
        'is_read': false,
        'created_at': now,
      },
    ]);
  }

  Future<void> addComment({
    required Profile actor,
    required String ticketId,
    required String message,
  }) async {
    await _assertTicketAccessible(actor: actor, ticketId: ticketId);

    final now = DateTime.now().toIso8601String();

    await _supabase.from('ticket_comments').insert({
      'ticket_id': ticketId,
      'author_id': actor.id,
      'author_name': actor.fullName,
      'author_role': actor.role.value,
      'message': message,
      'created_at': now,
    });

    await _supabase.from('ticket_tracking').insert({
      'ticket_id': ticketId,
      'actor_name': actor.fullName,
      'message': 'Komentar baru ditambahkan.',
      'created_at': now,
    });

    final ticket = await _supabase
        .from('tickets')
        .select('user_id,title')
        .eq('id', ticketId)
        .single();

    final ownerId = parseString(ticket['user_id']);
    final ticketTitle = parseString(ticket['title'], fallback: 'Tiket');

    await _supabase.from('ticket_notifications').insert({
      'title': 'Komentar tiket',
      'message': '${actor.fullName} memberi komentar pada tiket $ticketTitle.',
      'ticket_id': ticketId,
      'target_role': UserRole.user.value,
      'target_user_id': ownerId,
      'is_read': false,
      'created_at': now,
    });
  }

  Future<void> updateTicketStatus({
    required Profile actor,
    required String ticketId,
    required TicketStatus status,
  }) async {
    PermissionGuard.require(actor.role, AppPermission.updateTicketStatus);

    final now = DateTime.now().toIso8601String();

    await _supabase
        .from('tickets')
        .update({'status': status.label, 'updated_at': now}).eq('id', ticketId);

    await _supabase.from('ticket_tracking').insert({
      'ticket_id': ticketId,
      'actor_name': actor.fullName,
      'message': 'Status diperbarui menjadi ${status.label}.',
      'created_at': now,
    });

    final ticket = await _supabase
        .from('tickets')
        .select('user_id,title')
        .eq('id', ticketId)
        .single();

    await _supabase.from('ticket_notifications').insert({
      'title': 'Status tiket berubah',
      'message': 'Tiket ${parseString(ticket['title'])} sekarang ${status.label}.',
      'ticket_id': ticketId,
      'target_role': UserRole.user.value,
      'target_user_id': parseString(ticket['user_id']),
      'is_read': false,
      'created_at': now,
    });
  }

  Future<void> assignTicket({
    required Profile actor,
    required String ticketId,
    required String assigneeName,
  }) async {
    PermissionGuard.require(actor.role, AppPermission.assignTicket);

    final now = DateTime.now().toIso8601String();

    await _supabase
        .from('tickets')
        .update({'assigned_to': assigneeName, 'updated_at': now}).eq('id', ticketId);

    await _supabase.from('ticket_tracking').insert({
      'ticket_id': ticketId,
      'actor_name': actor.fullName,
      'message': 'Tiket di-assign ke $assigneeName.',
      'created_at': now,
    });

    final ticket = await _supabase
        .from('tickets')
        .select('user_id,title')
        .eq('id', ticketId)
        .single();

    await _supabase.from('ticket_notifications').insert({
      'title': 'Penugasan tiket',
      'message': 'Tiket ${parseString(ticket['title'])} ditangani oleh $assigneeName.',
      'ticket_id': ticketId,
      'target_role': UserRole.user.value,
      'target_user_id': parseString(ticket['user_id']),
      'is_read': false,
      'created_at': now,
    });
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _supabase
        .from('ticket_notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<void> _assertTicketAccessible({
    required Profile actor,
    required String ticketId,
  }) async {
    final ticket = await _supabase
        .from('tickets')
        .select('user_id')
        .eq('id', ticketId)
        .maybeSingle();

    if (ticket == null) {
      throw Exception('Tiket tidak ditemukan.');
    }

    if (PermissionGuard.hasPermission(actor.role, AppPermission.viewAllTickets)) {
      return;
    }

    final ownerId = parseString(ticket['user_id']);
    if (ownerId != actor.id) {
      throw Exception('Anda tidak berhak mengakses tiket ini.');
    }
  }
}
