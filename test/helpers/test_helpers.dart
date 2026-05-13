import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Wraps a [widget] in a [MaterialApp] with the given [overrides] for
/// Riverpod providers. Useful for widget tests that need provider injection.
Future<void> pumpWithOverrides(
  WidgetTester tester,
  Widget widget, {
  List<Override> overrides = const <Override>[],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: widget),
    ),
  );
}

/// Like [registerFallbackValue] but for [Map<String, dynamic>].
void registerFallbacks() {
  registerFallbackValue(<String, dynamic>{});
  registerFallbackValue(<String>[]);
  registerFallbackValue(DateTime.now());
  registerFallbackValue(StackTrace.current);
}

/// Completes [future] within [timeout] or fails the test.
Future<T> withTimeout<T>(Future<T> future,
    {Duration timeout = const Duration(seconds: 5)}) {
  return future.timeout(timeout);
}

/// Convenience: create a Completer that resolves immediately with [value].
Future<T> immediate<T>(T value) => Future<T>.value(value);

/// Convenience: create a Future that throws [error] immediately.
Future<T> immediateError<T>(Object error) => Future<T>.error(error);
