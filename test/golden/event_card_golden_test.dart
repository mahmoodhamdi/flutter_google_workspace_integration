import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/entities/calendar_event.dart';
import 'package:google_apis_flutter/features/google_calendar/presentation/widgets/event_card.dart';

void main() {
  group('EventCard goldens', () {
    testGoldens('renders consistently across themes & sizes', (tester) async {
      final ev = CalendarEvent(
        id: 'e1',
        calendarId: 'primary',
        summary: 'Team Standup',
        location: 'HQ Conference Room',
        start: DateTime(2026, 5, 13, 10),
        end: DateTime(2026, 5, 13, 10, 30),
        attendees: const <EventAttendee>[
          EventAttendee(email: 'a@example.com'),
          EventAttendee(email: 'b@example.com'),
        ],
      );
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: <Device>[
          Device.phone,
          Device.iphone11,
        ])
        ..addScenario(
          widget: SizedBox(width: 320, child: EventCard(event: ev)),
          name: 'light',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'event_card_themes_sizes');
    });
  });
}
