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
      id: (json['id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      userName: (json['user_name'] as String?) ?? 'User',
      title: (json['title'] as String?) ?? '-',
      description: (json['description'] as String?) ?? '-',
      status: statusFromString((json['status'] as String?) ?? 'Open'),
      priority: json['priority'] as String?,
      imageUrl: json['image_url'] as String?,
      assignedTo: json['assigned_to'] as String?,
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] as String?) ?? '') ?? DateTime.now(),
    );
  }
}