import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/core/errors/app_error.dart';
import 'package:google_apis_flutter/core/errors/result.dart';

void main() {
  group('ResultX', () {
    test('valueOrNull returns right value', () {
      const Result<int> r = Right<AppError, int>(5);
      expect(r.valueOrNull, 5);
    });

    test('valueOrNull returns null on left', () {
      const Result<int> r =
          Left<AppError, int>(AppError.network(message: 'no'));
      expect(r.valueOrNull, null);
    });

    test('errorOrNull returns error', () {
      const e = AppError.notFound(message: 'gone');
      const Result<int> r = Left<AppError, int>(e);
      expect(r.errorOrNull, e);
    });

    test('errorOrNull returns null on right', () {
      const Result<int> r = Right<AppError, int>(1);
      expect(r.errorOrNull, null);
    });

    test('isOk / isErr discriminate correctly', () {
      const Result<int> ok = Right<AppError, int>(1);
      const Result<int> err =
          Left<AppError, int>(AppError.timeout(message: 't'));
      expect(ok.isOk, true);
      expect(ok.isErr, false);
      expect(err.isOk, false);
      expect(err.isErr, true);
    });
  });
}
