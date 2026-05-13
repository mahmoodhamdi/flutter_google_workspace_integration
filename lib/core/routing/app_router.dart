import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_apis_flutter/core/auth/presentation/screens/register_screen.dart';
import 'package:google_apis_flutter/core/auth/presentation/screens/sign_in_screen.dart';
import 'package:google_apis_flutter/core/auth/providers/auth_providers.dart';
import 'package:google_apis_flutter/core/config/app_config.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/entities/calendar_event.dart';
import 'package:google_apis_flutter/features/google_calendar/presentation/screens/calendar_home_screen.dart';
import 'package:google_apis_flutter/features/google_calendar/presentation/screens/event_editor_screen.dart';
import 'package:google_apis_flutter/features/google_contacts/presentation/screens/contacts_list_screen.dart';
import 'package:google_apis_flutter/features/google_drive/presentation/screens/drive_browser_screen.dart';
import 'package:google_apis_flutter/features/google_gmail/presentation/screens/compose_screen.dart';
import 'package:google_apis_flutter/features/google_maps/presentation/screens/maps_demo_screen.dart';
import 'package:google_apis_flutter/features/google_meet/presentation/screens/meetings_screen.dart';
import 'package:google_apis_flutter/features/google_sheets/presentation/screens/spreadsheet_list_screen.dart';
import 'package:google_apis_flutter/features/google_sheets/presentation/screens/spreadsheet_viewer_screen.dart';
import 'package:google_apis_flutter/features/home/presentation/pages/home_page.dart';

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final config = AppConfig.fromEnvironment();
  return GoRouter(
    initialLocation: '/signin',
    redirect: (BuildContext context, GoRouterState state) {
      final active = ref.read(activeAccountProvider).valueOrNull;
      final isAuthRoute =
          state.matchedLocation == '/signin' || state.matchedLocation == '/register';
      if (active == null && !isAuthRoute) return '/signin';
      if (active != null && isAuthRoute) return '/home';
      return null;
    },
    refreshListenable: _RouterRefreshListenable(ref),
    routes: <GoRoute>[
      GoRoute(
        path: '/signin',
        builder: (_, __) => SignInScreen(config: config),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomePage(),
        routes: <RouteBase>[
          // Calendar
          GoRoute(
            path: 'calendar',
            builder: (_, __) => const CalendarHomeScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: 'new',
                builder: (_, __) => const EventEditorScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (_, state) {
                  final existing = state.extra as CalendarEvent?;
                  return EventEditorScreen(existing: existing);
                },
              ),
            ],
          ),
          // Drive
          GoRoute(
            path: 'drive',
            builder: (_, __) => const DriveBrowserScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: 'folder/:id',
                builder: (_, state) {
                  final extra = state.extra as Map<String, String?>?;
                  return DriveBrowserScreen(
                    folderId: state.pathParameters['id'],
                    folderName: extra?['name'],
                  );
                },
              ),
            ],
          ),
          // Sheets
          GoRoute(
            path: 'sheets',
            builder: (_, __) => const SpreadsheetListScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: ':id',
                builder: (_, state) => SpreadsheetViewerScreen(
                  spreadsheetId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          // Gmail compose
          GoRoute(
            path: 'compose',
            builder: (_, __) => const ComposeScreen(),
          ),
          // Contacts
          GoRoute(
            path: 'contacts',
            builder: (_, __) => const ContactsListScreen(),
          ),
          // Maps
          GoRoute(
            path: 'map',
            builder: (_, __) => const MapsDemoScreen(),
          ),
          // Meet
          GoRoute(
            path: 'meetings',
            builder: (_, __) => const MeetingsScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Adapts Riverpod's active-account stream into the [Listenable] interface
/// that GoRouter's `refreshListenable` expects.
class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(this._ref) {
    _sub = _ref.listen(
      activeAccountProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;
  late final ProviderSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
