import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/entities/calendar_event.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/repositories/calendar_repository.dart';

/// Use case: list events in the primary calendar for a date range.
class GetCalendarEvents {
  const GetCalendarEvents(this._repo);
  final CalendarRepository _repo;

  Future<Result<List<CalendarEvent>>> call({
    String calendarId = 'primary',
    DateTime? from,
    DateTime? to,
    int maxResults = 50,
    String? query,
  }) =>
      _repo.listEvents(
        calendarId: calendarId,
        timeMin: from,
        timeMax: to,
        maxResults: maxResults,
        query: query,
      );
}

class CreateCalendarEvent {
  const CreateCalendarEvent(this._repo);
  final CalendarRepository _repo;

  Future<Result<CalendarEvent>> call({
    String calendarId = 'primary',
    required CalendarEvent event,
    bool sendUpdates = true,
  }) =>
      _repo.createEvent(
        calendarId: calendarId,
        event: event,
        sendUpdates: sendUpdates,
      );
}

class UpdateCalendarEvent {
  const UpdateCalendarEvent(this._repo);
  final CalendarRepository _repo;

  Future<Result<CalendarEvent>> call({
    String calendarId = 'primary',
    required CalendarEvent event,
    bool sendUpdates = true,
  }) =>
      _repo.updateEvent(
        calendarId: calendarId,
        event: event,
        sendUpdates: sendUpdates,
      );
}

class DeleteCalendarEvent {
  const DeleteCalendarEvent(this._repo);
  final CalendarRepository _repo;

  Future<Result<void>> call({
    String calendarId = 'primary',
    required String eventId,
    bool sendUpdates = true,
  }) =>
      _repo.deleteEvent(
        calendarId: calendarId,
        eventId: eventId,
        sendUpdates: sendUpdates,
      );
}

class FindFreeSlot {
  const FindFreeSlot(this._repo);
  final CalendarRepository _repo;

  Future<Result<DateTime?>> call({
    required List<String> attendees,
    required DateTime from,
    required DateTime until,
    required Duration duration,
    int workingHoursStart = 9,
    int workingHoursEnd = 17,
  }) =>
      _repo.findFreeSlot(
        attendees: attendees,
        from: from,
        until: until,
        duration: duration,
        workingHoursStart: workingHoursStart,
        workingHoursEnd: workingHoursEnd,
      );
}
