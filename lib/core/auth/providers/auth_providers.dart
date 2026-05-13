import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/core/auth/data/auth_repository_impl.dart';
import 'package:google_apis_flutter/core/auth/data/firebase_auth_service.dart';
import 'package:google_apis_flutter/core/auth/data/google_sign_in_service.dart';
import 'package:google_apis_flutter/core/auth/domain/entities/account.dart';
import 'package:google_apis_flutter/core/auth/domain/repositories/auth_repository.dart';
import 'package:google_apis_flutter/core/auth/domain/token_provider.dart';
import 'package:google_apis_flutter/core/storage/secure_token_store.dart';

final Provider<GoogleSignInService> googleSignInServiceProvider =
    Provider<GoogleSignInService>(
  (Ref ref) => GoogleSignInService(),
  name: 'googleSignInServiceProvider',
);

final Provider<FirebaseAuthService> firebaseAuthServiceProvider =
    Provider<FirebaseAuthService>(
  (Ref ref) => FirebaseAuthService(),
  name: 'firebaseAuthServiceProvider',
);

final Provider<AuthRepositoryImpl> authRepositoryImplProvider =
    Provider<AuthRepositoryImpl>(
  (Ref ref) {
    final impl = AuthRepositoryImpl(
      google: ref.watch(googleSignInServiceProvider),
      firebase: ref.watch(firebaseAuthServiceProvider),
      store: ref.watch(secureTokenStoreProvider),
    );
    ref.onDispose(impl.dispose);
    return impl;
  },
  name: 'authRepositoryImplProvider',
);

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
  (Ref ref) => ref.watch(authRepositoryImplProvider),
  name: 'authRepositoryProvider',
);

final Provider<TokenProvider> tokenProviderProvider =
    Provider<TokenProvider>(
  (Ref ref) => ref.watch(authRepositoryImplProvider),
  name: 'tokenProviderProvider',
);

final StreamProvider<Account?> activeAccountProvider =
    StreamProvider<Account?>(
  (Ref ref) => ref.watch(authRepositoryProvider).watchActiveAccount(),
  name: 'activeAccountProvider',
);

final StreamProvider<List<Account>> accountsProvider =
    StreamProvider<List<Account>>(
  (Ref ref) => ref.watch(authRepositoryProvider).watchAccounts(),
  name: 'accountsProvider',
);
