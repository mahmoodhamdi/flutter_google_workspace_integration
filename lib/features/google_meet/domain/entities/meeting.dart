import 'package:freezed_annotation/freezed_annotation.dart';

part 'meeting.freezed.dart';
part 'meeting.g.dart';

/// A Google Meet meeting — modeled as a calendar event with a Meet link.
///
/// We do NOT use a separate Meet API (none exists publicly); meetings are
/// scheduled by creating calendar events with `conferenceData` requesting
/// a `hangoutsMeet` conference solution.
@freezed
class Meeting with _$Meeting {
  const Meeting._();

  const factory Meeting({
    required String calendarEventId,
    required String title,
    required DateTime start,
    required DateTime end,
    required String meetLink,
    String? description,
    @Default(<String>[]) List<String> attendeeEmails,
    @Default(MeetingStatus.scheduled) MeetingStatus status,
  }) = _Meeting;

  factory Meeting.fromJson(Map<String, dynamic> json) =>
      _$MeetingFromJson(json);

  Duration get duration => end.difference(start);

  bool get isUpcoming => start.isAfter(DateTime.now());

  bool get isInProgress {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }
}

enum MeetingStatus { scheduled, inProgress, ended, cancelled }
