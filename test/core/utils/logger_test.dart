import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/core/utils/logger/logger.dart';

void main() {
  group('redact', () {
    test('empty input -> <empty>', () {
      expect(redact(null), '<empty>');
      expect(redact(''), '<empty>');
    });

    test('short input -> all stars', () {
      expect(redact('abc'), '***');
    });

    test('long input shows last 4 chars', () {
      expect(redact('1234567890'), '******7890');
    });

    test('custom keep length', () {
      expect(redact('1234567890', keep: 2), '********90');
    });
  });

  group('redactEmail', () {
    test('keeps domain visible', () {
      expect(redactEmail('user@example.com'), '***@example.com');
    });

    test('invalid input', () {
      expect(redactEmail(null), '<invalid>');
      expect(redactEmail('no-at-sign'), '<invalid>');
    });

    test('multiple @ takes first split', () {
      expect(redactEmail('a@b@c.com'), '***@b@c.com');
    });
  });

  group('LoggerHelper backwards compat facade', () {
    test('all level methods exist and are callable', () {
      // They write to stdout; we only verify they don't throw.
      LoggerHelper.debug('debug');
      LoggerHelper.info('info');
      LoggerHelper.warning('warn');
      LoggerHelper.error('err');
    });
  });
}
