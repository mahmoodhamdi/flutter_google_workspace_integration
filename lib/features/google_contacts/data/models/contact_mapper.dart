import 'package:google_apis_flutter/features/google_contacts/domain/entities/contact.dart';
import 'package:googleapis/people/v1.dart' as gpeople;

class ContactMapper {
  const ContactMapper._();

  static Contact toDomain(gpeople.Person p) {
    final name = (p.names ?? <gpeople.Name>[]).firstOrNull;
    return Contact(
      resourceName: p.resourceName ?? '',
      displayName: name?.displayName ??
          [name?.givenName, name?.familyName]
              .whereType<String>()
              .join(' ')
              .trim(),
      givenName: name?.givenName,
      familyName: name?.familyName,
      emails: (p.emailAddresses ?? <gpeople.EmailAddress>[])
          .map<ContactEmail>(
            (e) => ContactEmail(
              value: e.value ?? '',
              label: e.formattedType ?? e.type,
              primary: e.metadata?.primary ?? false,
            ),
          )
          .toList(growable: false),
      phones: (p.phoneNumbers ?? <gpeople.PhoneNumber>[])
          .map<ContactPhone>(
            (ph) => ContactPhone(
              value: ph.canonicalForm ?? ph.value ?? '',
              label: ph.formattedType ?? ph.type,
              primary: ph.metadata?.primary ?? false,
            ),
          )
          .toList(growable: false),
      addresses: (p.addresses ?? <gpeople.Address>[])
          .map<ContactAddress>(
            (a) => ContactAddress(
              formatted: a.formattedValue ?? '',
              city: a.city,
              region: a.region,
              country: a.country,
              label: a.formattedType ?? a.type,
            ),
          )
          .toList(growable: false),
      organizations: (p.organizations ?? <gpeople.Organization>[])
          .map<ContactOrganization>(
            (o) => ContactOrganization(
              name: o.name,
              title: o.title,
              department: o.department,
            ),
          )
          .toList(growable: false),
      photoUrl: (p.photos ?? <gpeople.Photo>[]).firstOrNull?.url,
      etag: p.etag,
    );
  }

  static gpeople.Person toApi(Contact c) {
    return gpeople.Person(
      etag: c.etag,
      resourceName: c.resourceName.isEmpty ? null : c.resourceName,
      names: <gpeople.Name>[
        gpeople.Name(
          givenName: c.givenName ?? c.displayName.split(' ').first,
          familyName: c.familyName,
        ),
      ],
      emailAddresses: c.emails
          .map((e) => gpeople.EmailAddress(value: e.value, type: e.label))
          .toList(),
      phoneNumbers: c.phones
          .map((p) => gpeople.PhoneNumber(value: p.value, type: p.label))
          .toList(),
      addresses: c.addresses
          .map((a) => gpeople.Address(
                formattedValue: a.formatted,
                city: a.city,
                region: a.region,
                country: a.country,
                type: a.label,
              ))
          .toList(),
      organizations: c.organizations
          .map((o) => gpeople.Organization(
                name: o.name,
                title: o.title,
                department: o.department,
              ))
          .toList(),
    );
  }
}

extension _FirstOrNullX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
