import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/core/auth/providers/auth_providers.dart';
import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_contacts/data/datasources/contacts_remote_datasource.dart';
import 'package:google_apis_flutter/features/google_contacts/data/repositories/contacts_repository_impl.dart';
import 'package:google_apis_flutter/features/google_contacts/domain/entities/contact.dart';
import 'package:google_apis_flutter/features/google_contacts/domain/repositories/contacts_repository.dart';

final Provider<ContactsRemoteDataSource> contactsRemoteDataSourceProvider =
    Provider<ContactsRemoteDataSource>(
  (Ref ref) =>
      ContactsRemoteDataSource(ref.watch(googleSignInServiceProvider)),
);

final Provider<ContactsRepository> contactsRepositoryProvider =
    Provider<ContactsRepository>(
  (Ref ref) =>
      ContactsRepositoryImpl(ref.watch(contactsRemoteDataSourceProvider)),
);

final AutoDisposeFutureProvider<Result<List<Contact>>> contactsListProvider =
    FutureProvider.autoDispose<Result<List<Contact>>>(
        (Ref ref) => ref.watch(contactsRepositoryProvider).listContacts());

final AutoDisposeFutureProviderFamily<Result<List<Contact>>, String>
    contactsSearchProvider =
    FutureProvider.family.autoDispose<Result<List<Contact>>, String>(
  (Ref ref, String query) =>
      ref.watch(contactsRepositoryProvider).search(query: query),
);
