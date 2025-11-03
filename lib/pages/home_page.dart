import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_connection.dart'; // Database helper
import '../services/add_new_records.dart'; // Add/Update page
import 'package:provider/provider.dart'; // Provider package
import '../providers/user_provider.dart'; // UserProvider
import 'dart:io'; // For File image

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State variables for health records
  int _todaySteps = 0;
  int _todayCalories = 0;
  int _todayWater = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load all data (user + health) when the page first opens
    _loadAllData();
  }

  // --- Combined function to load all data ---
  Future<void> _loadAllData() async {
    // Show loading indicator only if not already loading
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    // 1. User Data is loaded automatically by the build method using Provider
    // No need to load it here manually

    // 2. Load Health Data from database
    final dbHelper = DatabaseHelper.instance;
    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final allRecords = await dbHelper.queryAllRecords();

    final todayRecord = allRecords.firstWhere(
      (record) => record['date'] == todayDate,
      orElse: () => <String, dynamic>{}, // Return empty map if not found
    );

    // 3. Update state with health data
    // Check if the widget is still mounted before calling setState
    if (!mounted) return;

    if (todayRecord.isNotEmpty) {
      setState(() {
        _todaySteps = todayRecord['steps'] ?? 0;
        _todayCalories = todayRecord['calories'] ?? 0;
        _todayWater = todayRecord['water'] ?? 0;
        _isLoading = false;
      });
    } else {
      // If no health record for today, set values to 0
      setState(() {
        _todaySteps = 0;
        _todayCalories = 0;
        _todayWater = 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- GET USER DATA FROM PROVIDER ---
    // This 'watches' the UserProvider. If user data changes (e.g., profile update),
    // this build method will re-run automatically.
    final user = context.watch<UserProvider>().user;

    // Get username and profile picture path, providing default values if null
    final String username = user?['username'] ?? 'User';
    final String profilePicPath = user?['profile_photo'] ?? '';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pass user data down to the header widget
            _buildHeader(username, profilePicPath),
            const SizedBox(height: 32),
            _buildGrid(), // The grid builds the InfoCards
            const SizedBox(height: 32),
            // The banner image
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.asset(
                'lib/assets/images/banner.png',
                height: 150,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget for the Header ---
  Widget _buildHeader(String username, String profilePicPath) {
    return Row(
      children: [
        // Display the user's profile picture
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey.shade200, // Fallback color
          backgroundImage: profilePicPath.isNotEmpty
              ? (profilePicPath.startsWith('http') // Check if it's a URL
                  ? NetworkImage(profilePicPath)
                  : FileImage(File(profilePicPath))) // Otherwise, assume it's a local file path
                  as ImageProvider
              : null, // If no path, show icon below
          child: profilePicPath.isEmpty
              ? const Icon(Icons.person, size: 30, color: Colors.grey) // Default icon
              : null,
        ),
        const SizedBox(width: 16),
        // Display the greeting and username
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning',
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
            Text(
              username, // Use the username from the provider
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(), // Pushes the notification icon to the end
        // Notification icon button
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: Colors.black,
            size: 28,
          ),
          onPressed: () {
            // future notification functionality
          },
        ),
      ],
    );
  }

  // --- Helper Widget for the 2x2 Grid ---
  Widget _buildGrid() {
    return GridView.count(
      crossAxisCount: 2, // 2 cards per row
      shrinkWrap: true, // Needed inside SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(), // Disables grid scrolling
      crossAxisSpacing: 16, // Horizontal space between cards
      mainAxisSpacing: 16, // Vertical space between cards
      children: [
        // InfoCard for Steps
        InfoCard(
          icon: Icons.directions_walk,
          value: _isLoading ? "..." : _todaySteps.toString(), // Show loading or data
          label: 'Steps',
          color: const Color(0xFFE7F7E9),
          iconColor: const Color(0xFF3E9D5E),
          onTap: () {}, // Can add navigation later if needed
        ),
        // InfoCard for Calories
        InfoCard(
          icon: Icons.local_fire_department,
          value: _isLoading ? "..." : _todayCalories.toString(),
          label: 'Calories Burned',
          color: const Color(0xFFFDE4E6),
          iconColor: const Color(0xFFEA868F),
          onTap: () {},
        ),
        // InfoCard for Water Intake
        InfoCard(
          icon: Icons.water_drop,
          // Convert ml to L for display
          value: _isLoading ? "..." : '${(_todayWater / 1000).toStringAsFixed(1)} L',
          label: 'Water Intake',
          color: const Color(0xFFE4F3FF),
          iconColor: const Color(0xFF70B3F2),
          onTap: () {},
        ),
        // InfoCard for Adding/Updating Records
        InfoCard(
          icon: Icons.add,
          label: 'Add New',
          color: const Color(0xFFEAEAEA),
          iconColor: const Color(0xFF3A3A3A),
          // --- onTap logic to check for existing record ---
          onTap: () async { // Make the function async
            final dbHelper = DatabaseHelper.instance;
            final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

            // Check if a record exists for today using the new DB function
            final Map<String, dynamic>? todayRecord =
                await dbHelper.queryRecordByDate(todayDate);

            // Check if mounted after await before navigating
            if (!mounted) return;

            // Navigate to AddNewRecordsPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewRecordsPage(
                  // Pass today's record if it exists, otherwise pass null
                  existingRecord: todayRecord,
                ),
              ),
            ).then((_) {
              // When returning from AddNewRecordsPage, reload all data
              // to update the InfoCards and potentially the header
              _loadAllData();
            });
          },
        ),
      ],
    );
  }
}

// --- Reusable Widget for the Info Cards ---
// (This widget remains unchanged)
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.icon,
    this.value,
    required this.label,
    required this.color,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String? value;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20), // Ripple effect matches card shape
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 16),
            // Only display the value Text if it's not null
            if (value != null)
              Text(
                value!,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            if (value != null) const SizedBox(height: 4), // Space between value and label
            // Display the label
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}