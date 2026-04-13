# SRS Traceability Matrix

| SRS ID | Requirement | Screen/Feature | Endpoint/Table | Source File |
|---|---|---|---|---|
| FR-001 | Login | Login form + session bootstrap | `supabase.auth.signInWithPassword` | `lib/features/auth/presentation/login_screen.dart`, `lib/core/app_controller.dart`, `lib/services/auth_service.dart` |
| FR-002 | Logout | Logout from app bar/profile | `supabase.auth.signOut` | `lib/features/home/presentation/home_shell_screen.dart`, `lib/features/auth/presentation/profile_screen.dart`, `lib/services/auth_service.dart` |
| FR-003 | Register | Register User | `supabase.auth.signUp`, `profiles` upsert | `lib/features/auth/presentation/register_screen.dart`, `lib/services/auth_service.dart`, `lib/services/profile_service.dart` |
| FR-004 | Reset Password | Reset password form | `supabase.auth.resetPasswordForEmail` | `lib/features/auth/presentation/reset_password_screen.dart`, `lib/services/auth_service.dart` |
| FR-005.1 | Membuat tiket | Create Ticket | `tickets` insert | `lib/features/tickets/presentation/create_ticket_screen.dart`, `lib/services/ticket_service.dart`, `lib/core/app_controller.dart` |
| FR-005.2 | Upload lampiran kamera/file | Camera/Gallery attachment | `storage.ticket-attachments` upload + `tickets.image_url` | `lib/features/tickets/presentation/create_ticket_screen.dart`, `lib/services/ticket_service.dart` |
| FR-005.3 | Melihat daftar tiket | Ticket list by role | `tickets` select (user scoped/all scoped) | `lib/features/tickets/presentation/ticket_list_screen.dart`, `lib/services/ticket_service.dart` |
| FR-005.4 | Melihat detail tiket | Ticket detail | `tickets`, `ticket_comments`, `ticket_tracking` select | `lib/features/tickets/presentation/ticket_detail_screen.dart`, `lib/services/ticket_service.dart` |
| FR-005.5 | Komentar/reply | Comment composer | `ticket_comments` insert, `ticket_tracking` insert | `lib/features/tickets/presentation/ticket_detail_screen.dart`, `lib/services/ticket_service.dart` |
| FR-006.1 | Helpdesk/Admin lihat semua tiket | Role-based list scope | `tickets` select all (helpdesk/admin) | `lib/services/ticket_service.dart`, `lib/core/permissions.dart` |
| FR-006.2 | Filter/kelola tiket | Dashboard + list operations | `tickets` query by status + role scope | `lib/features/tickets/presentation/dashboard_screen.dart`, `lib/features/tickets/presentation/ticket_list_screen.dart` |
| FR-006.3 | Update status | Helpdesk/Admin action guard | `tickets` update, `ticket_tracking` insert, `ticket_notifications` insert | `lib/features/tickets/presentation/ticket_detail_screen.dart`, `lib/services/ticket_service.dart`, `lib/core/permissions.dart` |
| FR-006.4 | Assign tiket | Helpdesk/Admin assignment | `tickets.assigned_to` update + tracking + notification | `lib/features/tickets/presentation/ticket_detail_screen.dart`, `lib/services/ticket_service.dart`, `lib/core/permissions.dart` |
| FR-007.1 | Menampilkan notifikasi status | Notification list | `ticket_notifications` select | `lib/features/tickets/presentation/notifications_screen.dart`, `lib/services/ticket_service.dart` |
| FR-007.2 | Navigasi dari notifikasi | Tap notification to detail | `ticket_notifications.is_read` update | `lib/features/tickets/presentation/notifications_screen.dart`, `lib/core/app_controller.dart` |
| FR-008 | Statistik tiket dashboard | Open/Progress/Resolved/Closed cards | Aggregated in client from scoped ticket set | `lib/features/tickets/presentation/dashboard_screen.dart`, `lib/core/app_controller.dart` |
| FR-010 | Riwayat penanganan tiket | History screen | `ticket_tracking` select | `lib/features/tickets/presentation/history_screen.dart`, `lib/core/app_controller.dart`, `lib/services/ticket_service.dart` |
| FR-011 | Tracking status tiket aktif | Timeline in ticket detail | `ticket_tracking` + status pipeline | `lib/features/tickets/presentation/ticket_detail_screen.dart` |
| NFR-Performance | List efisien | Scoped fetch + ordered queries | Indexed query on `updated_at` | `lib/services/ticket_service.dart`, `supabase/srs_backend_setup.sql` |
| NFR-Usability | UI responsive dan konsisten | Material 3 + reusable flow | N/A | `lib/main.dart`, `lib/features/**` |
| NFR-Compatibility | Android & iOS | Flutter cross-platform | N/A | `pubspec.yaml`, `android/`, `ios/` |
| NFR-Maintainability | Clean architecture baseline | Controller + services + model + permission guard | N/A | `lib/core/`, `lib/services/`, `lib/models/` |
| UI-01 | Splash Screen | Splash screen | N/A | `lib/features/auth/presentation/splash_screen.dart` |
| UI-02 | Login Screen | Login screen | Auth endpoint | `lib/features/auth/presentation/login_screen.dart` |
| UI-03 | Dashboard | Dashboard screen | Ticket endpoint | `lib/features/tickets/presentation/dashboard_screen.dart` |
| UI-04 | List Tiket | Ticket list | Ticket endpoint | `lib/features/tickets/presentation/ticket_list_screen.dart` |
| UI-05 | Detail Tiket | Ticket detail + tracking + comments | Ticket/comment/tracking endpoint | `lib/features/tickets/presentation/ticket_detail_screen.dart` |
| UI-06 | Create Ticket | Create ticket form | Ticket endpoint + storage | `lib/features/tickets/presentation/create_ticket_screen.dart` |
| UI-07 | Profile | Profile + logout + theme | Profile/auth endpoint | `lib/features/auth/presentation/profile_screen.dart` |
| UI-08 | Dark/Light Mode | Theme switch | N/A | `lib/main.dart`, `lib/core/app_controller.dart` |
| EXT-ADM-01 | Provisioning role user (Admin) | Admin role provisioning screen | `profiles` select/update + `assign_user_role` RPC | `lib/features/auth/presentation/role_provisioning_screen.dart`, `lib/services/profile_service.dart`, `supabase/srs_backend_setup.sql` |
