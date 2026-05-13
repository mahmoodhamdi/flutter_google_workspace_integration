import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_contacts/domain/entities/contact.dart';

abstract class ContactsRepository {
  /// List all contacts. Uses pagination internally.
  Future<Result<List<Contact>>> listContacts({
    int pageSize = 100,
    String? pageToken,
  });

  /// Search by free-text query (matches name, email, phone, organization).
  Future<Result<List<Contact>>> search({required String query, int limit = 30});

  Future<Result<Contact>> getContact(String resourceName);

  Future<Result<Contact>> createContact(Contact contact);

  Future<Result<Contact>> updateContact(Contact contact);

  Future<Result<void>> deleteContact(String resourceName);
}
