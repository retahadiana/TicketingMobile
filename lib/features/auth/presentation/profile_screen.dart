import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_controller.dart';
import '../../../models/profile_model.dart';
import '../../tickets/presentation/history_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    final profile = controller.currentUser;

    if (profile == null) {
      return const Center(child: Text('Tidak ada profil aktif.'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        _ProfileHeader(profile: profile),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat & Tracking'),
            subtitle: const Text('Lihat histori aktivitas tiket'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: controller.themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref
                    .read(appControllerProvider)
                    .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
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
            Text('Role: ${profile.role.value}'),
          ],
        ),
      ),
    );
  }
}
