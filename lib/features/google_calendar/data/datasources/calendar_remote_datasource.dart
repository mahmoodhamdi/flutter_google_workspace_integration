import 'package:google_apis_flutter/core/auth/data/google_sign_in_service.dart';
import 'package:google_apis_flutter/core/errors/app_error.dart';
import 'package:google_apis_flutter/core/utils/constants/api_constants.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;

/// Thin adapter over the `googleapis` Calendar V3 client.
class CalendarRemoteDataSource {
  CalendarRemoteDataSource(this._signIn);

  final GoogleSignInService _signIn;

  Future<gcal.CalendarApi> _api() async {
    final client = await _signIn.authClient(scopes: ApiConstants.calendarScopes);
    if (client == null) {
      throw const AppError.unauthorized(message: 'Not signed in');
    }
    return gcal.CalendarApi(client);
  }

  Future<gcal.CalendarList> listCalendars({String? pageToken}) async {
    final api = await _api();
    return api.calendarList.list(pageToken: pageToken);
  }

  Future<gcal.Events> listEvents({
    required String calendarId,
    DateTime? timeMin,
    DateTime? timeMax,
    int maxResults = 50,
    String? query,
    String? pageToken,
  }) async {
    final api = await _api();
    return api.events.list(
      calendarId,
      timeMin: timeMin?.toUtc(),
      timeMax: timeMax?.toUtc(),
      maxResults: maxResults,
      singleEvents: true,
      orderBy: 'startTime',
      q: query,
      pageToken: pageToken,
    );
  }

  Future<gcal.Event> getEvent(String calendarId, String eventId) async {
    final api = await _api();
    return api.events.get(calendarId, eventId);
  }

  Future<gcal.Event> insertEvent({
    required String calendarId,
    required gcal.Event event,
    bool sendUpdates = true,
  }) async {
    final api = await _api();
    return api.events.insert(
      event,
      calendarId,
      sendUpdates: sendUpdates ? 'all' : 'none',
      conferenceDataVersion: event.conferenceData != null ? 1 : null,
    );
  }

  Future<gcal.Event> updateEvent({
    required String calendarId,
    required String eventId,
    required gcal.Event event,
    bool sendUpdates = true,
  }) async {
    final api = await _api();
    return api.events.update(
      event,
      calendarId,
      eventId,
      sendUpdates: sendUpdates ? 'all' : 'none',
    );
  }

  Future<void> deleteEvent({
    required String calendarId,
    required String eventId,
    bool sendUpdates = true,
  }) async {
    final api = await _api();
    await api.events.delete(
      calendarId,
      eventId,
      sendUpdates: sendUpdates ? 'all' : 'none',
    );
  }

  Future<gcal.FreeBusyResponse> freeBusy({
    required List<String> calendarIds,
    required DateTime timeMin,
    required DateTime timeMax,
  }) async {
    final api = await _api();
    final req = gcal.FreeBusyRequest(
      timeMin: timeMin.toUtc(),
      timeMax: timeMax.toUtc(),
      items: calendarIds
          .map((id) => gcal.FreeBusyRequestItem(id: id))
          .toList(growable: false),
    );
    return api.freebusy.query(req);
  }
}
