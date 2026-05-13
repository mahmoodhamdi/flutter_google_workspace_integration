import 'dart:convert';

import 'package:google_apis_flutter/core/errors/app_error.dart';
import 'package:google_apis_flutter/core/errors/guard.dart';
import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/core/storage/hive_init.dart';
import 'package:google_apis_flutter/features/google_calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:google_apis_flutter/features/google_calendar/data/models/calendar_event_mapper.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/entities/calendar_event.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/repositories/calendar_repository.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;

class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl(this._remote);
  final CalendarRemoteDataSource _remote;

  @override
  Future<Result<List<CalendarSummary>>> listCalendars() =>
      guardWithRetry<List<CalendarSummary>>(() async {
        final r = await _remote.listCalendars();
        final items = r.items ?? const <gcal.CalendarListEntry>[];
        return items
            .map<CalendarSummary>(CalendarEventMapper.toCalendarSummary)
            .toList(growable: false);
      }, operation: 'calendar.listCalendars');

  @override
  Future<Result<List<CalendarEvent>>> listEvents({
    required String calendarId,
    DateTime? timeMin,
    DateTime? timeMax,
    int maxResults = 50,
    String? query,
    String? pageToken,
  }) async {
    final cacheKey = 'list:$calendarId:${timeMin?.toIso8601String() ?? ''}:${timeMax?.toIso8601String() ?? ''}';
    return guardWithRetry<List<CalendarEvent>>(() async {
      final r = await _remote.listEvents(
        calendarId: calendarId,
        timeMin: timeMin,
        timeMax: timeMax,
        maxResults: maxResults,
        query: query,
        pageToken: pageToken,
      );
      final items = r.items ?? const <gcal.Event>[];
      final events = items
          .map<CalendarEvent>(
            (e) => CalendarEventMapper.toEvent(e, calendarId),
          )
          .toList(growable: false);
      await _cacheEvents(cacheKey, events);
      return events;
    }, operation: 'calendar.listEvents');
  }

  @override
  Future<Result<CalendarEvent>> getEvent({
    required String calendarId,
    required String eventId,
  }) =>
      guardWithRetry<CalendarEvent>(() async {
        final raw = await _remote.getEvent(calendarId, eventId);
        return CalendarEventMapper.toEvent(raw, calendarId);
      }, operation: 'calendar.getEvent');

  @override
  Future<Result<CalendarEvent>> createEvent({
    required String calendarId,
    required CalendarEvent event,
    bool sendUpdates = true,
  }) =>
      guard<CalendarEvent>(() async {
        final raw = await _remote.insertEvent(
          calendarId: calendarId,
          event: CalendarEventMapper.toApi(event),
          sendUpdates: sendUpdates,
        );
        return CalendarEventMapper.toEvent(raw, calendarId);
      }, operation: 'calendar.createEvent');

  @override
  Future<Result<CalendarEvent>> updateEvent({
    required String calendarId,
    required CalendarEvent event,
    bool sendUpdates = true,
  }) =>
      guard<CalendarEvent>(() async {
        if (event.id.isEmpty) {
          throw const AppError.validation(message: 'Event id required');
        }
        final raw = await _remote.updateEvent(
          calendarId: calendarId,
          eventId: event.id,
          event: CalendarEventMapper.toApi(event),
          sendUpdates: sendUpdates,
        );
        return CalendarEventMapper.toEvent(raw, calendarId);
      }, operation: 'calendar.updateEvent');

  @override
  Future<Result<void>> deleteEvent({
    required String calendarId,
    required String eventId,
    bool sendUpdates = true,
  }) =>
      guard<void>(() => _remote.deleteEvent(
            calendarId: calendarId,
            eventId: eventId,
            sendUpdates: sendUpdates,
          ),
          operation: 'calendar.deleteEvent');

  @override
  Future<Result<CalendarEvent>> rsvp({
    required String calendarId,
    required String eventId,
    required AttendeeResponse response,
    required String attendeeEmail,
  }) =>
      guard<CalendarEvent>(() async {
        final existing = await _remote.getEvent(calendarId, eventId);
        final domain = CalendarEventMapper.toEvent(existing, calendarId);
        final updatedAttendees = domain.attendees.map((a) {
          if (a.email.toLowerCase() == attendeeEmail.toLowerCase()) {
            return a.copyWith(response: response);
          }
          return a;
        }).toList(growable: false);
        final patched = domain.copyWith(attendees: updatedAttendees);
        final raw = await _remote.updateEvent(
          calendarId: calendarId,
          eventId: eventId,
          event: CalendarEventMapper.toApi(patched),
          sendUpdates: false,
        );
        return CalendarEventMapper.toEvent(raw, calendarId);
      }, operation: 'calendar.rsvp');

  @override
  Future<Result<List<CalendarEvent>>> freeBusy({
    required List<String> calendarIds,
    required DateTime timeMin,
    required DateTime timeMax,
  }) =>
      guardWithRetry<List<CalendarEvent>>(() async {
        final r = await _remote.freeBusy(
          calendarIds: calendarIds,
          timeMin: timeMin,
          timeMax: timeMax,
        );
        final busy = <CalendarEvent>[];
        r.calendars?.forEach((id, info) {
          info.busy?.forEach((slot) {
            busy.add(
              CalendarEvent(
                id: '$id|${slot.start?.millisecondsSinceEpoch}',
                calendarId: id,
                summary: '(busy)',
                start: slot.start!.toLocal(),
                end: slot.end!.toLocal(),
              ),
            );
          });
        });
        return busy;
      }, operation: 'calendar.freeBusy');

  @override
  Future<Result<DateTime?>> findFreeSlot({
    required List<String> attendees,
    required DateTime from,
    required DateTime until,
    required Duration duration,
    int workingHoursStart = 9,
    int workingHoursEnd = 17,
  }) =>
      guard<DateTime?>(() async {
        final busyRes = await freeBusy(
          calendarIds: attendees,
          timeMin: from,
          timeMax: until,
        );
        final busy = busyRes.fold<List<CalendarEvent>>(
          (_) => <CalendarEvent>[],
          (events) => events,
        );
        // Sort busy intervals by start.
        final sortedBusy = [...busy]..sort((a, b) => a.start.compareTo(b.start));

        // Walk candidate slots in 15-minute steps within working hours.
        DateTime cursor = from;
        while (cursor.add(duration).isBefore(until.add(const Duration(seconds: 1)))) {
          // Snap to working hours.
          final localHour = cursor.hour;
          if (localHour < workingHoursStart) {
            cursor = DateTime(cursor.year, cursor.month, cursor.day,
                workingHoursStart);
            continue;
          }
          if (cursor.add(duration).hour > workingHoursEnd ||
              localHour >= workingHoursEnd) {
            // Next day.
            cursor = DateTime(cursor.year, cursor.month, cursor.day + 1,
                workingHoursStart);
            continue;
          }
          final candidateEnd = cursor.add(duration);
          final overlapsBusy = sortedBusy.any((b) =>
              cursor.isBefore(b.end) && b.start.isBefore(candidateEnd));
          if (!overlapsBusy) {
            return cursor;
          }
          cursor = cursor.add(const Duration(minutes: 15));
        }
        return null;
      }, operation: 'calendar.findFreeSlot');

  Future<void> _cacheEvents(String key, List<CalendarEvent> events) async {
    try {
      final box = cacheBox('calendar');
      await box.put(
        key,
        jsonEncode(events.map((e) => e.toJson()).toList()),
      );
    } catch (_) {
      // best-effort; cache failures are non-fatal.
    }
  }
}
