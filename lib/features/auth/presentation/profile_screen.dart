import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_controller.dart';
import '../../../core/permissions.dart';
import '../../../models/profile_model.dart';
import '../../tickets/presentation/history_screen.dart';
import 'role_provisioning_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    final profile = controller.currentUser;

    if (profile == null) {
      return const Center(child: Text('Tidak ada profil aktif.'));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 450),
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(offset: Offset(0, (1 - value) * 10), child: child),
          ),
          child: _ProfileHeader(profile: profile),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Riwayat & Tracking'),
                subtitle: const Text('Lihat histori aktivitas tiket'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                subtitle: Text(
                  controller.themeMode == ThemeMode.dark
                      ? 'Tampilan gelap aktif'
                      : 'Tampilan terang aktif',
                ),
                trailing: Switch(
                  value: controller.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    ref
                        .read(appControllerProvider)
                        .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ),
            ],
          ),
        ),
        if (PermissionGuard.hasPermission(profile.role, AppPermission.manageUserRoles))
          Card(
            child: ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Provisioning Role User'),
              subtitle: const Text('Atur role User/Helpdesk/Admin'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const RoleProvisioningScreen(),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.errorContainer,
            foregroundColor: colorScheme.onErrorContainer,
          ),
          onPressed: () async {
            await ref.read(appControllerProvider).logout();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
            }
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Profile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 26,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(profile.fullName.substring(0, 1).toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(profile.fullName,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(profile.email),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('Role: ${profile.role.value}'),
            ),
          ],
        ),
      ),
    );
  }
}
