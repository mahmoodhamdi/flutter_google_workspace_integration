import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/features/google_contacts/data/models/contact_mapper.dart';
import 'package:google_apis_flutter/features/google_contacts/domain/entities/contact.dart';
import 'package:googleapis/people/v1.dart' as gpeople;

void main() {
  group('Contact.initials', () {
    test('two-word name -> two letters', () {
      const c = Contact(resourceName: 'r', displayName: 'Jane Doe');
      expect(c.initials, 'JD');
    });

    test('single-word name -> first letter', () {
      const c = Contact(resourceName: 'r', displayName: 'Alice');
      expect(c.initials, 'A');
    });

    test('empty name -> ?', () {
      const c = Contact(resourceName: 'r', displayName: '');
      expect(c.initials, '?');
    });

    test('trims whitespace', () {
      const c = Contact(resourceName: 'r', displayName: '  John  ');
      expect(c.initials, 'J');
    });

    test('three-word name uses first and last letters', () {
      const c = Contact(resourceName: 'r', displayName: 'Mary Jane Watson');
      expect(c.initials, 'MW');
    });
  });

  group('Contact.primaryEmail', () {
    test('returns marked-primary email', () {
      const c = Contact(
        resourceName: 'r',
        displayName: 'X',
        emails: <ContactEmail>[
          ContactEmail(value: 'first@example.com'),
          ContactEmail(value: 'primary@example.com', primary: true),
        ],
      );
      expect(c.primaryEmail, 'primary@example.com');
    });

    test('returns first email when none marked primary', () {
      const c = Contact(
        resourceName: 'r',
        displayName: 'X',
        emails: <ContactEmail>[ContactEmail(value: 'only@example.com')],
      );
      expect(c.primaryEmail, 'only@example.com');
    });
  });

  group('ContactMapper.toDomain', () {
    test('builds displayName from given+family when missing', () {
      final p = gpeople.Person(
        resourceName: 'people/123',
        names: <gpeople.Name>[
          gpeople.Name(givenName: 'Jane', familyName: 'Doe'),
        ],
      );
      final c = ContactMapper.toDomain(p);
      expect(c.displayName, 'Jane Doe');
      expect(c.givenName, 'Jane');
      expect(c.familyName, 'Doe');
    });

    test('maps emails, phones, organizations', () {
      final p = gpeople.Person(
        resourceName: 'people/456',
        names: <gpeople.Name>[gpeople.Name(displayName: 'Alice')],
        emailAddresses: <gpeople.EmailAddress>[
          gpeople.EmailAddress(
            value: 'a@example.com',
            metadata: gpeople.FieldMetadata(primary: true),
          ),
        ],
        phoneNumbers: <gpeople.PhoneNumber>[
          gpeople.PhoneNumber(canonicalForm: '+15550100', type: 'mobile'),
        ],
        organizations: <gpeople.Organization>[
          gpeople.Organization(name: 'Acme', title: 'CEO'),
        ],
        photos: <gpeople.Photo>[gpeople.Photo(url: 'https://photo')],
      );
      final c = ContactMapper.toDomain(p);
      expect(c.emails.first.value, 'a@example.com');
      expect(c.emails.first.primary, true);
      expect(c.phones.first.value, '+15550100');
      expect(c.organizations.first.name, 'Acme');
      expect(c.photoUrl, 'https://photo');
    });

    test('handles missing optional fields', () {
      final p = gpeople.Person(resourceName: 'people/empty');
      final c = ContactMapper.toDomain(p);
      expect(c.resourceName, 'people/empty');
      expect(c.displayName, '');
      expect(c.emails, isEmpty);
      expect(c.phones, isEmpty);
    });
  });

  group('ContactMapper.toApi', () {
    test('places given name in Name', () {
      const c = Contact(
        resourceName: 'people/1',
        displayName: 'John Smith',
        givenName: 'John',
        familyName: 'Smith',
      );
      final p = ContactMapper.toApi(c);
      expect(p.names!.first.givenName, 'John');
      expect(p.names!.first.familyName, 'Smith');
    });

    test('strips empty resource name on create', () {
      const c = Contact(resourceName: '', displayName: 'Solo');
      final p = ContactMapper.toApi(c);
      expect(p.resourceName, null);
    });
  });
}
