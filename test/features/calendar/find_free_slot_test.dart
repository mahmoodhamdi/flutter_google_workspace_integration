import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_calendar/data/repositories/calendar_repository_impl.dart';
import 'package:google_apis_flutter/features/google_calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/entities/calendar_event.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:mocktail/mocktail.dart';

class MockDS extends Mock implements CalendarRemoteDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(gcal.Event());
  });

  group('findFreeSlot', () {
    test('returns the first hour-slot when nobody is busy', () async {
      final ds = MockDS();
      when(() => ds.freeBusy(
            calendarIds: any(named: 'calendarIds'),
            timeMin: any(named: 'timeMin'),
            timeMax: any(named: 'timeMax'),
          )).thenAnswer((_) async => gcal.FreeBusyResponse(
            calendars: <String, gcal.FreeBusyCalendar>{
              'me@example.com': gcal.FreeBusyCalendar(busy: const <gcal.TimePeriod>[]),
            },
          ));
      final repo = CalendarRepositoryImpl(ds);
      final from = DateTime(2026, 5, 13, 9);
      final until = DateTime(2026, 5, 13, 17);
      final res = await repo.findFreeSlot(
        attendees: const <String>['me@example.com'],
        from: from,
        until: until,
        duration: const Duration(hours: 1),
      );
      expect(res.isRight(), true);
      expect(res.valueOrNull, from);
    });

    test('skips busy intervals', () async {
      final ds = MockDS();
      when(() => ds.freeBusy(
            calendarIds: any(named: 'calendarIds'),
            timeMin: any(named: 'timeMin'),
            timeMax: any(named: 'timeMax'),
          )).thenAnswer((_) async => gcal.FreeBusyResponse(
            calendars: <String, gcal.FreeBusyCalendar>{
              'a@example.com': gcal.FreeBusyCalendar(
                busy: <gcal.TimePeriod>[
                  gcal.TimePeriod(
                    start: DateTime(2026, 5, 13, 9),
                    end: DateTime(2026, 5, 13, 11),
                  ),
                ],
              ),
            },
          ));
      final repo = CalendarRepositoryImpl(ds);
      final from = DateTime(2026, 5, 13, 9);
      final until = DateTime(2026, 5, 13, 17);
      final res = await repo.findFreeSlot(
        attendees: const <String>['a@example.com'],
        from: from,
        until: until,
        duration: const Duration(hours: 1),
      );
      expect(res.isRight(), true);
      // First free 1-hour slot starts at 11:00 after the 9-11 busy block.
      expect(res.valueOrNull, DateTime(2026, 5, 13, 11));
    });

    test('returns null when no slot fits before until', () async {
      final ds = MockDS();
      when(() => ds.freeBusy(
            calendarIds: any(named: 'calendarIds'),
            timeMin: any(named: 'timeMin'),
            timeMax: any(named: 'timeMax'),
          )).thenAnswer((_) async => gcal.FreeBusyResponse(
            calendars: <String, gcal.FreeBusyCalendar>{
              'a@example.com': gcal.FreeBusyCalendar(
                busy: <gcal.TimePeriod>[
                  gcal.TimePeriod(
                    start: DateTime(2026, 5, 13, 9),
                    end: DateTime(2026, 5, 13, 17),
                  ),
                ],
              ),
            },
          ));
      final repo = CalendarRepositoryImpl(ds);
      final res = await repo.findFreeSlot(
        attendees: const <String>['a@example.com'],
        from: DateTime(2026, 5, 13, 9),
        until: DateTime(2026, 5, 13, 17),
        duration: const Duration(hours: 1),
      );
      expect(res.isRight(), true);
      // No slot before 17:00 since busy spans the whole day.
      // (Algorithm rolls to next day; until cuts it off.)
      expect(res.valueOrNull, null);
    });
  });

  group('CalendarRepositoryImpl basic plumbing', () {
    test('listCalendars uses datasource and maps entries', () async {
      final ds = MockDS();
      when(() => ds.listCalendars(pageToken: any(named: 'pageToken')))
          .thenAnswer((_) async => gcal.CalendarList(
                items: <gcal.CalendarListEntry>[
                  gcal.CalendarListEntry(
                    id: 'primary',
                    summary: 'My Cal',
                    accessRole: 'owner',
                    primary: true,
                  ),
                ],
              ));
      final repo = CalendarRepositoryImpl(ds);
      final res = await repo.listCalendars();
      expect(res.isRight(), true);
      final list = res.valueOrNull!;
      expect(list, hasLength(1));
      expect(list.first.primary, true);
      expect(list.first.accessRole, CalendarAccessRole.owner);
    });
  });
}
