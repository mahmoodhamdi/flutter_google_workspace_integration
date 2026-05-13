import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/entities/calendar_event.dart';
import 'package:google_apis_flutter/features/google_calendar/presentation/widgets/event_card.dart';

void main() {
  group('EventCard', () {
    testWidgets('renders event summary and time range', (tester) async {
      final ev = CalendarEvent(
        id: 'e',
        calendarId: 'primary',
        summary: 'Project Sync',
        start: DateTime(2026, 5, 13, 10),
        end: DateTime(2026, 5, 13, 11),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EventCard(event: ev)),
        ),
      );
      expect(find.text('Project Sync'), findsOneWidget);
    });

    testWidgets('shows "All day" for all-day events', (tester) async {
      final ev = CalendarEvent(
        id: 'e',
        calendarId: 'primary',
        summary: 'Vacation',
        start: DateTime(2026, 5, 13),
        end: DateTime(2026, 5, 14),
        allDay: true,
      );
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: EventCard(event: ev))),
      );
      expect(find.text('All day'), findsOneWidget);
    });

    testWidgets('shows location when present', (tester) async {
      final ev = CalendarEvent(
        id: 'e',
        calendarId: 'primary',
        summary: 'Meet',
        start: DateTime(2026, 5, 13, 10),
        end: DateTime(2026, 5, 13, 11),
        location: 'HQ Conference Room',
      );
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: EventCard(event: ev))),
      );
      expect(find.text('HQ Conference Room'), findsOneWidget);
    });

    testWidgets('shows attendees count when present', (tester) async {
      final ev = CalendarEvent(
        id: 'e',
        calendarId: 'primary',
        summary: 'Big meeting',
        start: DateTime(2026, 5, 13, 10),
        end: DateTime(2026, 5, 13, 11),
        attendees: const <EventAttendee>[
          EventAttendee(email: 'a@b.com'),
          EventAttendee(email: 'c@d.com'),
          EventAttendee(email: 'e@f.com'),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: EventCard(event: ev))),
      );
      expect(find.text('3 attendees'), findsOneWidget);
    });

    testWidgets('single attendee uses singular', (tester) async {
      final ev = CalendarEvent(
        id: 'e',
        calendarId: 'primary',
        summary: '1-on-1',
        start: DateTime(2026, 5, 13, 10),
        end: DateTime(2026, 5, 13, 11),
        attendees: const <EventAttendee>[EventAttendee(email: 'a@b.com')],
      );
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: EventCard(event: ev))),
      );
      expect(find.text('1 attendee'), findsOneWidget);
    });

    testWidgets('tapping calls onTap', (tester) async {
      bool tapped = false;
      final ev = CalendarEvent(
        id: 'e',
        calendarId: 'primary',
        summary: 'Tap me',
        start: DateTime(2026, 5, 13, 10),
        end: DateTime(2026, 5, 13, 11),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventCard(event: ev, onTap: () => tapped = true),
          ),
        ),
      );
      await tester.tap(find.text('Tap me'));
      expect(tapped, true);
    });
  });
}
