import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/core/auth/domain/entities/account.dart';
import 'package:google_apis_flutter/core/auth/domain/repositories/auth_repository.dart';
import 'package:google_apis_flutter/core/auth/presentation/screens/sign_in_screen.dart';
import 'package:google_apis_flutter/core/auth/providers/auth_providers.dart';
import 'package:google_apis_flutter/core/config/app_config.dart';
import 'package:google_apis_flutter/core/errors/app_error.dart';
import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  group('SignInScreen', () {
    testWidgets('renders Google sign-in button', (tester) async {
      final mock = MockAuthRepository();
      when(() => mock.watchActiveAccount()).thenAnswer((_) => const Stream<Account?>.empty());
      when(() => mock.watchAccounts())
          .thenAnswer((_) => Stream<List<Account>>.value(const <Account>[]));
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            authRepositoryProvider.overrideWithValue(mock),
          ],
          child: MaterialApp(
            home: SignInScreen(config: AppConfig.fromFlavor(AppFlavor.base)),
          ),
        ),
      );
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Sign in with email instead'), findsOneWidget);
    });

    testWidgets('toggles email mode on tap', (tester) async {
      final mock = MockAuthRepository();
      when(() => mock.watchActiveAccount()).thenAnswer((_) => const Stream<Account?>.empty());
      when(() => mock.watchAccounts()).thenAnswer((_) => Stream<List<Account>>.value(const <Account>[]));
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            authRepositoryProvider.overrideWithValue(mock),
          ],
          child: MaterialApp(
            home: SignInScreen(config: AppConfig.fromFlavor(AppFlavor.base)),
          ),
        ),
      );
      await tester.tap(find.text('Sign in with email instead'));
      await tester.pump();
      expect(find.widgetWithText(TextFormField, ''), findsNothing); // labels filled
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('shows error message on Google sign-in failure',
        (tester) async {
      final mock = MockAuthRepository();
      when(() => mock.watchActiveAccount()).thenAnswer((_) => const Stream<Account?>.empty());
      when(() => mock.watchAccounts()).thenAnswer((_) => Stream<List<Account>>.value(const <Account>[]));
      when(() => mock.signInWithGoogle(scopes: any(named: 'scopes')))
          .thenAnswer((_) async => const Left<AppError, Account>(
                AppError.unauthorized(message: 'no token'),
              ));
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            authRepositoryProvider.overrideWithValue(mock),
          ],
          child: MaterialApp(
            home: SignInScreen(config: AppConfig.fromFlavor(AppFlavor.base)),
          ),
        ),
      );
      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle();
      expect(find.text('Authentication required.'), findsOneWidget);
    });
  });
}
