import 'package:flutter/material.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/entities/calendar_event.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, this.onTap});

  final CalendarEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFmt = DateFormat.jm();
    final timeRange = event.allDay
        ? 'All day'
        : '${timeFmt.format(event.start)} – ${timeFmt.format(event.end)}';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 4,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      event.summary,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        Icon(Icons.access_time,
                            size: 14, color: theme.textTheme.bodySmall?.color),
                        const SizedBox(width: 4),
                        Text(timeRange, style: theme.textTheme.bodySmall),
                      ],
                    ),
                    if (event.location != null && event.location!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Row(
                        children: <Widget>[
                          Icon(Icons.location_on_outlined,
                              size: 14,
                              color: theme.textTheme.bodySmall?.color),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (event.attendees.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Row(
                        children: <Widget>[
                          Icon(Icons.people_outline,
                              size: 14,
                              color: theme.textTheme.bodySmall?.color),
                          const SizedBox(width: 4),
                          Text(
                            '${event.attendees.length} attendee${event.attendees.length == 1 ? '' : 's'}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (event.meetLink != null)
                IconButton(
                  icon: const Icon(Icons.videocam_outlined),
                  tooltip: 'Join Meet',
                  onPressed: onTap,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
