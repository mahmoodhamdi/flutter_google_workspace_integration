import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/core/auth/providers/auth_providers.dart';

class AccountSwitcher extends ConsumerWidget {
  const AccountSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final activeAsync = ref.watch(activeAccountProvider);

    return accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) {
          return const SizedBox.shrink();
        }
        final active = activeAsync.valueOrNull;
        return PopupMenuButton<String>(
          icon: CircleAvatar(
            radius: 16,
            backgroundImage: active?.photoUrl != null
                ? NetworkImage(active!.photoUrl!)
                : null,
            child: active?.photoUrl == null
                ? Text(
                    (active?.displayName?.isNotEmpty ?? false)
                        ? active!.displayName!.substring(0, 1).toUpperCase()
                        : '?',
                  )
                : null,
          ),
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            ...accounts.map<PopupMenuEntry<String>>(
              (a) => PopupMenuItem<String>(
                value: a.id,
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 14,
                      backgroundImage:
                          a.photoUrl != null ? NetworkImage(a.photoUrl!) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            a.displayName ?? a.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            a.email,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (a.id == active?.id)
                      const Icon(Icons.check, size: 18),
                  ],
                ),
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: '__add__',
              child: ListTile(
                leading: Icon(Icons.add),
                title: Text('Add another account'),
                dense: true,
              ),
            ),
            const PopupMenuItem<String>(
              value: '__signout__',
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Sign out'),
                dense: true,
              ),
            ),
          ],
          onSelected: (value) async {
            final repo = ref.read(authRepositoryProvider);
            if (value == '__signout__') {
              await repo.signOutActive();
            } else if (value == '__add__') {
              await repo.signInWithGoogle(scopes: <String>[]);
            } else {
              await repo.switchAccount(value);
            }
          },
        );
      },
      loading: () => const SizedBox(
        width: 32,
        height: 32,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
