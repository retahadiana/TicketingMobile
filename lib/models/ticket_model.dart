import 'profile_model.dart';

enum TicketStatus {
  open,
  inProgress,
  resolved,
  closed,
}

extension TicketStatusX on TicketStatus {
  String get label {
    switch (this) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }
}

TicketStatus statusFromString(String rawStatus) {
  switch (rawStatus.toLowerCase()) {
    case 'in progress':
      return TicketStatus.inProgress;
    case 'resolved':
      return TicketStatus.resolved;
    case 'closed':
      return TicketStatus.closed;
    default:
      return TicketStatus.open;
  }
}

DateTime parseDate(dynamic raw) {
  if (raw is String) {
    return DateTime.tryParse(raw) ?? DateTime.now();
  }
  return DateTime.now();
}

String parseString(dynamic value, {String fallback = ''}) {
  if (value is String) {
    return value;
  }
  if (value != null) {
    return value.toString();
  }
  return fallback;
}

class TicketComment {
  final String id;
  final String ticketId;
  final String authorId;
  final String authorName;
  final UserRole authorRole;
  final String message;
  final DateTime createdAt;

  const TicketComment({
    required this.id,
    required this.ticketId,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.message,
    required this.createdAt,
  });

  factory TicketComment.fromJson(Map<String, dynamic> json) {
    return TicketComment(
      id: parseString(json['id']),
      ticketId: parseString(json['ticket_id']),
      authorId: parseString(json['author_id']),
      authorName: parseString(json['author_name'], fallback: 'Unknown'),
      authorRole: roleFromString(parseString(json['author_role'], fallback: 'User')),
      message: parseString(json['message'], fallback: '-'),
      createdAt: parseDate(json['created_at']),
    );
  }
}

class TicketTrackingEvent {
  final String id;
  final String ticketId;
  final String actorName;
  final String message;
  final DateTime createdAt;

  const TicketTrackingEvent({
    required this.id,
    required this.ticketId,
    required this.actorName,
    required this.message,
    required this.createdAt,
  });

  factory TicketTrackingEvent.fromJson(Map<String, dynamic> json) {
    return TicketTrackingEvent(
      id: parseString(json['id']),
      ticketId: parseString(json['ticket_id']),
      actorName: parseString(json['actor_name'], fallback: 'System'),
      message: parseString(json['message'], fallback: '-'),
      createdAt: parseDate(json['created_at']),
    );
  }
}

class TicketNotification {
  final String id;
  final String title;
  final String message;
  final String ticketId;
  final DateTime createdAt;
  final UserRole targetRole;
  final String? targetUserId;
  final bool isRead;

  const TicketNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.ticketId,
    required this.createdAt,
    required this.targetRole,
    this.targetUserId,
    this.isRead = false,
  });

  TicketNotification copyWith({bool? isRead}) {
    return TicketNotification(
      id: id,
      title: title,
      message: message,
      ticketId: ticketId,
      createdAt: createdAt,
      targetRole: targetRole,
      targetUserId: targetUserId,
      isRead: isRead ?? this.isRead,
    );
  }

  factory TicketNotification.fromJson(Map<String, dynamic> json) {
    return TicketNotification(
      id: parseString(json['id']),
      title: parseString(json['title'], fallback: '-'),
      message: parseString(json['message'], fallback: '-'),
      ticketId: parseString(json['ticket_id']),
      createdAt: parseDate(json['created_at']),
      targetRole: roleFromString(parseString(json['target_role'], fallback: 'User')),
      targetUserId: json['target_user_id'] as String?,
      isRead: (json['is_read'] as bool?) ?? false,
    );
  }
}

class Ticket {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String description;
  final TicketStatus status;
  final String? priority;
  final String? imageUrl;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TicketComment> comments;
  final List<TicketTrackingEvent> tracking;

  const Ticket({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    required this.status,
    this.priority,
    this.imageUrl,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
    this.comments = const <TicketComment>[],
    this.tracking = const <TicketTrackingEvent>[],
  });

  Ticket copyWith({
    String? id,
    String? userId,
    String? userName,
    String? title,
    String? description,
    TicketStatus? status,
    String? priority,
    String? imageUrl,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TicketComment>? comments,
    List<TicketTrackingEvent>? tracking,
  }) {
    return Ticket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      imageUrl: imageUrl ?? this.imageUrl,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      comments: comments ?? this.comments,
      tracking: tracking ?? this.tracking,
    );
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: parseString(json['id']),
      userId: parseString(json['user_id']),
      userName: parseString(json['user_name'], fallback: 'User'),
      title: parseString(json['title'], fallback: '-'),
      description: parseString(json['description'], fallback: '-'),
      status: statusFromString(parseString(json['status'], fallback: 'Open')),
      priority: json['priority'] as String?,
      imageUrl: json['image_url'] as String?,
      assignedTo: json['assigned_to'] as String?,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}
