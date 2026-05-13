import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_calendar/presentation/providers/calendar_providers.dart';
import 'package:google_apis_flutter/features/google_meet/data/meet_service.dart';
import 'package:google_apis_flutter/features/google_meet/domain/entities/meeting.dart';

final Provider<MeetService> meetServiceProvider = Provider<MeetService>(
  (Ref ref) => MeetService(ref.watch(calendarRepositoryProvider)),
);

final AutoDisposeFutureProvider<Result<List<Meeting>>> upcomingMeetingsProvider =
    FutureProvider.autoDispose<Result<List<Meeting>>>(
        (Ref ref) => ref.watch(meetServiceProvider).listUpcoming());
