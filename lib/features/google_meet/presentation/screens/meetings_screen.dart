import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/features/google_meet/presentation/providers/meet_providers.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingsScreen extends ConsumerWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(upcomingMeetingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetings'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(upcomingMeetingsProvider),
          ),
        ],
      ),
      body: async.when(
        data: (res) => res.fold(
          (err) => Center(child: Text(err.userMessage)),
          (list) {
            if (list.isEmpty) {
              return const Center(child: Text('No upcoming meetings'));
            }
            return ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final m = list[i];
                final start = DateFormat.MMMd().add_jm().format(m.start);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: const Icon(Icons.videocam_outlined),
                  ),
                  title: Text(m.title),
                  subtitle: Text(
                    '$start · ${m.duration.inMinutes} min · ${m.attendeeEmails.length} attendees',
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: () => _join(m.meetLink),
                    child: const Text('Join'),
                  ),
                );
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  Future<void> _join(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
