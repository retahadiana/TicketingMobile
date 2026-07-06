import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_controller.dart';
import '../../../core/theme/glassmorphism.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? Colors.white : AGColors.deepNavy;
    final fgSub = fg.withValues(alpha: 0.6);

    return GradientScaffold(
      appBar: glassAppBar(title: 'Pengaturan'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Tampilan',
                    style: TextStyle(color: fg, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<ThemeMode>(
                    title: Text('Mode Sistem', style: TextStyle(color: fg)),
                    value: ThemeMode.system,
                    groupValue: controller.themeMode,
                    onChanged: (mode) {
                      if (mode != null) {
                        ref.read(appControllerProvider.notifier).setThemeMode(mode);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('Mode Terang', style: TextStyle(color: fg)),
                    value: ThemeMode.light,
                    groupValue: controller.themeMode,
                    onChanged: (mode) {
                      if (mode != null) {
                        ref.read(appControllerProvider.notifier).setThemeMode(mode);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('Mode Gelap', style: TextStyle(color: fg)),
                    value: ThemeMode.dark,
                    groupValue: controller.themeMode,
                    onChanged: (mode) {
                      if (mode != null) {
                        ref.read(appControllerProvider.notifier).setThemeMode(mode);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: ListTile(
                leading: Icon(Icons.info_outline, color: fg.withValues(alpha: 0.7)),
                title: Text('Tentang Aplikasi', style: TextStyle(color: fg)),
                subtitle: Text('E-Ticketing Helpdesk v2.0.0\nProyek UAS Mobile',
                    style: TextStyle(color: fgSub)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
