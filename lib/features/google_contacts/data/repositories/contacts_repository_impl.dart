import 'package:google_apis_flutter/core/errors/guard.dart';
import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_contacts/data/datasources/contacts_remote_datasource.dart';
import 'package:google_apis_flutter/features/google_contacts/data/models/contact_mapper.dart';
import 'package:google_apis_flutter/features/google_contacts/domain/entities/contact.dart';
import 'package:google_apis_flutter/features/google_contacts/domain/repositories/contacts_repository.dart';
import 'package:googleapis/people/v1.dart' as gpeople;

class ContactsRepositoryImpl implements ContactsRepository {
  ContactsRepositoryImpl(this._remote);
  final ContactsRemoteDataSource _remote;

  @override
  Future<Result<List<Contact>>> listContacts({
    int pageSize = 100,
    String? pageToken,
  }) =>
      guardWithRetry<List<Contact>>(() async {
        final list = <Contact>[];
        String? token = pageToken;
        // Drain pages so the UI gets full list (most users have < 1000).
        for (int i = 0; i < 20; i++) {
          final r = await _remote.listConnections(
            pageSize: pageSize,
            pageToken: token,
          );
          final conns = r.connections ?? const <gpeople.Person>[];
          list.addAll(conns.map<Contact>(ContactMapper.toDomain));
          token = r.nextPageToken;
          if (token == null || token.isEmpty) break;
        }
        list.sort((a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
        return list;
      }, operation: 'contacts.list');

  @override
  Future<Result<List<Contact>>> search({
    required String query,
    int limit = 30,
  }) =>
      guardWithRetry<List<Contact>>(() async {
        if (query.trim().isEmpty) return const <Contact>[];
        final r = await _remote.search(query.trim());
        final raw = r.results ?? const <gpeople.SearchResult>[];
        final results = raw
            .where((res) => res.person != null)
            .map<Contact>((res) => ContactMapper.toDomain(res.person!))
            .toList();
        return results.take(limit).toList();
      }, operation: 'contacts.search');

  @override
  Future<Result<Contact>> getContact(String resourceName) =>
      guardWithRetry<Contact>(() async {
        final raw = await _remote.getPerson(resourceName);
        return ContactMapper.toDomain(raw);
      }, operation: 'contacts.get');

  @override
  Future<Result<Contact>> createContact(Contact contact) =>
      guard<Contact>(() async {
        final raw = await _remote.createContact(ContactMapper.toApi(contact));
        return ContactMapper.toDomain(raw);
      }, operation: 'contacts.create');

  @override
  Future<Result<Contact>> updateContact(Contact contact) =>
      guard<Contact>(() async {
        final raw = await _remote.updateContact(
          resourceName: contact.resourceName,
          person: ContactMapper.toApi(contact),
          updateMask: 'names,emailAddresses,phoneNumbers,addresses,organizations',
        );
        return ContactMapper.toDomain(raw);
      }, operation: 'contacts.update');

  @override
  Future<Result<void>> deleteContact(String resourceName) =>
      guard<void>(() => _remote.deleteContact(resourceName),
          operation: 'contacts.delete');
}
