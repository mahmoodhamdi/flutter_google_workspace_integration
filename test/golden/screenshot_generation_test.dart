/// Programmatic screenshot generation for marketing.
///
/// Runs as part of the goldens suite. Each scenario renders a key screen
/// in 4 variants (light/dark × AR/EN) and writes a PNG that's checked
/// against a baseline. Re-running with `--update-goldens` produces fresh
/// PNGs we ship as `marketing/screenshots/<vertical>/`.
///
/// To regenerate marketing screenshots:
///   flutter test --update-goldens test/golden/screenshot_generation_test.dart
///   cp test/golden/goldens/* marketing/screenshots/base/
///
/// The same infrastructure can be reused per-vertical by overriding the
/// AppConfig in test setup.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/entities/calendar_event.dart';
import 'package:google_apis_flutter/features/google_calendar/presentation/widgets/event_card.dart';
import 'package:google_apis_flutter/features/google_drive/domain/entities/drive_file.dart';
import 'package:google_apis_flutter/features/google_drive/presentation/widgets/drive_file_tile.dart';
import 'package:google_apis_flutter/features/google_drive/presentation/widgets/storage_indicator.dart';

void main() {
  group('Marketing screenshot generation', () {
    final samples = <CalendarEvent>[
      CalendarEvent(
        id: 'evt-1',
        calendarId: 'primary',
        summary: 'Q2 OKR Review',
        location: 'HQ — Mahogany Room',
        start: DateTime(2026, 5, 13, 10),
        end: DateTime(2026, 5, 13, 11),
        attendees: const <EventAttendee>[
          EventAttendee(email: 'alice@example.com'),
          EventAttendee(email: 'bob@example.com'),
          EventAttendee(email: 'carol@example.com'),
        ],
      ),
      CalendarEvent(
        id: 'evt-2',
        calendarId: 'primary',
        summary: '1:1 with manager',
        start: DateTime(2026, 5, 13, 14),
        end: DateTime(2026, 5, 13, 14, 30),
      ),
      CalendarEvent(
        id: 'evt-3',
        calendarId: 'primary',
        summary: 'Team Standup',
        start: DateTime(2026, 5, 13, 9),
        end: DateTime(2026, 5, 13, 9, 30),
        meetLink: 'https://meet.google.com/abc-defg-hij',
      ),
    ];

    final files = <DriveFile>[
      DriveFile(
        id: 'f1',
        name: 'Q2_strategy.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 2 * 1024 * 1024,
        modifiedTime: DateTime(2026, 5, 10),
      ),
      DriveFile(
        id: 'f2',
        name: 'Team_photos',
        mimeType: 'application/vnd.google-apps.folder',
      ),
      DriveFile(
        id: 'f3',
        name: 'Forecast.xlsx',
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        sizeBytes: 380 * 1024,
        modifiedTime: DateTime(2026, 5, 12),
      ),
    ];

    testGoldens('event card hero', (tester) async {
      await tester.pumpWidgetBuilder(
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: samples
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: EventCard(event: e),
                    ))
                .toList(),
          ),
        ),
        surfaceSize: const Size(360, 360),
      );
      await screenMatchesGolden(tester, 'marketing_event_cards');
    });

    testGoldens('drive file list hero', (tester) async {
      await tester.pumpWidgetBuilder(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const StorageIndicator(
              DriveStorageQuota(
                usageBytes: 8 * 1024 * 1024 * 1024,
                limitBytes: 15 * 1024 * 1024 * 1024,
              ),
            ),
            const Divider(),
            ...files.map((f) => DriveFileTile(
                  file: f,
                  onTap: () {},
                  onShare: () {},
                  onDelete: () {},
                  onRename: () {},
                )),
          ],
        ),
        surfaceSize: const Size(360, 400),
      );
      await screenMatchesGolden(tester, 'marketing_drive_list');
    });
  });
}
