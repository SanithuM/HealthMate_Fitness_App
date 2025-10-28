import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_connection.dart';
import '../services/add_new_records.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 3. --- STATE VARIABLES ADDED ---
  // These will hold the data from the database
  int _todaySteps = 0;
  int _todayCalories = 0;
  int _todayWater = 0;
  bool _isLoading = true;

  // 4. --- INITSTATE ADDED ---
  // This function runs once when the widget is first created
  @override
  void initState() {
    super.initState();
    // Load today's data from the database as soon as the page opens
    _loadTodaySummary();
  }

  // 5. --- NEW FUNCTION: To load data from the database ---
  Future<void> _loadTodaySummary() async {
    setState(() {
      _isLoading = true; // Show loading (optional)
    });

    final dbHelper = DatabaseHelper.instance;
    // Get today's date in 'YYYY-MM-DD' format
    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // We fetch *all* records and find today's
    // A more efficient way would be to add a 'queryByDate' function
    // in your db_connection.dart, but this works for now.
    final allRecords = await dbHelper.queryAllRecords();

    // Find the record for today
    final todayRecord = allRecords.firstWhere(
      (record) => record['date'] == todayDate,
      // If no record is found, return an empty map
      orElse: () => <String, dynamic>{}, 
    );

    // Update the state with today's data
    if (todayRecord.isNotEmpty) {
      setState(() {
        _todaySteps = todayRecord['steps'] ?? 0;
        _todayCalories = todayRecord['calories'] ?? 0;
        _todayWater = todayRecord['water'] ?? 0;
        _isLoading = false;
      });
    } else {
      // If no record, set all to 0
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 6. --- CONTEXT REMOVED ---
            // No longer need to pass context to these methods
            _buildHeader(),
            const SizedBox(height: 32),
            _buildGrid(), // 7. --- CONTEXT REMOVED ---
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

  // --- Helper Widget for the Header ---
  Widget _buildHeader() { // 8. --- CONTEXT REMOVED ---
    return Row(
      // ... (Header code is unchanged) ...
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(
            'https://t4.ftcdn.net/jpg/04/31/64/75/360_F_431647519_usrbQ8Z983hTYe8zgA7t1XVc5fEtqcpa.jpg',
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning',
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
            const Text(
              'Sanithu',
              style: TextStyle(
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

  // --- Helper Widget for the 2x2 Grid ---
  Widget _buildGrid() { // 9. --- CONTEXT REMOVED ---
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        // 10. --- INFOCARDS UPDATED ---
        InfoCard(
          icon: Icons.directions_walk,
          // Use the state variable, not a hard-coded string
          value: _isLoading ? "..." : _todaySteps.toString(),
          label: 'Steps',
          color: const Color(0xFFE7F7E9),
          iconColor: const Color(0xFF3E9D5E),
          onTap: () {},
        ),
        InfoCard(
          icon: Icons.local_fire_department,
          // Use the state variable
          value: _isLoading ? "..." : _todayCalories.toString(),
          label: 'Calories Burned',
          color: const Color(0xFFFDE4E6),
          iconColor: const Color(0xFFEA868F),
          onTap: () {},
        ),
        InfoCard(
          icon: Icons.water_drop,
          // Use the state variable and format 'ml' to 'L'
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
          // 11. --- KEY CHANGE: .then() ADDED ---
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddNewRecordsPage(),
              ),
              // This code runs *after* the AddNewRecordsPage is "popped"
            ).then((_) {
              // Re-load the data from the DB to show new values
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