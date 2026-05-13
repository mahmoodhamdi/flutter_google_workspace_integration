import 'package:google_apis_flutter/features/google_calendar/domain/entities/calendar_event.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;

/// Maps between the `googleapis` Calendar V3 DTOs and our domain entities.
class CalendarEventMapper {
  const CalendarEventMapper._();

  // --- Calendar list ---

  static CalendarSummary toCalendarSummary(gcal.CalendarListEntry entry) {
    return CalendarSummary(
      id: entry.id ?? '',
      summary: entry.summary ?? entry.summaryOverride ?? '(no name)',
      description: entry.description,
      timeZone: entry.timeZone,
      colorId: entry.colorId,
      primary: entry.primary ?? false,
      accessRole: _parseAccess(entry.accessRole),
    );
  }

  // --- Event read ---

  static CalendarEvent toEvent(gcal.Event e, String calendarId) {
    final start = _parseDt(e.start);
    final end = _parseDt(e.end) ?? start;
    final isAllDay = e.start?.date != null;
    return CalendarEvent(
      id: e.id ?? '',
      calendarId: calendarId,
      summary: e.summary ?? '(no title)',
      description: e.description,
      location: e.location,
      start: start ?? DateTime.now(),
      end: end ?? DateTime.now(),
      allDay: isAllDay,
      attendees: (e.attendees ?? <gcal.EventAttendee>[])
          .map<EventAttendee>(_toAttendee)
          .toList(growable: false),
      reminders: _parseReminders(e.reminders),
      recurrenceRule: (e.recurrence ?? <String>[]).firstOrNull,
      recurringEventId: e.recurringEventId,
      organizerEmail: e.organizer?.email,
      status: _parseStatus(e.status),
      hangoutLink: e.hangoutLink,
      meetLink: _meetLinkFromConferenceData(e.conferenceData),
      created: e.created,
      updated: e.updated,
      etag: e.etag,
    );
  }

  // --- Event write ---

  static gcal.Event toApi(CalendarEvent e) {
    return gcal.Event(
      id: e.id.isEmpty ? null : e.id,
      summary: e.summary,
      description: e.description,
      location: e.location,
      start: e.allDay
          ? gcal.EventDateTime(date: _dateOnly(e.start))
          : gcal.EventDateTime(dateTime: e.start.toUtc()),
      end: e.allDay
          ? gcal.EventDateTime(date: _dateOnly(e.end))
          : gcal.EventDateTime(dateTime: e.end.toUtc()),
      attendees: e.attendees
          .map<gcal.EventAttendee>(
            (a) => gcal.EventAttendee(
              email: a.email,
              displayName: a.displayName,
              responseStatus: _attendeeResponseToApi(a.response),
              optional: a.optional ? true : null,
              organizer: a.organizer ? true : null,
            ),
          )
          .toList(),
      recurrence: e.recurrenceRule == null ? null : <String>[e.recurrenceRule!],
      reminders: gcal.EventReminders(
        useDefault: e.reminders.isEmpty,
        overrides: e.reminders.isEmpty
            ? null
            : e.reminders
                .map(
                  (r) => gcal.EventReminder(
                    method: r.method == ReminderMethod.popup ? 'popup' : 'email',
                    minutes: r.minutesBefore,
                  ),
                )
                .toList(),
      ),
      conferenceData: e.meetLink != null
          ? gcal.ConferenceData(
              createRequest: gcal.CreateConferenceRequest(
                requestId: 'gws-${DateTime.now().millisecondsSinceEpoch}',
                conferenceSolutionKey: gcal.ConferenceSolutionKey(
                  type: 'hangoutsMeet',
                ),
              ),
            )
          : null,
    );
  }

  // --- Helpers ---

  static EventAttendee _toAttendee(gcal.EventAttendee a) => EventAttendee(
        email: a.email ?? '',
        displayName: a.displayName,
        response: _parseAttendeeResponse(a.responseStatus),
        optional: a.optional ?? false,
        organizer: a.organizer ?? false,
      );

  static DateTime? _parseDt(gcal.EventDateTime? edt) {
    if (edt == null) return null;
    return edt.dateTime ?? (edt.date != null ? DateTime(edt.date!.year, edt.date!.month, edt.date!.day) : null);
  }

  static DateTime? _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static List<EventReminder> _parseReminders(gcal.EventReminders? r) {
    if (r?.overrides == null) return const <EventReminder>[];
    return r!.overrides!
        .map((o) => EventReminder(
              method: o.method == 'email' ? ReminderMethod.email : ReminderMethod.popup,
              minutesBefore: o.minutes ?? 10,
            ))
        .toList(growable: false);
  }

  static EventStatus? _parseStatus(String? s) => switch (s) {
        'confirmed' => EventStatus.confirmed,
        'tentative' => EventStatus.tentative,
        'cancelled' => EventStatus.cancelled,
        _ => null,
      };

  static AttendeeResponse _parseAttendeeResponse(String? s) => switch (s) {
        'accepted' => AttendeeResponse.accepted,
        'declined' => AttendeeResponse.declined,
        'tentative' => AttendeeResponse.tentative,
        _ => AttendeeResponse.needsAction,
      };

  static String _attendeeResponseToApi(AttendeeResponse r) => switch (r) {
        AttendeeResponse.accepted => 'accepted',
        AttendeeResponse.declined => 'declined',
        AttendeeResponse.tentative => 'tentative',
        AttendeeResponse.needsAction => 'needsAction',
      };

  static CalendarAccessRole _parseAccess(String? r) => switch (r) {
        'freeBusyReader' => CalendarAccessRole.freeBusyReader,
        'reader' => CalendarAccessRole.reader,
        'writer' => CalendarAccessRole.writer,
        'owner' => CalendarAccessRole.owner,
        _ => CalendarAccessRole.reader,
      };

  static String? _meetLinkFromConferenceData(gcal.ConferenceData? cd) {
    if (cd?.entryPoints == null) return null;
    final entry = cd!.entryPoints!
        .firstWhere((e) => e.entryPointType == 'video', orElse: () => gcal.EntryPoint());
    return entry.uri;
  }
}
