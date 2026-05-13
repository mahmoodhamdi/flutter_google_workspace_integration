import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/entities/calendar_event.dart';

void main() {
  CalendarEvent _ev({
    String id = 'e1',
    required DateTime start,
    required DateTime end,
    String summary = 'Meeting',
    bool allDay = false,
  }) =>
      CalendarEvent(
        id: id,
        calendarId: 'primary',
        summary: summary,
        start: start,
        end: end,
        allDay: allDay,
      );

  group('CalendarEvent.duration', () {
    test('returns end - start', () {
      final ev = _ev(
        start: DateTime(2026, 5, 13, 10),
        end: DateTime(2026, 5, 13, 11, 30),
      );
      expect(ev.duration, const Duration(hours: 1, minutes: 30));
    });

    test('zero duration for instant events', () {
      final now = DateTime(2026, 5, 13, 10);
      final ev = _ev(start: now, end: now);
      expect(ev.duration, Duration.zero);
    });
  });

  group('CalendarEvent.overlaps', () {
    test('returns true for overlapping windows', () {
      final a = _ev(
        start: DateTime(2026, 5, 13, 10),
        end: DateTime(2026, 5, 13, 11),
      );
      final b = _ev(
        id: 'e2',
        start: DateTime(2026, 5, 13, 10, 30),
        end: DateTime(2026, 5, 13, 12),
      );
      expect(a.overlaps(b), true);
      expect(b.overlaps(a), true);
    });

    test('returns false for adjacent (touching) events', () {
      final a = _ev(
        start: DateTime(2026, 5, 13, 10),
        end: DateTime(2026, 5, 13, 11),
      );
      final b = _ev(
        id: 'e2',
        start: DateTime(2026, 5, 13, 11),
        end: DateTime(2026, 5, 13, 12),
      );
      expect(a.overlaps(b), false);
    });

    test('returns false for separated events', () {
      final a = _ev(
        start: DateTime(2026, 5, 13, 10),
        end: DateTime(2026, 5, 13, 11),
      );
      final b = _ev(
        id: 'e2',
        start: DateTime(2026, 5, 13, 12),
        end: DateTime(2026, 5, 13, 13),
      );
      expect(a.overlaps(b), false);
    });

    test('overlap test handles same-instant boundary cases', () {
      final a = _ev(
        start: DateTime(2026, 5, 13, 10),
        end: DateTime(2026, 5, 13, 10),
      );
      final b = _ev(
        id: 'e2',
        start: DateTime(2026, 5, 13, 9),
        end: DateTime(2026, 5, 13, 11),
      );
      expect(a.overlaps(b), false);
    });
  });

  group('CalendarEvent JSON roundtrip', () {
    test('serializes and deserializes through fromJson/toJson', () {
      final original = CalendarEvent(
        id: 'evt-1',
        calendarId: 'primary',
        summary: 'Standup',
        description: 'Daily',
        location: 'HQ',
        start: DateTime.utc(2026, 5, 13, 9),
        end: DateTime.utc(2026, 5, 13, 9, 30),
        attendees: const <EventAttendee>[
          EventAttendee(
            email: 'a@example.com',
            response: AttendeeResponse.accepted,
            organizer: true,
          ),
          EventAttendee(email: 'b@example.com', optional: true),
        ],
        reminders: const <EventReminder>[
          EventReminder(method: ReminderMethod.popup, minutesBefore: 10),
        ],
        status: EventStatus.confirmed,
      );
      final json = original.toJson();
      final back = CalendarEvent.fromJson(json);
      expect(back, original);
    });
  });
}
