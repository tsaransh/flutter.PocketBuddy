// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About $appName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              children: [
                const Text(
                  'App Name: $appName',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Developer: SARANSH TYAGI',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Description: Pocket Buddy is an expense tracker application designed to help you track your personal expenses as well as group expenses, such as expenses shared among friends.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(18),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(25),
                          ),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.tertiaryContainer,
                        foregroundColor:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                      onPressed: _launchGitHubRepo,
                      child: const Text('GitHub Repo'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(18),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(25),
                          ),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.tertiaryContainer,
                        foregroundColor:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                      onPressed: _contactUs,
                      child: const Text('Contact us'),
                    ),
                  ],
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(18),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    foregroundColor: Theme.of(context).colorScheme.onTertiary,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Update App'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Version: $appVersion',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _launchGitHubRepo() async {
    const url = 'https://github.com/tsaransh/flutter.PocketBuddy';

    await launch(url);
  }

  void _contactUs() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'tyagisaransh90@gmail.com',
      queryParameters: {'subject': 'Pocket Buddy'},
    );

    await launch(emailLaunchUri.toString());

    // Fallback: Open URL in browser
    await launch(
        'mailto:tyagisaransh90@gmail.com?subject=Pocket Buddy Feedback');
  }
}

const String appName = 'POCKET BUDDY';
const String appVersion = '1.0.0';
