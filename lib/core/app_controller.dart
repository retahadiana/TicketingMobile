import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile_model.dart';
import '../models/ticket_model.dart';

final appControllerProvider =
    ChangeNotifierProvider<AppController>((ref) => AppController());

class AppController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Profile? _currentUser;

  final List<Profile> _users = <Profile>[
    const Profile(
      id: 'u-1',
      fullName: 'Budi User',
      role: UserRole.user,
      email: 'user@helpdesk.app',
    ),
    const Profile(
      id: 'u-2',
      fullName: 'Sari Helpdesk',
      role: UserRole.helpdesk,
      email: 'helpdesk@helpdesk.app',
    ),
    const Profile(
      id: 'u-3',
      fullName: 'Andi Admin',
      role: UserRole.admin,
      email: 'admin@helpdesk.app',
    ),
  ];

  final Map<String, String> _passwordByEmail = <String, String>{
    'user@helpdesk.app': '123456',
    'helpdesk@helpdesk.app': '123456',
    'admin@helpdesk.app': '123456',
  };

  final List<Ticket> _tickets = <Ticket>[];
  final List<TicketNotification> _notifications = <TicketNotification>[];

  AppController() {
    _seedInitialTickets();
  }

  ThemeMode get themeMode => _themeMode;
  Profile? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  List<Ticket> get visibleTickets {
    final user = _currentUser;
    if (user == null) {
      return const <Ticket>[];
    }

    if (user.role == UserRole.user) {
      final ownTickets = _tickets.where((t) => t.userId == user.id).toList();
      ownTickets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return ownTickets;
    }

    final allTickets = List<Ticket>.from(_tickets);
    allTickets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return allTickets;
  }

  List<TicketTrackingEvent> get activityHistory {
    final sorted = <TicketTrackingEvent>[];
    for (final ticket in visibleTickets) {
      sorted.addAll(ticket.tracking);
    }
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  List<TicketNotification> get myNotifications {
    final user = _currentUser;
    if (user == null) {
      return const <TicketNotification>[];
    }

    final filtered = _notifications.where((n) {
      if (n.targetUserId != null) {
        return n.targetUserId == user.id;
      }
      return n.targetRole == user.role;
    }).toList();
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  int get unreadNotificationCount =>
      myNotifications.where((notification) => !notification.isRead).length;

  Map<TicketStatus, int> get dashboardStats {
    final stats = <TicketStatus, int>{
      TicketStatus.open: 0,
      TicketStatus.inProgress: 0,
      TicketStatus.resolved: 0,
      TicketStatus.closed: 0,
    };

    for (final ticket in visibleTickets) {
      stats[ticket.status] = (stats[ticket.status] ?? 0) + 1;
    }
    return stats;
  }

  Future<void> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final user = _users
        .where((u) => u.email.toLowerCase() == email.toLowerCase())
        .cast<Profile?>()
        .firstWhere((u) => u != null, orElse: () => null);

    if (user == null) {
      throw Exception('Akun tidak ditemukan.');
    }

    final savedPassword = _passwordByEmail[user.email];
    if (savedPassword != password) {
      throw Exception('Password tidak sesuai.');
    }

    _currentUser = user;
    notifyListeners();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final exists = _users.any((u) => u.email.toLowerCase() == email.toLowerCase());
    if (exists) {
      throw Exception('Email sudah terdaftar.');
    }

    final newUser = Profile(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      role: UserRole.user,
      email: email,
    );

    _users.add(newUser);
    _passwordByEmail[email] = password;
    notifyListeners();
  }

  Future<void> resetPassword({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final exists = _users.any((u) => u.email.toLowerCase() == email.toLowerCase());
    if (!exists) {
      throw Exception('Email tidak ditemukan.');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> createTicket({
    required String title,
    required String description,
    String? imagePath,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    final now = DateTime.now();
    final id = 't-${now.microsecondsSinceEpoch}';

    final firstTracking = TicketTrackingEvent(
      id: 'tr-${now.microsecondsSinceEpoch}',
      ticketId: id,
      actorName: user.fullName,
      message: 'Tiket dibuat oleh pelapor.',
      createdAt: now,
    );

    _tickets.insert(
      0,
      Ticket(
        id: id,
        userId: user.id,
        userName: user.fullName,
        title: title,
        description: description,
        status: TicketStatus.open,
        imageUrl: imagePath,
        createdAt: now,
        updatedAt: now,
        tracking: <TicketTrackingEvent>[firstTracking],
      ),
    );

    _pushNotification(
      title: 'Tiket baru masuk',
      message: '$title menunggu tindak lanjut helpdesk/admin.',
      ticketId: id,
      targetRole: UserRole.helpdesk,
    );
    _pushNotification(
      title: 'Tiket baru masuk',
      message: '$title menunggu tindak lanjut helpdesk/admin.',
      ticketId: id,
      targetRole: UserRole.admin,
    );

    notifyListeners();
  }

  Future<void> addComment({required String ticketId, required String message}) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    final index = _tickets.indexWhere((ticket) => ticket.id == ticketId);
    if (index < 0) {
      throw Exception('Tiket tidak ditemukan.');
    }

    final ticket = _tickets[index];
    final now = DateTime.now();

    final comment = TicketComment(
      id: 'c-${now.microsecondsSinceEpoch}',
      ticketId: ticketId,
      authorId: user.id,
      authorName: user.fullName,
      authorRole: user.role,
      message: message,
      createdAt: now,
    );

    final tracking = TicketTrackingEvent(
      id: 'tr-${now.microsecondsSinceEpoch + 1}',
      ticketId: ticketId,
      actorName: user.fullName,
      message: 'Komentar baru ditambahkan.',
      createdAt: now,
    );

    _tickets[index] = ticket.copyWith(
      comments: <TicketComment>[...ticket.comments, comment],
      tracking: <TicketTrackingEvent>[...ticket.tracking, tracking],
      updatedAt: now,
    );

    _pushNotification(
      title: 'Komentar tiket',
      message: '${user.fullName} memberi komentar pada tiket ${ticket.title}.',
      ticketId: ticketId,
      targetRole: UserRole.user,
      targetUserId: ticket.userId,
    );

    notifyListeners();
  }

  Future<void> updateTicketStatus({
    required String ticketId,
    required TicketStatus newStatus,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    if (user.role == UserRole.user) {
      throw Exception('Hanya helpdesk/admin yang dapat mengubah status.');
    }

    final index = _tickets.indexWhere((ticket) => ticket.id == ticketId);
    if (index < 0) {
      throw Exception('Tiket tidak ditemukan.');
    }

    final ticket = _tickets[index];
    final now = DateTime.now();
    final tracking = TicketTrackingEvent(
      id: 'tr-${now.microsecondsSinceEpoch}',
      ticketId: ticketId,
      actorName: user.fullName,
      message: 'Status diperbarui menjadi ${newStatus.label}.',
      createdAt: now,
    );

    _tickets[index] = ticket.copyWith(
      status: newStatus,
      tracking: <TicketTrackingEvent>[...ticket.tracking, tracking],
      updatedAt: now,
    );

    _pushNotification(
      title: 'Status tiket berubah',
      message: 'Tiket ${ticket.title} sekarang ${newStatus.label}.',
      ticketId: ticketId,
      targetRole: UserRole.user,
      targetUserId: ticket.userId,
    );

    notifyListeners();
  }

  Future<void> assignTicket({
    required String ticketId,
    required String assigneeName,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    if (user.role == UserRole.user) {
      throw Exception('Hanya helpdesk/admin yang dapat assign tiket.');
    }

    final index = _tickets.indexWhere((ticket) => ticket.id == ticketId);
    if (index < 0) {
      throw Exception('Tiket tidak ditemukan.');
    }

    final ticket = _tickets[index];
    final now = DateTime.now();

    final tracking = TicketTrackingEvent(
      id: 'tr-${now.microsecondsSinceEpoch}',
      ticketId: ticketId,
      actorName: user.fullName,
      message: 'Tiket di-assign ke $assigneeName.',
      createdAt: now,
    );

    _tickets[index] = ticket.copyWith(
      assignedTo: assigneeName,
      tracking: <TicketTrackingEvent>[...ticket.tracking, tracking],
      updatedAt: now,
    );

    _pushNotification(
      title: 'Penugasan tiket',
      message: 'Tiket ${ticket.title} ditangani oleh $assigneeName.',
      ticketId: ticketId,
      targetRole: UserRole.user,
      targetUserId: ticket.userId,
    );

    notifyListeners();
  }

  void markNotificationRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index < 0) {
      return;
    }

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
  }

  Ticket? getTicketById(String ticketId) {
    for (final ticket in _tickets) {
      if (ticket.id == ticketId) {
        return ticket;
      }
    }
    return null;
  }

  void _pushNotification({
    required String title,
    required String message,
    required String ticketId,
    required UserRole targetRole,
    String? targetUserId,
  }) {
    _notifications.insert(
      0,
      TicketNotification(
        id: 'n-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        message: message,
        ticketId: ticketId,
        createdAt: DateTime.now(),
        targetRole: targetRole,
        targetUserId: targetUserId,
      ),
    );
  }

  void _seedInitialTickets() {
    final now = DateTime.now();
    final user = _users.firstWhere((u) => u.role == UserRole.user);

    _tickets.addAll(<Ticket>[
      Ticket(
        id: 't-1001',
        userId: user.id,
        userName: user.fullName,
        title: 'Aplikasi lambat saat buka dashboard',
        description: 'Dashboard membutuhkan waktu lama saat menampilkan daftar tiket.',
        status: TicketStatus.inProgress,
        assignedTo: 'Sari Helpdesk',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 3)),
        tracking: <TicketTrackingEvent>[
          TicketTrackingEvent(
            id: 'tr-1',
            ticketId: 't-1001',
            actorName: user.fullName,
            message: 'Tiket dibuat oleh pelapor.',
            createdAt: now.subtract(const Duration(days: 2)),
          ),
          TicketTrackingEvent(
            id: 'tr-2',
            ticketId: 't-1001',
            actorName: 'Sari Helpdesk',
            message: 'Tiket diterima dan sedang dianalisis.',
            createdAt: now.subtract(const Duration(days: 1, hours: 4)),
          ),
        ],
      ),
      Ticket(
        id: 't-1002',
        userId: user.id,
        userName: user.fullName,
        title: 'Tidak bisa upload lampiran dari kamera',
        description: 'Saat memilih kamera, aplikasi tidak melanjutkan ke halaman tiket.',
        status: TicketStatus.open,
        createdAt: now.subtract(const Duration(hours: 10)),
        updatedAt: now.subtract(const Duration(hours: 10)),
        tracking: <TicketTrackingEvent>[
          TicketTrackingEvent(
            id: 'tr-3',
            ticketId: 't-1002',
            actorName: user.fullName,
            message: 'Tiket dibuat oleh pelapor.',
            createdAt: now.subtract(const Duration(hours: 10)),
          ),
        ],
      ),
    ]);

    _notifications.addAll(<TicketNotification>[
      TicketNotification(
        id: 'n-1',
        title: 'Status tiket diperbarui',
        message: 'Tiket Aplikasi lambat saat buka dashboard kini In Progress.',
        ticketId: 't-1001',
        createdAt: now.subtract(const Duration(hours: 3)),
        targetRole: UserRole.user,
        targetUserId: user.id,
      ),
      TicketNotification(
        id: 'n-2',
        title: 'Tiket baru masuk',
        message: 'Tidak bisa upload lampiran dari kamera menunggu tindak lanjut.',
        ticketId: 't-1002',
        createdAt: now.subtract(const Duration(hours: 9)),
        targetRole: UserRole.helpdesk,
      ),
    ]);
  }
}
