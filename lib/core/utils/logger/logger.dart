import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Application logger.
///
/// Use [appLog] everywhere. Production builds (`kReleaseMode`) keep [Level.warning]
/// and above; debug builds get [Level.trace].
///
/// PII redaction is the caller's responsibility — use [redact] on tokens,
/// emails (except domain), and other sensitive fields before passing to log.
final Logger appLog = Logger(
  printer: kReleaseMode
      ? SimplePrinter(printTime: true, colors: false)
      : PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 8,
          lineLength: 100,
          printEmojis: false,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
  level: kReleaseMode ? Level.warning : Level.trace,
  filter: _AppLogFilter(),
);

class _AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kReleaseMode) {
      return event.level.index >= Level.warning.index;
    }
    return event.level.index >= Level.trace.index;
  }
}

/// Redacts a string by keeping only the last [keep] characters.
String redact(String? value, {int keep = 4}) {
  if (value == null || value.isEmpty) {
    return '<empty>';
  }
  if (value.length <= keep) {
    return '*' * value.length;
  }
  return '${'*' * (value.length - keep)}${value.substring(value.length - keep)}';
}

/// Redacts an email to keep domain visible.
/// `user@example.com` -> `***@example.com`
String redactEmail(String? email) {
  if (email == null || !email.contains('@')) {
    return '<invalid>';
  }
  final parts = email.split('@');
  return '***@${parts[1]}';
}

/// Backwards-compatible facade for code that imports the older `LoggerHelper`.
class LoggerHelper {
  const LoggerHelper._();

  static void debug(String message) => appLog.d(message);
  static void info(String message) => appLog.i(message);
  static void warning(String message) => appLog.w(message);
  static void error(String message, [Object? error, StackTrace? stack]) =>
      appLog.e(message, error: error, stackTrace: stack);
}
