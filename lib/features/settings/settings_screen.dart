import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_apis_flutter/core/auth/providers/auth_providers.dart';
import 'package:google_apis_flutter/core/config/app_config.dart';
import 'package:google_apis_flutter/core/notifications/notification_service.dart';
import 'package:google_apis_flutter/core/storage/hive_init.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _biometricEnabled = false;
  bool _pushEnabled = true;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    final box = ref.read(kvBoxProvider);
    _biometricEnabled = box.get('biometric_enabled') == 'true';
    _pushEnabled = box.get('push_enabled') != 'false';
    _darkMode = box.get('dark_mode') == 'true';
  }

  Future<void> _toggle(String key, bool value) async {
    await ref.read(kvBoxProvider).put(key, value.toString());
  }

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.fromEnvironment();
    final activeAsync = ref.watch(activeAccountProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          activeAsync.maybeWhen(
            data: (a) => a == null
                ? const SizedBox.shrink()
                : ListTile(
                    leading: CircleAvatar(
                      backgroundImage: a.photoUrl != null
                          ? NetworkImage(a.photoUrl!)
                          : null,
                      child: a.photoUrl == null
                          ? Text((a.displayName ?? a.email).substring(0, 1))
                          : null,
                    ),
                    title: Text(a.displayName ?? a.email),
                    subtitle: Text(a.email),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          const Divider(),
          SwitchListTile(
            value: _biometricEnabled,
            onChanged: (v) {
              setState(() => _biometricEnabled = v);
              _toggle('biometric_enabled', v);
            },
            title: const Text('Unlock with biometrics'),
            subtitle: const Text('Require fingerprint/Face ID on launch'),
          ),
          SwitchListTile(
            value: _pushEnabled,
            onChanged: (v) async {
              setState(() => _pushEnabled = v);
              _toggle('push_enabled', v);
              if (v) {
                await ref
                    .read(notificationServiceProvider)
                    .requestPermissions();
              }
            },
            title: const Text('Push notifications'),
            subtitle: const Text('Meeting reminders, sync status'),
          ),
          SwitchListTile(
            value: _darkMode,
            onChanged: (v) {
              setState(() => _darkMode = v);
              _toggle('dark_mode', v);
            },
            title: const Text('Dark mode'),
            subtitle: const Text('Override system theme'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy policy'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => launchUrl(Uri.parse(config.privacyPolicyUrl)),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of service'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => launchUrl(Uri.parse(config.termsOfServiceUrl)),
          ),
          ListTile(
            leading: const Icon(Icons.support_outlined),
            title: const Text('Contact support'),
            subtitle: Text(config.supportEmail),
            onTap: () => launchUrl(
                Uri.parse('mailto:${config.supportEmail}')),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sign out',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await ref.read(authRepositoryProvider).signOutAll();
              if (context.mounted) context.go('/signin');
            },
          ),
          ListTile(
            title: const Center(
              child: Text(
                'v1.0.0',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
