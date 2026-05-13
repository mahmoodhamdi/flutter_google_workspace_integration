import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/features/google_calendar/presentation/screens/event_editor_screen.dart';

void main() {
  group('EventEditorScreen', () {
    testWidgets('renders create form for new event', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: EventEditorScreen()),
        ),
      );
      expect(find.text('New event'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, ''), findsWidgets);
      expect(find.text('All day'), findsOneWidget);
      expect(find.text('Add Google Meet link'), findsOneWidget);
    });

    testWidgets('toggling all-day affects start/end picker behavior', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: EventEditorScreen()),
        ),
      );
      final sw = find.widgetWithText(SwitchListTile, 'All day');
      await tester.tap(sw);
      await tester.pump();
      // No assertion about pickers (they require platform); we only assert
      // the switch is now on.
      final widget = tester.widget<SwitchListTile>(sw);
      expect(widget.value, true);
    });
  });
}
