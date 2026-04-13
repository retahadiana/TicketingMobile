import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_controller.dart';
import '../../../models/profile_model.dart';
import '../../auth/presentation/profile_screen.dart';
import '../../tickets/presentation/create_ticket_screen.dart';
import '../../tickets/presentation/dashboard_screen.dart';
import '../../tickets/presentation/notifications_screen.dart';
import '../../tickets/presentation/ticket_list_screen.dart';

class HomeShellScreen extends ConsumerStatefulWidget {
  const HomeShellScreen({super.key});

  @override
  ConsumerState<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends ConsumerState<HomeShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(appControllerProvider);
    final user = controller.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = <Widget>[
      const DashboardScreen(),
      const TicketListScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    final titles = <String>[
      'Dashboard',
      'Daftar Tiket',
      'Notifikasi',
      'Profil',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${titles[_index]} • ${user.role.value}'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(appControllerProvider).logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: pages[_index],
      floatingActionButton: _index == 1 && user.role == UserRole.user
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const CreateTicketScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Ticket'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: <Widget>[
          const NavigationDestination(icon: Icon(Icons.space_dashboard), label: 'Dashboard'),
          const NavigationDestination(icon: Icon(Icons.confirmation_number), label: 'Tiket'),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: controller.unreadNotificationCount > 0,
              label: Text(controller.unreadNotificationCount.toString()),
              child: const Icon(Icons.notifications),
            ),
            label: 'Notifikasi',
          ),
          const NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
