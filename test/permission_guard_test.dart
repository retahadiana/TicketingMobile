import 'package:flutter_test/flutter_test.dart';
import 'package:ticketing_helpdesk/core/permissions.dart';
import 'package:ticketing_helpdesk/models/profile_model.dart';

void main() {
  group('PermissionGuard matrix', () {
    test('User permissions are restricted', () {
      expect(PermissionGuard.hasPermission(UserRole.user, AppPermission.createTicket), isTrue);
      expect(PermissionGuard.hasPermission(UserRole.user, AppPermission.viewOwnTickets), isTrue);
      expect(PermissionGuard.hasPermission(UserRole.user, AppPermission.addComment), isTrue);

      expect(PermissionGuard.hasPermission(UserRole.user, AppPermission.viewAllTickets), isFalse);
      expect(PermissionGuard.hasPermission(UserRole.user, AppPermission.updateTicketStatus), isFalse);
      expect(PermissionGuard.hasPermission(UserRole.user, AppPermission.assignTicket), isFalse);
      expect(PermissionGuard.hasPermission(UserRole.user, AppPermission.manageUserRoles), isFalse);
    });

    test('Helpdesk permissions for ticket operations', () {
      expect(PermissionGuard.hasPermission(UserRole.helpdesk, AppPermission.viewAllTickets), isTrue);
      expect(PermissionGuard.hasPermission(UserRole.helpdesk, AppPermission.updateTicketStatus), isTrue);
      expect(PermissionGuard.hasPermission(UserRole.helpdesk, AppPermission.assignTicket), isTrue);

      expect(PermissionGuard.hasPermission(UserRole.helpdesk, AppPermission.createTicket), isFalse);
      expect(PermissionGuard.hasPermission(UserRole.helpdesk, AppPermission.manageUserRoles), isFalse);
    });

    test('Admin has support permissions and user role management', () {
      expect(PermissionGuard.hasPermission(UserRole.admin, AppPermission.viewAllTickets), isTrue);
      expect(PermissionGuard.hasPermission(UserRole.admin, AppPermission.updateTicketStatus), isTrue);
      expect(PermissionGuard.hasPermission(UserRole.admin, AppPermission.assignTicket), isTrue);
      expect(PermissionGuard.hasPermission(UserRole.admin, AppPermission.manageUserRoles), isTrue);
    });
  });
}
