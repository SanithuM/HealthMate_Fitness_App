import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // A state variable to manage the switch's value
  bool _isNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We add an AppBar for a nice title at the top
      appBar: AppBar(
        title: const Text('Settings'),
        // This makes the app bar use the scaffold's background color
        backgroundColor: Colors.white,
        elevation: 0,
        // Ensures title text is black
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          // --- Section: Account ---
          _buildSectionHeader('Account'),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              // Handle "Edit Profile" tap
            },
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              // Handle "Change Password" tap
            },
          ),
          const Divider(),

          // --- Section: App Settings ---
          _buildSectionHeader('App Settings'),
          // A special tile with a switch
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: _isNotificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _isNotificationsEnabled = value;
              });
            },
            secondary: Icon(
              Icons.notifications_outlined,
              color: Colors.grey[700],
            ),
            activeThumbColor: const Color(0xFF5D3EBC), // Your app's purple color
          ),
          _buildSettingsTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English', // Show the current value
            onTap: () {
              // Handle "Language" tap
            },
          ),
          const Divider(),

          // --- Section: About ---
          _buildSectionHeader('About'),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About App',
            onTap: () {
              // Handle "About App" tap
            },
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // Handle "Privacy Policy" tap
            },
          ),
          const SizedBox(height: 24),

          // --- Log Out Button ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16),
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Handle log out
              },
              child: const Text(
                'Log Out',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for section headers (e.g., "Account")
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Helper widget for a standard settings list tile
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}