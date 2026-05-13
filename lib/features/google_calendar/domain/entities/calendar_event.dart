import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_event.freezed.dart';
part 'calendar_event.g.dart';

/// A Google Calendar event in the domain layer (decoupled from googleapis types).
@freezed
class CalendarEvent with _$CalendarEvent {
  const CalendarEvent._();

  const factory CalendarEvent({
    required String id,
    required String calendarId,
    required String summary,
    String? description,
    String? location,
    required DateTime start,
    required DateTime end,
    @Default(false) bool allDay,
    @Default(<EventAttendee>[]) List<EventAttendee> attendees,
    @Default(<EventReminder>[]) List<EventReminder> reminders,
    String? recurrenceRule,
    String? recurringEventId,
    String? organizerEmail,
    EventStatus? status,
    String? hangoutLink,
    String? meetLink,
    DateTime? created,
    DateTime? updated,
    String? etag,
  }) = _CalendarEvent;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);

  Duration get duration => end.difference(start);

  bool overlaps(CalendarEvent other) =>
      start.isBefore(other.end) && other.start.isBefore(end);
}

@freezed
class EventAttendee with _$EventAttendee {
  const factory EventAttendee({
    required String email,
    String? displayName,
    @Default(AttendeeResponse.needsAction) AttendeeResponse response,
    @Default(false) bool optional,
    @Default(false) bool organizer,
  }) = _EventAttendee;

  factory EventAttendee.fromJson(Map<String, dynamic> json) =>
      _$EventAttendeeFromJson(json);
}

@freezed
class EventReminder with _$EventReminder {
  const factory EventReminder({
    required ReminderMethod method,
    required int minutesBefore,
  }) = _EventReminder;

  factory EventReminder.fromJson(Map<String, dynamic> json) =>
      _$EventReminderFromJson(json);
}

enum AttendeeResponse { accepted, declined, tentative, needsAction }

enum ReminderMethod { popup, email }

enum EventStatus { confirmed, tentative, cancelled }

@freezed
class CalendarSummary with _$CalendarSummary {
  const factory CalendarSummary({
    required String id,
    required String summary,
    String? description,
    String? timeZone,
    String? colorId,
    @Default(false) bool primary,
    @Default(CalendarAccessRole.reader) CalendarAccessRole accessRole,
  }) = _CalendarSummary;

  factory CalendarSummary.fromJson(Map<String, dynamic> json) =>
      _$CalendarSummaryFromJson(json);
}

enum CalendarAccessRole {
  freeBusyReader,
  reader,
  writer,
  owner,
}
