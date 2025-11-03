import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'pages/welcome_page.dart';
import 'services/navigation_bar.dart'; // main app page

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // This line "watches" the UserProvider for changes.
    final userProvider = context.watch<UserProvider>();

    // If the user is null, show the WelcomePage.
    if (userProvider.user == null) {
      return const WelcomePage();
    }

    // Otherwise, the user is logged in, so show the main app.
    return const NavigationBarTest();
  }
}