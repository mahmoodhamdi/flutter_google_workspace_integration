import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/core/auth/domain/entities/account.dart';
import 'package:google_apis_flutter/core/auth/presentation/widgets/account_switcher.dart';
import 'package:google_apis_flutter/core/auth/providers/auth_providers.dart';

void main() {
  group('AccountSwitcher', () {
    testWidgets('renders nothing when no accounts', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            accountsProvider.overrideWith((_) => Stream<List<Account>>.value(const <Account>[])),
            activeAccountProvider.overrideWith((_) => Stream<Account?>.value(null)),
          ],
          child: const MaterialApp(home: Scaffold(appBar: null, body: AccountSwitcher())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PopupMenuButton<String>), findsNothing);
    });

    testWidgets('shows avatar with first initial when account active', (tester) async {
      const account = Account(
        id: 'jane@example.com',
        email: 'jane@example.com',
        displayName: 'Jane Doe',
        isActive: true,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            accountsProvider
                .overrideWith((_) => Stream<List<Account>>.value(const <Account>[account])),
            activeAccountProvider
                .overrideWith((_) => Stream<Account?>.value(account)),
          ],
          child: const MaterialApp(home: Scaffold(body: AccountSwitcher())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
      expect(find.text('J'), findsOneWidget);
    });
  });
}
