import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/core/auth/providers/auth_providers.dart';
import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:google_apis_flutter/features/google_calendar/data/repositories/calendar_repository_impl.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/entities/calendar_event.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/repositories/calendar_repository.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/usecases/calendar_usecases.dart';

final Provider<CalendarRemoteDataSource> calendarRemoteDataSourceProvider =
    Provider<CalendarRemoteDataSource>(
  (Ref ref) => CalendarRemoteDataSource(
    ref.watch(googleSignInServiceProvider),
  ),
);

final Provider<CalendarRepository> calendarRepositoryProvider =
    Provider<CalendarRepository>(
  (Ref ref) => CalendarRepositoryImpl(
    ref.watch(calendarRemoteDataSourceProvider),
  ),
);

// Use case providers
final Provider<GetCalendarEvents> getCalendarEventsProvider =
    Provider<GetCalendarEvents>(
        (Ref ref) => GetCalendarEvents(ref.watch(calendarRepositoryProvider)));
final Provider<CreateCalendarEvent> createCalendarEventProvider =
    Provider<CreateCalendarEvent>((Ref ref) =>
        CreateCalendarEvent(ref.watch(calendarRepositoryProvider)));
final Provider<UpdateCalendarEvent> updateCalendarEventProvider =
    Provider<UpdateCalendarEvent>((Ref ref) =>
        UpdateCalendarEvent(ref.watch(calendarRepositoryProvider)));
final Provider<DeleteCalendarEvent> deleteCalendarEventProvider =
    Provider<DeleteCalendarEvent>((Ref ref) =>
        DeleteCalendarEvent(ref.watch(calendarRepositoryProvider)));
final Provider<FindFreeSlot> findFreeSlotProvider = Provider<FindFreeSlot>(
    (Ref ref) => FindFreeSlot(ref.watch(calendarRepositoryProvider)));

// Async state for a date range list.
final AutoDisposeFutureProviderFamily<Result<List<CalendarEvent>>, DateRangeKey>
    eventsForRangeProvider = FutureProvider.family.autoDispose<Result<List<CalendarEvent>>, DateRangeKey>(
  (Ref ref, DateRangeKey key) {
    final uc = ref.watch(getCalendarEventsProvider);
    return uc(
      calendarId: key.calendarId,
      from: key.from,
      to: key.to,
    );
  },
);

class DateRangeKey {
  const DateRangeKey({
    required this.calendarId,
    required this.from,
    required this.to,
  });

  final String calendarId;
  final DateTime from;
  final DateTime to;

  @override
  bool operator ==(Object other) =>
      other is DateRangeKey &&
      other.calendarId == calendarId &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(calendarId, from, to);
}

final AutoDisposeFutureProvider<Result<List<CalendarSummary>>>
    calendarsListProvider = FutureProvider.autoDispose<Result<List<CalendarSummary>>>(
  (Ref ref) => ref.watch(calendarRepositoryProvider).listCalendars(),
);
