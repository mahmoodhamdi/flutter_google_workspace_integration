import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_apis_flutter/core/auth/presentation/widgets/account_switcher.dart';
import 'package:google_apis_flutter/core/config/app_config.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = AppConfig.fromEnvironment();
    return Scaffold(
      appBar: AppBar(
        title: Text(config.appName),
        actions: const <Widget>[
          AccountSwitcher(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 3 : 2,
          padding: const EdgeInsets.all(16),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: _tilesFor(config)
              .map((tile) => _FeatureTile(tile: tile))
              .toList(),
        ),
      ),
    );
  }

  List<_TileDef> _tilesFor(AppConfig c) => <_TileDef>[
        if (c.isEnabled(AppFeature.calendar))
          const _TileDef(
            label: 'Calendar',
            icon: Icons.event,
            route: '/home/calendar',
          ),
        if (c.isEnabled(AppFeature.drive))
          const _TileDef(
            label: 'Drive',
            icon: Icons.folder_outlined,
            route: '/home/drive',
          ),
        if (c.isEnabled(AppFeature.sheets))
          const _TileDef(
            label: 'Sheets',
            icon: Icons.table_chart,
            route: '/home/sheets',
          ),
        if (c.isEnabled(AppFeature.gmailSend))
          const _TileDef(
            label: 'Compose',
            icon: Icons.mail_outlined,
            route: '/home/compose',
          ),
        if (c.isEnabled(AppFeature.contacts))
          const _TileDef(
            label: 'Contacts',
            icon: Icons.contacts_outlined,
            route: '/home/contacts',
          ),
        if (c.isEnabled(AppFeature.maps))
          const _TileDef(
            label: 'Map',
            icon: Icons.map_outlined,
            route: '/home/map',
          ),
        if (c.isEnabled(AppFeature.meet))
          const _TileDef(
            label: 'Meetings',
            icon: Icons.videocam_outlined,
            route: '/home/meetings',
          ),
      ];
}

class _TileDef {
  const _TileDef({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.tile});
  final _TileDef tile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go(tile.route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(tile.icon, size: 36, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(tile.label, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
