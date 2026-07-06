import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_controller.dart';
import '../../../core/permissions.dart';
import '../../../core/theme/glassmorphism.dart';
import '../../../models/profile_model.dart';
import '../../auth/presentation/profile_screen.dart';
import '../../tickets/presentation/create_ticket_screen.dart';
import '../../tickets/presentation/dashboard_screen.dart';
import '../../tickets/presentation/notifications_screen.dart';
import '../../tickets/presentation/ticket_list_screen.dart';
import 'settings_screen.dart';

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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? Colors.white : AGColors.deepNavy;
    final fgSub = fg.withValues(alpha: 0.6);

    if (user == null) {
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

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(titles[_index], style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
            Text(user.role.value, style: TextStyle(color: fgSub, fontSize: 12)),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Pengaturan',
            icon: Icon(Icons.settings, color: fg.withValues(alpha: 0.7)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(appControllerProvider).logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              }
            },
            icon: Icon(Icons.logout, color: fg.withValues(alpha: 0.7)),
          ),
        ],
      ),
      body: SafeArea(child: pages[_index]),
      floatingActionButton: _index == 1 &&
              PermissionGuard.hasPermission(user.role, AppPermission.createTicket)
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const CreateTicketScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Ticket'),
              elevation: 0,
              backgroundColor: dark ? AGColors.accentCyan : AGColors.softPurple,
              foregroundColor: Colors.white,
            )
          : null,
      bottomNavigationBar: AnimatedGlassNavigationBar(
        selectedIndex: _index,
        unreadNotificationCount: controller.unreadNotificationCount,
        onDestinationSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}

// ─── Custom Animated Glass Navigation Bar ────────────────────────────────────
class AnimatedGlassNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final int unreadNotificationCount;

  const AnimatedGlassNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.unreadNotificationCount,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Background and color styling matching the theme and mockup
    final navBgColor = dark ? const Color(0xFF1E1E2C) : Colors.white;
    final activeColor = dark ? AGColors.accentCyan : AGColors.softPurple;
    final inactiveColor = dark ? Colors.white54 : AGColors.deepNavy.withValues(alpha: 0.5);

    final items = [
      const _NavbarItem(icon: Icons.space_dashboard, label: 'Dashboard'),
      const _NavbarItem(icon: Icons.confirmation_number, label: 'Tiket'),
      const _NavbarItem(
        icon: Icons.notifications,
        label: 'Notifikasi',
        isBadge: true,
      ),
      const _NavbarItem(icon: Icons.person, label: 'Profil'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final itemWidth = totalWidth / items.length;

        // Base height of the navbar is 64. Plus safe area bottom padding.
        // Total container height is 64 + 16 (for top overflow padding) + bottomPadding.
        return Container(
          width: totalWidth,
          height: 80 + bottomPadding,
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main background card (rounded only at top corners)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: 16, // Top padding to allow the circle to overflow
                child: Container(
                  decoration: BoxDecoration(
                    color: navBgColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: dark ? 0.35 : 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    border: Border(
                      top: BorderSide(
                        color: dark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),

              // Sliding active circle indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                left: selectedIndex * itemWidth,
                top: 0, // Perfectly floats overlapping the top edge
                child: SizedBox(
                  width: itemWidth,
                  child: Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: navBgColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(alpha: dark ? 0.4 : 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: dark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.05),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: Icon(
                            items[selectedIndex].icon,
                            key: ValueKey<int>(selectedIndex),
                            color: activeColor,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Items Row
              Positioned(
                left: 0,
                right: 0,
                bottom: bottomPadding,
                top: 16,
                child: Row(
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = selectedIndex == index;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onDestinationSelected(index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Show inactive icon or transparent space if active
                            SizedBox(
                              height: 28,
                              child: isSelected
                                  ? const SizedBox.shrink()
                                  : Center(
                                      child: item.isBadge
                                          ? Badge(
                                              isLabelVisible: unreadNotificationCount > 0,
                                              label: Text(unreadNotificationCount.toString()),
                                              child: Icon(
                                                item.icon,
                                                color: inactiveColor,
                                                size: 24,
                                              ),
                                            )
                                          : Icon(
                                              item.icon,
                                              color: inactiveColor,
                                              size: 24,
                                            ),
                                    ),
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? activeColor : inactiveColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavbarItem {
  final IconData icon;
  final String label;
  final bool isBadge;

  const _NavbarItem({
    required this.icon,
    required this.label,
    this.isBadge = false,
  });
}
