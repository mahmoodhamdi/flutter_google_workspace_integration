import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/features/google_drive/domain/entities/drive_file.dart';
import 'package:google_apis_flutter/features/google_drive/presentation/widgets/drive_file_tile.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('DriveFileTile', () {
    testWidgets('renders file name and size', (tester) async {
      const f = DriveFile(
        id: 'f',
        name: 'report.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 2048,
      );
      await tester.pumpWidget(host(DriveFileTile(
        file: f,
        onTap: () {},
        onShare: () {},
        onDelete: () {},
        onRename: () {},
      )));
      expect(find.text('report.pdf'), findsOneWidget);
      expect(find.textContaining('2.0 KB'), findsOneWidget);
    });

    testWidgets('shows folder icon for folder mime', (tester) async {
      const f = DriveFile(
        id: 'fld',
        name: 'Docs',
        mimeType: 'application/vnd.google-apps.folder',
      );
      await tester.pumpWidget(host(DriveFileTile(
        file: f,
        onTap: () {},
        onShare: () {},
        onDelete: () {},
        onRename: () {},
      )));
      expect(find.byIcon(Icons.folder), findsOneWidget);
    });

    testWidgets('popup menu actions wired up', (tester) async {
      int renameCount = 0;
      int shareCount = 0;
      int deleteCount = 0;
      const f = DriveFile(id: 'f', name: 'x.png', mimeType: 'image/png');
      await tester.pumpWidget(host(DriveFileTile(
        file: f,
        onTap: () {},
        onShare: () => shareCount++,
        onDelete: () => deleteCount++,
        onRename: () => renameCount++,
      )));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      expect(renameCount, 1);
    });
  });
}
