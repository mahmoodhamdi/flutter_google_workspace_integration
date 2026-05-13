import 'package:google_apis_flutter/core/errors/app_error.dart';
import 'package:google_apis_flutter/core/errors/guard.dart';
import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/entities/calendar_event.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/repositories/calendar_repository.dart';
import 'package:google_apis_flutter/features/google_meet/domain/entities/meeting.dart';

class MeetService {
  MeetService(this._calendar);
  final CalendarRepository _calendar;

  /// Schedule a Meet by creating a calendar event with `conferenceData`.
  Future<Result<Meeting>> scheduleMeeting({
    required String title,
    required DateTime start,
    required DateTime end,
    String? description,
    List<String> attendees = const <String>[],
  }) {
    return guard<Meeting>(() async {
      final event = CalendarEvent(
        id: '',
        calendarId: 'primary',
        summary: title,
        description: description,
        start: start,
        end: end,
        attendees: attendees
            .map((email) => EventAttendee(email: email))
            .toList(growable: false),
        meetLink: 'pending', // signals to the mapper to add conferenceData
      );
      final created = await _calendar.createEvent(
        calendarId: 'primary',
        event: event,
      );
      return created.fold(
        (err) => throw err,
        (e) => _toMeeting(e),
      );
    }, operation: 'meet.schedule');
  }

  Future<Result<List<Meeting>>> listUpcoming({int days = 14}) =>
      guard<List<Meeting>>(() async {
        final now = DateTime.now();
        final list = await _calendar.listEvents(
          calendarId: 'primary',
          timeMin: now,
          timeMax: now.add(Duration(days: days)),
          maxResults: 50,
        );
        return list.fold(
          (err) => throw err,
          (events) => events
              .where((e) => e.meetLink != null && e.meetLink!.isNotEmpty)
              .map(_toMeeting)
              .toList(growable: false),
        );
      }, operation: 'meet.listUpcoming');

  Future<Result<void>> cancelMeeting(String eventId) =>
      _calendar.deleteEvent(calendarId: 'primary', eventId: eventId);

  Meeting _toMeeting(CalendarEvent e) {
    if (e.meetLink == null || e.meetLink!.isEmpty) {
      throw const AppError.notFound(
        message: 'Event does not have a Meet link',
      );
    }
    final now = DateTime.now();
    return Meeting(
      calendarEventId: e.id,
      title: e.summary,
      start: e.start,
      end: e.end,
      meetLink: e.meetLink!,
      description: e.description,
      attendeeEmails: e.attendees.map((a) => a.email).toList(growable: false),
      status: e.status == EventStatus.cancelled
          ? MeetingStatus.cancelled
          : (now.isAfter(e.end)
              ? MeetingStatus.ended
              : (now.isAfter(e.start)
                  ? MeetingStatus.inProgress
                  : MeetingStatus.scheduled)),
    );
  }
}
