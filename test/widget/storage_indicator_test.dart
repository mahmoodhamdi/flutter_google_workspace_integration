import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/features/google_drive/domain/entities/drive_file.dart';
import 'package:google_apis_flutter/features/google_drive/presentation/widgets/storage_indicator.dart';

void main() {
  group('StorageIndicator', () {
    testWidgets('renders nothing when limit unknown', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: StorageIndicator(DriveStorageQuota(usageBytes: 1024)),
        ),
      ));
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('shows progress bar when limit known', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StorageIndicator(DriveStorageQuota(
            usageBytes: 1 * 1024 * 1024 * 1024,
            limitBytes: 5 * 1024 * 1024 * 1024,
          )),
        ),
      ));
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.textContaining('1.0 GB'), findsOneWidget);
      expect(find.textContaining('5.0 GB'), findsOneWidget);
    });
  });
}
