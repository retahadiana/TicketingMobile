import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_model.dart';

class TicketService {
  final _supabase = Supabase.instance.client;

  Stream<List<Ticket>> streamTickets() {
    return _supabase
        .from('tickets')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) => data.map((json) => Ticket.fromJson(json)).toList());
  }

  Future<List<Ticket>> fetchTickets() async {
    final data = await _supabase
        .from('tickets')
        .select()
        .order('created_at');

    final list = data as List<dynamic>;
    return list.map((json) => Ticket.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<String?> uploadImage(File imageFile) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'ticket-attachments/$fileName';

    await _supabase.storage.from('ticket-attachments').upload(path, imageFile);
    return _supabase.storage.from('ticket-attachments').getPublicUrl(path);
  }

  Future<void> createTicketWithImage({
    required String title,
    required String desc,
    String? imageUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    await _supabase.from('tickets').insert({
      'user_id': user!.id,
      'title': title,
      'description': desc,
      'image_url': imageUrl,
      'status': 'Open',
    });
  }

  Future<void> updateTicket({
    required String ticketId,
    String? status,
    String? assignedTo,
  }) async {
    final updates = <String, dynamic>{};
    if (status != null) updates['status'] = status;
    if (assignedTo != null) updates['assigned_to'] = assignedTo;
    if (updates.isEmpty) return;

    await _supabase.from('tickets').update(updates).eq('id', ticketId);
  }
}
