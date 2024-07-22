import 'package:flutter/material.dart';
import 'package:google_apis_flutter/features/google_analytics/presentation/pages/google_analytics_page.dart';
import 'package:google_apis_flutter/features/google_calendar/presentation/pages/google_calendar_page.dart';
import 'package:google_apis_flutter/features/google_contacts/presentation/pages/google_contacts_page.dart';
import 'package:google_apis_flutter/features/google_docs/presentation/pages/google_docs_page.dart';
import 'package:google_apis_flutter/features/google_drive/presentation/pages/google_drive_page.dart';
import 'package:google_apis_flutter/features/google_gmail/presentation/pages/google_gmail_page.dart';
import 'package:google_apis_flutter/features/google_keep/presentation/pages/google_keep_page.dart';
import 'package:google_apis_flutter/features/google_maps/presentation/pages/google_maps_page.dart';
import 'package:google_apis_flutter/features/google_meet/presentation/pages/google_meet_page.dart';
import 'package:google_apis_flutter/features/google_sheets/presentation/pages/google_sheets_page.dart';
import 'package:google_apis_flutter/core/utils/constants/sizes.dart';
import 'package:google_apis_flutter/core/utils/helpers/helper_functions.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google APIs Flutter Integrator'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Sizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // button for every page
                ElevatedButton(
                    onPressed: () {
                      HelperFunctions.navigateToScreen(
                          context, const GoogleCalendarPage());
                    },
                    child: const Text('Google Calendar')),
                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),
                ElevatedButton(
                    onPressed: () {
                      HelperFunctions.navigateToScreen(
                        context,
                        const GoogleDrivePage(),
                      );
                    },
                    child: const Text('Google Drive')),
                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),
                ElevatedButton(
                    onPressed: () {
                      HelperFunctions.navigateToScreen(
                        context,
                        const GoogleDocsPage(),
                      );
                    },
                    child: const Text('Google Docs')),
                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),
                ElevatedButton(
                    onPressed: () {
                      HelperFunctions.navigateToScreen(
                        context,
                        const GoogleSheetsPage(),
                      );
                    },
                    child: const Text('Google Sheets')),
                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),
                ElevatedButton(
                    onPressed: () {
                      HelperFunctions.navigateToScreen(
                        context,
                        const GoogleContactsPage(),
                      );
                    },
                    child: const Text('Google Contacts')),
                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),
                ElevatedButton(
                    onPressed: () {
                      HelperFunctions.navigateToScreen(
                        context,
                        const GoogleMeetPage(),
                      );
                    },
                    child: const Text('Google Meet')),
                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),
                ElevatedButton(
                    onPressed: () {
                      HelperFunctions.navigateToScreen(
                        context,
                        const GoogleKeepPage(),
                      );
                    },
                    child: const Text('Google Keep')),
                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),
                ElevatedButton(
                    onPressed: () {
                      HelperFunctions.navigateToScreen(
                        context,
                        const GoogleGmailPage(),
                      );
                    },
                    child: const Text('Google Gmail')),
                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),
                ElevatedButton(
                    onPressed: () {
                      HelperFunctions.navigateToScreen(
                        context,
                        const GoogleAnalyticsPage(),
                      );
                    },
                    child: const Text('Google Analytics')),
                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),
                ElevatedButton(
                    onPressed: () {
                      HelperFunctions.navigateToScreen(
                        context,
                        const GoogleMapsPage(),
                      );
                    },
                    child: const Text('Google Maps')),
              ],
            ),
          ),
        ));
  }
}
