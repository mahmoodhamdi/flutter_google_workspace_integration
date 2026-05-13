import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/features/google_meet/domain/entities/meeting.dart';

void main() {
  Meeting _m({
    required DateTime start,
    required DateTime end,
    MeetingStatus status = MeetingStatus.scheduled,
  }) =>
      Meeting(
        calendarEventId: 'evt',
        title: 'Standup',
        start: start,
        end: end,
        meetLink: 'https://meet.google.com/abc',
        status: status,
      );

  group('Meeting.duration', () {
    test('end - start', () {
      final m = _m(
        start: DateTime(2026, 5, 13, 10),
        end: DateTime(2026, 5, 13, 10, 45),
      );
      expect(m.duration, const Duration(minutes: 45));
    });
  });

  group('Meeting.isUpcoming', () {
    test('future start', () {
      final m = _m(
        start: DateTime.now().add(const Duration(hours: 1)),
        end: DateTime.now().add(const Duration(hours: 2)),
      );
      expect(m.isUpcoming, true);
    });

    test('past start', () {
      final m = _m(
        start: DateTime.now().subtract(const Duration(hours: 2)),
        end: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(m.isUpcoming, false);
    });
  });

  group('Meeting.isInProgress', () {
    test('current time between start and end', () {
      final m = _m(
        start: DateTime.now().subtract(const Duration(minutes: 5)),
        end: DateTime.now().add(const Duration(minutes: 25)),
      );
      expect(m.isInProgress, true);
    });

    test('not yet started', () {
      final m = _m(
        start: DateTime.now().add(const Duration(minutes: 5)),
        end: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(m.isInProgress, false);
    });

    test('already ended', () {
      final m = _m(
        start: DateTime.now().subtract(const Duration(hours: 2)),
        end: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(m.isInProgress, false);
    });
  });

  group('MeetingStatus enum', () {
    test('all statuses defined', () {
      expect(MeetingStatus.values, hasLength(4));
      expect(MeetingStatus.values.toSet(), <MeetingStatus>{
        MeetingStatus.scheduled,
        MeetingStatus.inProgress,
        MeetingStatus.ended,
        MeetingStatus.cancelled,
      });
    });
  });
}
