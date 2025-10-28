import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_connection.dart';
import '../services/add_new_records.dart';
import '../services/user_session.dart';
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

  // State variables for user
  String _username = 'User';
  String _profilePicPath = '';

  @override
  void initState() {
    super.initState();
    // Load all data (user + health) when the page first opens
    _loadAllData();
  }

  // --- NEW: Combined function to load all data ---
  Future<void> _loadAllData() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    // 1. Load User Data from session
    final user = UserSession().currentUser;
    if (user != null) {
      _username = user['username'];
      _profilePicPath = user['profile_photo'] ?? '';
    }

    // 2. Load Health Data from database
    final dbHelper = DatabaseHelper.instance;
    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final allRecords = await dbHelper.queryAllRecords();

    final todayRecord = allRecords.firstWhere(
      (record) => record['date'] == todayDate,
      orElse: () => <String, dynamic>{},
    );

    // 3. Update state with all new data
    if (todayRecord.isNotEmpty) {
      setState(() {
        _todaySteps = todayRecord['steps'] ?? 0;
        _todayCalories = todayRecord['calories'] ?? 0;
        _todayWater = todayRecord['water'] ?? 0;
        _isLoading = false;
      });
    } else {
      // If no health record, set to 0 but still load user
      setState(() {
        _todaySteps = 0;
        _todayCalories = 0;
        _todayWater = 0;
        _isLoading = false;
      });
    }
  }

  // --- REMOVED: _loadTodaySummary() is now part of _loadAllData() ---

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(), // Context no longer needed
            const SizedBox(height: 32),
            _buildGrid(), // Context no longer needed
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
  Widget _buildHeader() {
    return Row(
      children: [
        // --- UPDATED: The circular avatar ---
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey.shade200, // Fallback color
          backgroundImage: _profilePicPath.isNotEmpty
              ? (_profilePicPath.startsWith('http')
                  ? NetworkImage(_profilePicPath)
                  : FileImage(File(_profilePicPath))) as ImageProvider
              : null,
          child: _profilePicPath.isEmpty
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
              _username, // Use state variable, not "Sanithu"
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
        // --- InfoCards now use state variables ---
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
          // --- UPDATED: .then() calls _loadAllData ---
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddNewRecordsPage(),
              ),
            ).then((_) {
              // Re-load ALL data to refresh cards and header
              _loadAllData();
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