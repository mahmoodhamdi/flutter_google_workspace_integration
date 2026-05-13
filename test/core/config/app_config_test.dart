import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/core/config/app_config.dart';

void main() {
  group('AppFlavor.fromString', () {
    test('parses known values', () {
      expect(AppFlavor.fromString('bizcalendar'), AppFlavor.bizcalendar);
      expect(AppFlavor.fromString('drivevault'), AppFlavor.drivevault);
      expect(AppFlavor.fromString('sheetsops'), AppFlavor.sheetsops);
      expect(AppFlavor.fromString('meetcompanion'), AppFlavor.meetcompanion);
    });

    test('defaults to base for unknown / null / empty', () {
      expect(AppFlavor.fromString(null), AppFlavor.base);
      expect(AppFlavor.fromString(''), AppFlavor.base);
      expect(AppFlavor.fromString('xyz'), AppFlavor.base);
    });
  });

  group('AppConfig.fromFlavor', () {
    test('base has all 7 features enabled', () {
      final c = AppConfig.fromFlavor(AppFlavor.base);
      expect(c.appName, 'Workspace Hub');
      expect(c.isEnabled(AppFeature.calendar), true);
      expect(c.isEnabled(AppFeature.drive), true);
      expect(c.isEnabled(AppFeature.sheets), true);
      expect(c.isEnabled(AppFeature.gmailSend), true);
      expect(c.isEnabled(AppFeature.contacts), true);
      expect(c.isEnabled(AppFeature.maps), true);
      expect(c.isEnabled(AppFeature.meet), true);
    });

    test('bizcalendar enables calendar/contacts/meet only', () {
      final c = AppConfig.fromFlavor(AppFlavor.bizcalendar);
      expect(c.isEnabled(AppFeature.calendar), true);
      expect(c.isEnabled(AppFeature.contacts), true);
      expect(c.isEnabled(AppFeature.meet), true);
      expect(c.isEnabled(AppFeature.drive), false);
      expect(c.isEnabled(AppFeature.sheets), false);
      expect(c.isEnabled(AppFeature.gmailSend), false);
    });

    test('drivevault enables drive only', () {
      final c = AppConfig.fromFlavor(AppFlavor.drivevault);
      expect(c.enabledFeatures, <AppFeature>{AppFeature.drive});
    });

    test('sheetsops enables sheets + dashboards', () {
      final c = AppConfig.fromFlavor(AppFlavor.sheetsops);
      expect(c.isEnabled(AppFeature.sheets), true);
      expect(c.isEnabled(AppFeature.dashboards), true);
    });

    test('meetcompanion enables calendar + meet + drive', () {
      final c = AppConfig.fromFlavor(AppFlavor.meetcompanion);
      expect(c.isEnabled(AppFeature.calendar), true);
      expect(c.isEnabled(AppFeature.meet), true);
      expect(c.isEnabled(AppFeature.drive), true);
      expect(c.isEnabled(AppFeature.gmailSend), false);
    });
  });

  group('OAuth scope safety (no restricted scopes)', () {
    final restricted = <String>{
      'https://mail.google.com/',
      'https://www.googleapis.com/auth/gmail.modify',
      'https://www.googleapis.com/auth/gmail.readonly',
      'https://www.googleapis.com/auth/drive',
      'https://www.googleapis.com/auth/drive.readonly',
    };

    for (final flavor in AppFlavor.values) {
      test('${flavor.name} uses zero restricted scopes', () {
        final c = AppConfig.fromFlavor(flavor);
        for (final s in c.requiredOAuthScopes) {
          expect(restricted.contains(s), false, reason: 'restricted: $s');
        }
      });
    }
  });
}
