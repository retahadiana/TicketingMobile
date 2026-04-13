import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile_model.dart';
import '../models/ticket_model.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/ticket_service.dart';
import 'permissions.dart';
import 'supabase_state.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final profileServiceProvider = Provider<ProfileService>((ref) => ProfileService());
final ticketServiceProvider = Provider<TicketService>((ref) => TicketService());

final appControllerProvider = ChangeNotifierProvider<AppController>((ref) {
  return AppController(
    authService: ref.read(authServiceProvider),
    profileService: ref.read(profileServiceProvider),
    ticketService: ref.read(ticketServiceProvider),
  );
});

class AppController extends ChangeNotifier {
  final AuthService _authService;
  final ProfileService _profileService;
  final TicketService _ticketService;

  AppController({
    required AuthService authService,
    required ProfileService profileService,
    required TicketService ticketService,
  })  : _authService = authService,
        _profileService = profileService,
        _ticketService = ticketService {
    _bootstrap();
  }

  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = false;
  String? _lastError;
  Profile? _currentUser;
  List<Ticket> _tickets = <Ticket>[];
  List<TicketNotification> _notifications = <TicketNotification>[];
  List<Profile> _profilesForProvisioning = <Profile>[];

  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  Profile? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  List<Ticket> get visibleTickets => _tickets;

  List<TicketNotification> get myNotifications => _notifications;

  List<Profile> get profilesForProvisioning => _profilesForProvisioning;

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  List<TicketTrackingEvent> get activityHistory {
    final all = <TicketTrackingEvent>[];
    for (final ticket in _tickets) {
      all.addAll(ticket.tracking);
    }
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  Map<TicketStatus, int> get dashboardStats {
    final stats = <TicketStatus, int>{
      TicketStatus.open: 0,
      TicketStatus.inProgress: 0,
      TicketStatus.resolved: 0,
      TicketStatus.closed: 0,
    };

    for (final ticket in _tickets) {
      stats[ticket.status] = (stats[ticket.status] ?? 0) + 1;
    }
    return stats;
  }

  Ticket? getTicketById(String ticketId) {
    for (final ticket in _tickets) {
      if (ticket.id == ticketId) {
        return ticket;
      }
    }
    return null;
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> _bootstrap() async {
    if (!SupabaseState.isInitialized) {
      _lastError =
          'Supabase belum terinisialisasi. Jalankan aplikasi dengan SUPABASE_URL dan SUPABASE_ANON_KEY.';
      notifyListeners();
      return;
    }

    await _withLoading(() async {
      final profile = await _profileService.getCurrentProfile();
      _currentUser = profile;
      if (profile != null) {
        await refreshData();
      }
    });
  }

  Future<void> login({required String email, required String password}) async {
    await _withLoading(() async {
      await _authService.signIn(email, password);
      _currentUser = await _profileService.getCurrentProfile();
      await refreshData();
    });
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await _withLoading(() async {
      await _authService.signUp(email, password, fullName, role.value);
    });
  }

  Future<void> resetPassword({required String email}) async {
    await _withLoading(() async {
      await _authService.resetPassword(email);
    });
  }

  Future<void> logout() async {
    await _withLoading(() async {
      await _authService.signOut();
      _currentUser = null;
      _tickets = <Ticket>[];
      _notifications = <TicketNotification>[];
    });
  }

  Future<void> refreshData() async {
    final profile = _currentUser;
    if (profile == null) {
      return;
    }

    await _withLoading(() async {
      _tickets = await _ticketService.fetchTicketsForRole(profile);
      _notifications = await _ticketService.fetchNotificationsForRole(profile);
      if (profile.role == UserRole.admin) {
        _profilesForProvisioning = await _profileService.listAllProfilesForAdmin();
      } else {
        _profilesForProvisioning = <Profile>[];
      }
    }, silentLoading: true);
  }

  Future<void> refreshProvisioningUsers() async {
    final profile = _requireCurrentUser();
    PermissionGuard.require(profile.role, AppPermission.manageUserRoles);

    await _withLoading(() async {
      _profilesForProvisioning = await _profileService.listAllProfilesForAdmin();
    }, silentLoading: true);
  }

  Future<void> assignRoleToUser({
    required String targetUserId,
    required UserRole role,
  }) async {
    final profile = _requireCurrentUser();
    if (profile.role != UserRole.admin) {
      throw Exception('Hanya Admin yang dapat mengubah role user.');
    }

    await _withLoading(() async {
      await _profileService.assignUserRole(targetUserId: targetUserId, role: role);
      _profilesForProvisioning = await _profileService.listAllProfilesForAdmin();

      if (_currentUser?.id == targetUserId) {
        _currentUser = _currentUser?.copyWith(role: role);
      }
    });
  }

  Future<void> createTicket({
    required String title,
    required String description,
    String? imagePath,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    final profile = _requireCurrentUser();
    PermissionGuard.require(profile.role, AppPermission.createTicket);

    await _withLoading(() async {
      String? imageUrl;
      if (imageBytes != null && imageBytes.isNotEmpty) {
        imageUrl = await _ticketService.uploadImageBytes(
          imageBytes,
          userId: profile.id,
          fileName: imageFileName,
        );
      } else if (imagePath != null && imagePath.isNotEmpty) {
        imageUrl = await _ticketService.uploadImage(File(imagePath), userId: profile.id);
      }

      await _ticketService.createTicket(
        actor: profile,
        title: title,
        description: description,
        imageUrl: imageUrl,
      );

      await refreshData();
    });
  }

  Future<void> addComment({required String ticketId, required String message}) async {
    final profile = _requireCurrentUser();
    PermissionGuard.require(profile.role, AppPermission.addComment);

    await _withLoading(() async {
      await _ticketService.addComment(
        actor: profile,
        ticketId: ticketId,
        message: message,
      );
      await refreshData();
    });
  }

  Future<void> updateTicketStatus({
    required String ticketId,
    required TicketStatus newStatus,
  }) async {
    final profile = _requireCurrentUser();
    PermissionGuard.require(profile.role, AppPermission.updateTicketStatus);

    await _withLoading(() async {
      await _ticketService.updateTicketStatus(
        actor: profile,
        ticketId: ticketId,
        status: newStatus,
      );
      await refreshData();
    });
  }

  Future<void> assignTicket({
    required String ticketId,
    required String assigneeName,
  }) async {
    final profile = _requireCurrentUser();
    PermissionGuard.require(profile.role, AppPermission.assignTicket);

    await _withLoading(() async {
      await _ticketService.assignTicket(
        actor: profile,
        ticketId: ticketId,
        assigneeName: assigneeName,
      );
      await refreshData();
    });
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _withLoading(() async {
      await _ticketService.markNotificationRead(notificationId);
      _notifications = _notifications
          .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
          .toList();
    }, silentLoading: true);
  }

  Profile _requireCurrentUser() {
    final profile = _currentUser;
    if (profile == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }
    return profile;
  }

  Future<void> _withLoading(
    Future<void> Function() action, {
    bool silentLoading = false,
  }) async {
    if (!silentLoading) {
      _isLoading = true;
      _lastError = null;
      notifyListeners();
    }

    try {
      await action();
    } catch (error) {
      _lastError = error.toString();
      rethrow;
    } finally {
      if (!silentLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }
}
