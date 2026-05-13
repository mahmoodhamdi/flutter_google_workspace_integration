import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/entities/calendar_event.dart';
import 'package:google_apis_flutter/features/google_calendar/presentation/providers/calendar_providers.dart';
import 'package:google_apis_flutter/features/google_calendar/presentation/widgets/event_card.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarHomeScreen extends ConsumerStatefulWidget {
  const CalendarHomeScreen({super.key});

  @override
  ConsumerState<CalendarHomeScreen> createState() => _CalendarHomeScreenState();
}

class _CalendarHomeScreenState extends ConsumerState<CalendarHomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;
  String _calendarId = 'primary';

  DateRangeKey get _rangeKey {
    final start = DateTime(_focusedDay.year, _focusedDay.month);
    final end = DateTime(_focusedDay.year, _focusedDay.month + 1, 0, 23, 59);
    return DateRangeKey(calendarId: _calendarId, from: start, to: end);
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsForRangeProvider(_rangeKey));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _openSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(eventsForRangeProvider(_rangeKey)),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          TableCalendar<CalendarEvent>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
            calendarFormat: _format,
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            onFormatChanged: (f) => setState(() => _format = f),
            onPageChanged: (focused) => setState(() => _focusedDay = focused),
            eventLoader: (day) => eventsAsync.maybeWhen(
              data: (res) => res.fold(
                (_) => <CalendarEvent>[],
                (list) => list
                    .where((e) => isSameDay(e.start, day))
                    .toList(growable: false),
              ),
              orElse: () => <CalendarEvent>[],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildEventList(eventsAsync)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/calendar/new'),
        icon: const Icon(Icons.add),
        label: const Text('New event'),
      ),
    );
  }

  Widget _buildEventList(AsyncValue<dynamic> async) {
    return async.when(
      data: (res) => res.fold(
        (err) => Center(child: Text(err.userMessage as String)),
        (list) {
          final dayEvents = (list as List<CalendarEvent>)
              .where((e) => isSameDay(e.start, _selectedDay))
              .toList()
            ..sort((a, b) => a.start.compareTo(b.start));
          if (dayEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.event_busy,
                      size: 48, color: Theme.of(context).disabledColor),
                  const SizedBox(height: 8),
                  Text(
                    'No events for ${DateFormat.yMMMd().format(_selectedDay)}',
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: dayEvents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final e = dayEvents[i];
              return EventCard(
                event: e,
                onTap: () => context.push('/calendar/event/${e.id}'),
              );
            },
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }

  void _openSearch(BuildContext context) {
    showSearch<CalendarEvent?>(
      context: context,
      delegate: _EventSearchDelegate(_calendarId),
    );
  }
}

class _EventSearchDelegate extends SearchDelegate<CalendarEvent?> {
  _EventSearchDelegate(this.calendarId);
  final String calendarId;

  @override
  List<Widget>? buildActions(BuildContext context) => <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _SearchResults(query: query, calendarId: calendarId);

  @override
  Widget buildSuggestions(BuildContext context) => _SearchResults(query: query, calendarId: calendarId);
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query, required this.calendarId});
  final String query;
  final String calendarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.length < 2) {
      return const Center(child: Text('Type to search…'));
    }
    final futureRes = ref
        .read(getCalendarEventsProvider)
        .call(calendarId: calendarId, query: query);
    return FutureBuilder(
      future: futureRes,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final res = snap.data;
        if (res == null) return const SizedBox.shrink();
        return res.fold(
          (err) => Center(child: Text(err.userMessage)),
          (list) => ListView(
            children: list
                .map((e) => EventCard(event: e, onTap: () {}))
                .toList(growable: false),
          ),
        );
      },
    );
  }
}
