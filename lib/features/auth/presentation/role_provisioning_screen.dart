import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_controller.dart';
import '../../../core/permissions.dart';
import '../../../models/profile_model.dart';

class RoleProvisioningScreen extends ConsumerStatefulWidget {
  const RoleProvisioningScreen({super.key});

  @override
  ConsumerState<RoleProvisioningScreen> createState() =>
      _RoleProvisioningScreenState();
}

class _RoleProvisioningScreenState extends ConsumerState<RoleProvisioningScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      await ref.read(appControllerProvider).refreshProvisioningUsers();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _assignRole(Profile user, UserRole role) async {
    setState(() => _loading = true);
    try {
      await ref.read(appControllerProvider).assignRoleToUser(
            targetUserId: user.id,
            role: role,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role ${user.fullName} diubah menjadi ${role.value}.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah role: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(appControllerProvider);
    final current = app.currentUser;

    if (current == null ||
        !PermissionGuard.hasPermission(current.role, AppPermission.manageUserRoles)) {
      return const Scaffold(
        body: Center(child: Text('Hanya Admin yang dapat mengakses halaman ini.')),
      );
    }

    final users = app.profilesForProvisioning;

    return Scaffold(
      appBar: AppBar(title: const Text('Provisioning Role User')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, index) {
                  final user = users[index];
                  return Card(
                    child: ListTile(
                      title: Text(user.fullName),
                      subtitle: Text(user.email),
                      trailing: DropdownButton<UserRole>(
                        value: user.role,
                        items: UserRole.values
                            .map(
                              (role) => DropdownMenuItem<UserRole>(
                                value: role,
                                child: Text(role.value),
                              ),
                            )
                            .toList(),
                        onChanged: (newRole) {
                          if (newRole == null || newRole == user.role) {
                            return;
                          }
                          _assignRole(user, newRole);
                        },
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: users.length,
              ),
      ),
    );
  }
}
