import 'package:flutter/foundation.dart';

/// Per-flavor configuration. The compile-time `--dart-define` flag `FLAVOR`
/// selects the variant; defaults to "base" for the all-in-one starter kit.
enum AppFlavor {
  base,
  bizcalendar,
  drivevault,
  sheetsops,
  meetcompanion;

  static AppFlavor fromString(String? value) {
    return switch (value) {
      'bizcalendar' => AppFlavor.bizcalendar,
      'drivevault' => AppFlavor.drivevault,
      'sheetsops' => AppFlavor.sheetsops,
      'meetcompanion' => AppFlavor.meetcompanion,
      _ => AppFlavor.base,
    };
  }
}

@immutable
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.bundleId,
    required this.primaryColorHex,
    required this.enabledFeatures,
    required this.requiredOAuthScopes,
    required this.supportEmail,
    required this.privacyPolicyUrl,
    required this.termsOfServiceUrl,
    required this.googleMapsApiKey,
    this.demoMode = false,
  });

  factory AppConfig.fromFlavor(AppFlavor flavor) {
    return switch (flavor) {
      AppFlavor.base => const AppConfig(
          flavor: AppFlavor.base,
          appName: 'Workspace Hub',
          bundleId: 'com.workspacehub.app',
          primaryColorHex: '#4F46E5',
          enabledFeatures: <AppFeature>{
            AppFeature.calendar,
            AppFeature.drive,
            AppFeature.sheets,
            AppFeature.gmailSend,
            AppFeature.contacts,
            AppFeature.maps,
            AppFeature.meet,
          },
          requiredOAuthScopes: <String>{
            'https://www.googleapis.com/auth/calendar',
            'https://www.googleapis.com/auth/drive.file',
            'https://www.googleapis.com/auth/drive.metadata.readonly',
            'https://www.googleapis.com/auth/spreadsheets',
            'https://www.googleapis.com/auth/gmail.send',
            'https://www.googleapis.com/auth/contacts',
            'https://www.googleapis.com/auth/userinfo.email',
            'https://www.googleapis.com/auth/userinfo.profile',
          },
          supportEmail: 'support@workspacehub.app',
          privacyPolicyUrl: 'https://workspacehub.app/privacy',
          termsOfServiceUrl: 'https://workspacehub.app/terms',
          googleMapsApiKey: String.fromEnvironment('GOOGLE_MAPS_API_KEY'),
        ),
      AppFlavor.bizcalendar => const AppConfig(
          flavor: AppFlavor.bizcalendar,
          appName: 'BizCalendar',
          bundleId: 'com.workspacehub.bizcalendar',
          primaryColorHex: '#0F766E',
          enabledFeatures: <AppFeature>{
            AppFeature.calendar,
            AppFeature.contacts,
            AppFeature.meet,
          },
          requiredOAuthScopes: <String>{
            'https://www.googleapis.com/auth/calendar',
            'https://www.googleapis.com/auth/contacts',
            'https://www.googleapis.com/auth/userinfo.email',
            'https://www.googleapis.com/auth/userinfo.profile',
          },
          supportEmail: 'support@bizcalendar.app',
          privacyPolicyUrl: 'https://bizcalendar.app/privacy',
          termsOfServiceUrl: 'https://bizcalendar.app/terms',
          googleMapsApiKey: String.fromEnvironment('GOOGLE_MAPS_API_KEY'),
        ),
      AppFlavor.drivevault => const AppConfig(
          flavor: AppFlavor.drivevault,
          appName: 'DriveVault',
          bundleId: 'com.workspacehub.drivevault',
          primaryColorHex: '#7C3AED',
          enabledFeatures: <AppFeature>{
            AppFeature.drive,
          },
          requiredOAuthScopes: <String>{
            'https://www.googleapis.com/auth/drive.file',
            'https://www.googleapis.com/auth/drive.metadata.readonly',
            'https://www.googleapis.com/auth/userinfo.email',
            'https://www.googleapis.com/auth/userinfo.profile',
          },
          supportEmail: 'support@drivevault.app',
          privacyPolicyUrl: 'https://drivevault.app/privacy',
          termsOfServiceUrl: 'https://drivevault.app/terms',
          googleMapsApiKey: '',
        ),
      AppFlavor.sheetsops => const AppConfig(
          flavor: AppFlavor.sheetsops,
          appName: 'SheetsOps',
          bundleId: 'com.workspacehub.sheetsops',
          primaryColorHex: '#DC2626',
          enabledFeatures: <AppFeature>{
            AppFeature.sheets,
            AppFeature.dashboards,
          },
          requiredOAuthScopes: <String>{
            'https://www.googleapis.com/auth/spreadsheets',
            'https://www.googleapis.com/auth/userinfo.email',
            'https://www.googleapis.com/auth/userinfo.profile',
          },
          supportEmail: 'support@sheetsops.app',
          privacyPolicyUrl: 'https://sheetsops.app/privacy',
          termsOfServiceUrl: 'https://sheetsops.app/terms',
          googleMapsApiKey: '',
        ),
      AppFlavor.meetcompanion => const AppConfig(
          flavor: AppFlavor.meetcompanion,
          appName: 'MeetCompanion',
          bundleId: 'com.workspacehub.meetcompanion',
          primaryColorHex: '#EA580C',
          enabledFeatures: <AppFeature>{
            AppFeature.calendar,
            AppFeature.meet,
            AppFeature.drive,
          },
          requiredOAuthScopes: <String>{
            'https://www.googleapis.com/auth/calendar.events',
            'https://www.googleapis.com/auth/drive.file',
            'https://www.googleapis.com/auth/userinfo.email',
            'https://www.googleapis.com/auth/userinfo.profile',
          },
          supportEmail: 'support@meetcompanion.app',
          privacyPolicyUrl: 'https://meetcompanion.app/privacy',
          termsOfServiceUrl: 'https://meetcompanion.app/terms',
          googleMapsApiKey: '',
        ),
    };
  }

  factory AppConfig.fromEnvironment() {
    const flavorName = String.fromEnvironment('FLAVOR', defaultValue: 'base');
    return AppConfig.fromFlavor(AppFlavor.fromString(flavorName));
  }

  final AppFlavor flavor;
  final String appName;
  final String bundleId;
  final String primaryColorHex;
  final Set<AppFeature> enabledFeatures;
  final Set<String> requiredOAuthScopes;
  final String supportEmail;
  final String privacyPolicyUrl;
  final String termsOfServiceUrl;
  final String googleMapsApiKey;
  final bool demoMode;

  bool isEnabled(AppFeature f) => enabledFeatures.contains(f);
}

enum AppFeature {
  calendar,
  drive,
  sheets,
  gmailSend,
  contacts,
  maps,
  meet,
  dashboards;
}
