import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/features/google_contacts/domain/entities/contact.dart';
import 'package:google_apis_flutter/features/google_contacts/presentation/providers/contacts_providers.dart';

class ContactsListScreen extends ConsumerStatefulWidget {
  const ContactsListScreen({super.key});

  @override
  ConsumerState<ContactsListScreen> createState() =>
      _ContactsListScreenState();
}

class _ContactsListScreenState extends ConsumerState<ContactsListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final async = _query.isEmpty
        ? ref.watch(contactsListProvider)
        : ref.watch(contactsSearchProvider(_query));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search contacts',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          Expanded(
            child: async.when(
              data: (res) => res.fold(
                (err) => Center(child: Text(err.userMessage)),
                (list) => _buildList(list),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(null),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildList(List<Contact> contacts) {
    if (contacts.isEmpty) return const Center(child: Text('No contacts'));
    return ListView.separated(
      itemCount: contacts.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final c = contacts[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                c.photoUrl != null ? NetworkImage(c.photoUrl!) : null,
            child: c.photoUrl == null ? Text(c.initials) : null,
          ),
          title: Text(c.displayName.isEmpty ? '(no name)' : c.displayName),
          subtitle: Text(c.primaryEmail ?? c.phones.firstOrNull?.value ?? ''),
          onTap: () => _showEditor(c),
          trailing: c.organizations.isNotEmpty
              ? Text(
                  c.organizations.first.name ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : null,
        );
      },
    );
  }

  Future<void> _showEditor(Contact? existing) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _ContactEditor(existing: existing),
      ),
    );
    if (saved == true) {
      ref
        ..invalidate(contactsListProvider)
        ..invalidate(contactsSearchProvider(_query));
    }
  }
}

extension _FirstOrNullX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _ContactEditor extends ConsumerStatefulWidget {
  const _ContactEditor({this.existing});
  final Contact? existing;

  @override
  ConsumerState<_ContactEditor> createState() => _ContactEditorState();
}

class _ContactEditorState extends ConsumerState<_ContactEditor> {
  late TextEditingController _name;
  late TextEditingController _email;
  late TextEditingController _phone;
  late TextEditingController _org;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.displayName);
    _email = TextEditingController(text: widget.existing?.primaryEmail);
    _phone = TextEditingController(
      text: widget.existing?.phones.firstOrNull?.value,
    );
    _org = TextEditingController(
      text: widget.existing?.organizations.firstOrNull?.name,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _org.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final repo = ref.read(contactsRepositoryProvider);
    final draft = Contact(
      resourceName: widget.existing?.resourceName ?? '',
      displayName: _name.text.trim(),
      emails: _email.text.trim().isEmpty
          ? const <ContactEmail>[]
          : <ContactEmail>[ContactEmail(value: _email.text.trim())],
      phones: _phone.text.trim().isEmpty
          ? const <ContactPhone>[]
          : <ContactPhone>[ContactPhone(value: _phone.text.trim())],
      organizations: _org.text.trim().isEmpty
          ? const <ContactOrganization>[]
          : <ContactOrganization>[ContactOrganization(name: _org.text.trim())],
      etag: widget.existing?.etag,
    );
    final res = widget.existing == null
        ? await repo.createContact(draft)
        : await repo.updateContact(draft);
    if (!mounted) return;
    res.fold(
      (err) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.userMessage)),
        );
      },
      (_) => Navigator.of(context).pop(true),
    );
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete contact?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final res = await ref
        .read(contactsRepositoryProvider)
        .deleteContact(widget.existing!.resourceName);
    if (!mounted) return;
    res.fold(
      (err) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.userMessage)),
        );
      },
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New contact' : 'Edit contact'),
        actions: <Widget>[
          if (widget.existing != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _busy ? null : _delete,
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _busy ? null : _save,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _org,
                decoration: const InputDecoration(labelText: 'Organization'),
              ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
