import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/entities/calendar_event.dart';

abstract class CalendarRepository {
  Future<Result<List<CalendarSummary>>> listCalendars();

  Future<Result<List<CalendarEvent>>> listEvents({
    required String calendarId,
    DateTime? timeMin,
    DateTime? timeMax,
    int maxResults = 50,
    String? query,
    String? pageToken,
  });

  Future<Result<CalendarEvent>> getEvent({
    required String calendarId,
    required String eventId,
  });

  Future<Result<CalendarEvent>> createEvent({
    required String calendarId,
    required CalendarEvent event,
    bool sendUpdates = true,
  });

  Future<Result<CalendarEvent>> updateEvent({
    required String calendarId,
    required CalendarEvent event,
    bool sendUpdates = true,
  });

  Future<Result<void>> deleteEvent({
    required String calendarId,
    required String eventId,
    bool sendUpdates = true,
  });

  Future<Result<CalendarEvent>> rsvp({
    required String calendarId,
    required String eventId,
    required AttendeeResponse response,
    required String attendeeEmail,
  });

  Future<Result<List<CalendarEvent>>> freeBusy({
    required List<String> calendarIds,
    required DateTime timeMin,
    required DateTime timeMax,
  });

  /// Find the next [duration] slot when all [attendees] are free between
  /// [from] and [until], respecting working hours.
  Future<Result<DateTime?>> findFreeSlot({
    required List<String> attendees,
    required DateTime from,
    required DateTime until,
    required Duration duration,
    int workingHoursStart = 9,
    int workingHoursEnd = 17,
  });
}
