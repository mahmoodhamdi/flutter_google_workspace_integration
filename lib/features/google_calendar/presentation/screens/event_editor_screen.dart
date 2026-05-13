import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_apis_flutter/core/errors/app_error.dart';
import 'package:google_apis_flutter/features/google_calendar/domain/entities/calendar_event.dart';
import 'package:google_apis_flutter/features/google_calendar/presentation/providers/calendar_providers.dart';
import 'package:intl/intl.dart';

class EventEditorScreen extends ConsumerStatefulWidget {
  const EventEditorScreen({super.key, this.existing});

  final CalendarEvent? existing;

  @override
  ConsumerState<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends ConsumerState<EventEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _summary;
  late TextEditingController _description;
  late TextEditingController _location;
  late TextEditingController _attendees;
  late DateTime _start;
  late DateTime _end;
  bool _allDay = false;
  bool _addMeet = false;
  int _reminderMinutes = 10;
  bool _busy = false;
  AppError? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _summary = TextEditingController(text: e?.summary ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _location = TextEditingController(text: e?.location ?? '');
    _attendees = TextEditingController(
      text: e?.attendees.map((a) => a.email).join(', ') ?? '',
    );
    _start = e?.start ?? DateTime.now().add(const Duration(hours: 1));
    _end = e?.end ?? _start.add(const Duration(hours: 1));
    _allDay = e?.allDay ?? false;
    _addMeet = e?.meetLink != null;
  }

  @override
  void dispose() {
    _summary.dispose();
    _description.dispose();
    _location.dispose();
    _attendees.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final initial = isStart ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null) return;
    if (!mounted) return;
    if (_allDay) {
      setState(() {
        if (isStart) {
          _start = DateTime(date.year, date.month, date.day);
        } else {
          _end = DateTime(date.year, date.month, date.day, 23, 59);
        }
      });
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    setState(() {
      final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isStart) {
        _start = combined;
        if (_end.isBefore(_start)) {
          _end = _start.add(const Duration(hours: 1));
        }
      } else {
        _end = combined;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final attendees = _attendees.text
        .split(RegExp(r'[,;\s]+'))
        .where((s) => s.contains('@'))
        .map((email) => EventAttendee(email: email.trim()))
        .toList(growable: false);
    final draft = CalendarEvent(
      id: widget.existing?.id ?? '',
      calendarId: widget.existing?.calendarId ?? 'primary',
      summary: _summary.text.trim(),
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      location: _location.text.trim().isEmpty ? null : _location.text.trim(),
      start: _start,
      end: _end,
      allDay: _allDay,
      attendees: attendees,
      reminders: <EventReminder>[
        EventReminder(
          method: ReminderMethod.popup,
          minutesBefore: _reminderMinutes,
        ),
      ],
      meetLink: _addMeet ? 'pending' : null,
    );
    final res = widget.existing == null
        ? await ref.read(createCalendarEventProvider).call(event: draft)
        : await ref.read(updateCalendarEventProvider).call(event: draft);
    if (!mounted) return;
    res.fold(
      (err) => setState(() {
        _busy = false;
        _error = err;
      }),
      (_) => context.pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final dateFmt = DateFormat.yMMMEd();
    final timeFmt = DateFormat.jm();
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit event' : 'New event'),
        actions: <Widget>[
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _busy ? null : _confirmDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!.userMessage,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                TextFormField(
                  controller: _summary,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _location,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _attendees,
                  decoration: const InputDecoration(
                    labelText: 'Attendees (emails)',
                    helperText: 'Comma-separated',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _allDay,
                  onChanged: (v) => setState(() => _allDay = v),
                  title: const Text('All day'),
                ),
                ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(
                    _allDay
                        ? 'Starts ${dateFmt.format(_start)}'
                        : 'Starts ${dateFmt.format(_start)} • ${timeFmt.format(_start)}',
                  ),
                  onTap: () => _pickDateTime(isStart: true),
                ),
                ListTile(
                  leading: const Icon(Icons.event_available),
                  title: Text(
                    _allDay
                        ? 'Ends ${dateFmt.format(_end)}'
                        : 'Ends ${dateFmt.format(_end)} • ${timeFmt.format(_end)}',
                  ),
                  onTap: () => _pickDateTime(isStart: false),
                ),
                SwitchListTile(
                  value: _addMeet,
                  onChanged: (v) => setState(() => _addMeet = v),
                  title: const Text('Add Google Meet link'),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Reminder'),
                  trailing: DropdownButton<int>(
                    value: _reminderMinutes,
                    items: const <DropdownMenuItem<int>>[
                      DropdownMenuItem<int>(value: 5, child: Text('5 min')),
                      DropdownMenuItem<int>(value: 10, child: Text('10 min')),
                      DropdownMenuItem<int>(value: 30, child: Text('30 min')),
                      DropdownMenuItem<int>(value: 60, child: Text('1 hr')),
                      DropdownMenuItem<int>(value: 1440, child: Text('1 day')),
                    ],
                    onChanged: (v) =>
                        setState(() => _reminderMinutes = v ?? 10),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy ? null : _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(isEdit ? 'Save changes' : 'Create event'),
                  ),
                ),
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete event?'),
        content: const Text('This cannot be undone.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final res = await ref.read(deleteCalendarEventProvider).call(
          eventId: widget.existing!.id,
          calendarId: widget.existing!.calendarId,
        );
    if (!mounted) return;
    res.fold(
      (err) => setState(() {
        _busy = false;
        _error = err;
      }),
      (_) => context.pop(true),
    );
  }
}
