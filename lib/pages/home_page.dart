import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_connection.dart';
import '../services/add_new_records.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
// 2. --- IMPORT REMOVED ---
// import '../services/user_session.dart'; // No longer needed
import 'dart:io';

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

  // 3. --- STATE VARIABLES REMOVED ---
  // We no longer need these! The UserProvider will store them.
  // String _username = 'User';
  // String _profilePicPath = '';

  @override
  void initState() {
    super.initState();
    // 4. --- SIMPLIFIED: Just load health data ---
    // The user data will be handled by the 'build' method
    _loadTodaySummary();
  }

  // 5. --- RENAMED & SIMPLIFIED: ---
  // This function ONLY loads health data now.
  Future<void> _loadTodaySummary() async {
    // Show loading (optional)
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    // 1. Load Health Data from database
    final dbHelper = DatabaseHelper.instance;
    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final allRecords = await dbHelper.queryAllRecords();

    final todayRecord = allRecords.firstWhere(
      (record) => record['date'] == todayDate,
      orElse: () => <String, dynamic>{},
    );

    // 2. Update state with all new data
    // We check 'mounted' just in case
    if (!mounted) return;
    
    if (todayRecord.isNotEmpty) {
      setState(() {
        _todaySteps = todayRecord['steps'] ?? 0;
        _todayCalories = todayRecord['calories'] ?? 0;
        _todayWater = todayRecord['water'] ?? 0;
        _isLoading = false;
      });
    } else {
      // If no health record, set to 0
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
    // 6. --- GET USER DATA FROM PROVIDER ---
    // This line "watches" the provider. If the user data changes,
    // this 'build' method will automatically re-run.
    final user = context.watch<UserProvider>().user;

    // Get the username and photo path, providing default values
    final String username = user?['username'] ?? 'User';
    final String profilePicPath = user?['profile_photo'] ?? '';
    // ----------------------------------------

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 7. --- PASS DATA TO HEADER ---
            // We pass the user data down to the header widget
            _buildHeader(username, profilePicPath),
            const SizedBox(height: 32),
            _buildGrid(),
            const SizedBox(height: 32),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.asset(
                'assets/images/banner.png',
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

  // --- Helper Widget for the Header (UPDATED) ---
  Widget _buildHeader(String username, String profilePicPath) {
    return Row(
      children: [
        // --- UPDATED: The circular avatar ---
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey.shade200, // Fallback color
          backgroundImage: profilePicPath.isNotEmpty
              ? (profilePicPath.startsWith('http')
                  ? NetworkImage(profilePicPath)
                  : FileImage(File(profilePicPath))) as ImageProvider
              : null,
          child: profilePicPath.isEmpty
              ? const Icon(Icons.person, size: 30, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 16),
        // --- UPDATED: The "Good Morning" text ---
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning',
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
            Text(
              username, // Use the 'username' variable
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: Colors.black,
            size: 28,
          ),
          onPressed: () {
            // Handle notification tap
          },
        ),
      ],
    );
  }

  // --- Helper Widget for the 2x2 Grid (UPDATED) ---
  Widget _buildGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        // --- InfoCards (Unchanged, but now work) ---
        InfoCard(
          icon: Icons.directions_walk,
          value: _isLoading ? "..." : _todaySteps.toString(),
          label: 'Steps',
          color: const Color(0xFFE7F7E9),
          iconColor: const Color(0xFF3E9D5E),
          onTap: () {},
        ),
        InfoCard(
          icon: Icons.local_fire_department,
          value: _isLoading ? "..." : _todayCalories.toString(),
          label: 'Calories Burned',
          color: const Color(0xFFFDE4E6),
          iconColor: const Color(0xFFEA868F),
          onTap: () {},
        ),
        InfoCard(
          icon: Icons.water_drop,
          value: _isLoading ? "..." : '${_todayWater / 1000} L',
          label: 'Water Intake',
          color: const Color(0xFFE4F3FF),
          iconColor: const Color(0xFF70B3F2),
          onTap: () {},
        ),
        InfoCard(
          icon: Icons.add,
          label: 'Add New',
          color: const Color(0xFFEAEAEA),
          iconColor: const Color(0xFF3A3A3A),
          // --- UPDATED: .then() calls _loadTodaySummary ---
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddNewRecordsPage(),
              ),
            ).then((_) {
              // Re-load ONLY health data to refresh cards
              _loadTodaySummary();
            });
          },
        ),
      ],
    );
  }
}

// --- A Reusable Widget for the Info Cards ---
// (This widget is unchanged)
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
      borderRadius: BorderRadius.circular(20),
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
            if (value != null)
              Text(
                value!,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            if (value != null) const SizedBox(height: 4),
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