import '../models/profile_model.dart';

enum AppPermission {
  viewOwnTickets,
  viewAllTickets,
  createTicket,
  addComment,
  updateTicketStatus,
  assignTicket,
  viewNotifications,
  manageUserRoles,
}

class PermissionGuard {
  static bool hasPermission(UserRole role, AppPermission permission) {
    switch (permission) {
      case AppPermission.viewOwnTickets:
      case AppPermission.addComment:
      case AppPermission.viewNotifications:
        return true;
      case AppPermission.createTicket:
        return role == UserRole.user;
      case AppPermission.viewAllTickets:
      case AppPermission.updateTicketStatus:
      case AppPermission.assignTicket:
        return role == UserRole.helpdesk || role == UserRole.admin;
      case AppPermission.manageUserRoles:
        return role == UserRole.admin;
    }
  }

  static void require(UserRole role, AppPermission permission) {
    if (!hasPermission(role, permission)) {
      throw Exception('Anda tidak memiliki akses untuk aksi ini.');
    }
  }
}
