import 'package:google_apis_flutter/core/auth/data/google_sign_in_service.dart';
import 'package:google_apis_flutter/core/errors/app_error.dart';
import 'package:google_apis_flutter/core/utils/constants/api_constants.dart';
import 'package:googleapis/people/v1.dart' as gpeople;

class ContactsRemoteDataSource {
  ContactsRemoteDataSource(this._signIn);
  final GoogleSignInService _signIn;

  static const String _personFields =
      'names,emailAddresses,phoneNumbers,addresses,organizations,photos,metadata';

  Future<gpeople.PeopleServiceApi> _api() async {
    final client =
        await _signIn.authClient(scopes: ApiConstants.contactsScopes);
    if (client == null) {
      throw const AppError.unauthorized(message: 'Not signed in');
    }
    return gpeople.PeopleServiceApi(client);
  }

  Future<gpeople.ListConnectionsResponse> listConnections({
    int pageSize = 100,
    String? pageToken,
  }) async {
    final api = await _api();
    return api.people.connections.list(
      'people/me',
      pageSize: pageSize,
      pageToken: pageToken,
      personFields: _personFields,
      sortOrder: 'FIRST_NAME_ASCENDING',
    );
  }

  Future<gpeople.SearchResponse> search(String query) async {
    final api = await _api();
    return api.people.searchContacts(
      query: query,
      readMask: _personFields,
    );
  }

  Future<gpeople.Person> getPerson(String resourceName) async {
    final api = await _api();
    return api.people.get(resourceName, personFields: _personFields);
  }

  Future<gpeople.Person> createContact(gpeople.Person person) async {
    final api = await _api();
    return api.people.createContact(person, personFields: _personFields);
  }

  Future<gpeople.Person> updateContact({
    required String resourceName,
    required gpeople.Person person,
    required String updateMask,
  }) async {
    final api = await _api();
    return api.people.updateContact(
      person,
      resourceName,
      updatePersonFields: updateMask,
      personFields: _personFields,
    );
  }

  Future<void> deleteContact(String resourceName) async {
    final api = await _api();
    await api.people.deleteContact(resourceName);
  }
}
