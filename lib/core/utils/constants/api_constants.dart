/// API endpoints and OAuth scope constants.
class ApiConstants {
  const ApiConstants._();

  // --- Google API base URLs ---
  static const String googleApisBase = 'https://www.googleapis.com';
  static const String calendarApi = '$googleApisBase/calendar/v3';
  static const String driveApi = '$googleApisBase/drive/v3';
  static const String sheetsApi = 'https://sheets.googleapis.com/v4';
  static const String gmailApi = '$googleApisBase/gmail/v1';
  static const String peopleApi = 'https://people.googleapis.com/v1';

  // --- OAuth scopes (SENSITIVE only — no restricted scopes) ---
  static const String scopeCalendar =
      'https://www.googleapis.com/auth/calendar';
  static const String scopeCalendarEvents =
      'https://www.googleapis.com/auth/calendar.events';
  static const String scopeDriveFile =
      'https://www.googleapis.com/auth/drive.file';
  static const String scopeDriveMetaReadonly =
      'https://www.googleapis.com/auth/drive.metadata.readonly';
  static const String scopeSheets =
      'https://www.googleapis.com/auth/spreadsheets';
  static const String scopeSheetsReadonly =
      'https://www.googleapis.com/auth/spreadsheets.readonly';
  static const String scopeGmailSend =
      'https://www.googleapis.com/auth/gmail.send';
  static const String scopeContacts =
      'https://www.googleapis.com/auth/contacts';
  static const String scopeUserinfoEmail =
      'https://www.googleapis.com/auth/userinfo.email';
  static const String scopeUserinfoProfile =
      'https://www.googleapis.com/auth/userinfo.profile';

  // --- Minimum baseline scopes always requested ---
  static const List<String> baselineScopes = <String>[
    scopeUserinfoEmail,
    scopeUserinfoProfile,
  ];

  // --- Per-feature scope manifests ---
  static const List<String> calendarScopes = <String>[scopeCalendar];
  static const List<String> driveScopes = <String>[
    scopeDriveFile,
    scopeDriveMetaReadonly,
  ];
  static const List<String> sheetsScopes = <String>[scopeSheets];
  static const List<String> gmailSendScopes = <String>[scopeGmailSend];
  static const List<String> contactsScopes = <String>[scopeContacts];

  // --- Timeouts ---
  static const Duration defaultConnectTimeout = Duration(seconds: 10);
  static const Duration defaultReceiveTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);

  // --- Pagination defaults ---
  static const int defaultPageSize = 50;
  static const int maxPageSize = 250;
}

/// Backwards-compat: the original codebase referenced a bare `baseUrl`.
const String baseUrl = ApiConstants.googleApisBase;
