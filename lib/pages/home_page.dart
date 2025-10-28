import 'package:flutter/material.dart';
import '../services/add_new_records.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        // Add padding around the whole page
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. --- The Custom Header ---
            _buildHeader(context), // <-- Pass context
            const SizedBox(height: 32),

            // 2. --- The 2x2 Grid ---
            _buildGrid(context), // <-- Pass context
            
            // 3. --- Image Banner ---
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
  Widget _buildHeader(BuildContext context) { // <-- Receive context
    return Row(
      children: [
        // The circular avatar
        const CircleAvatar(
          radius: 30,
          // 2. profile image
          backgroundImage: NetworkImage(
            'https://t4.ftcdn.net/jpg/04/31/64/75/360_F_431647519_usrbQ8Z983hTYe8zgA7t1XVc5fEtqcpa.jpg',
          ),
        ),
        const SizedBox(width: 16),
        // The "Good Morning, Sanithu" text
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
        // Spacer to push the icon to the end
        const Spacer(),
        // Notification Bell Icon
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
  Widget _buildGrid(BuildContext context) { // <-- Receive context
    return GridView.count(
      crossAxisCount: 2,
      // These two lines are important to make the GridView
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Spacing between the cards
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        // Custom InfoCard widget
        InfoCard(
          icon: Icons.directions_walk,
          value: '254',
          label: 'Steps',
          color: const Color(0xFFFEF5D3),
          iconColor: const Color(0xFFE8B420),
          onTap: () {}, // Can add navigation later
        ),
        InfoCard(
          icon: Icons.local_fire_department,
          value: '10',
          label: 'Calories Burned',
          color: const Color(0xFFFDE4E6), 
          iconColor: const Color(0xFFEA868F),
          onTap: () {}, // Can add navigation later
        ),
        InfoCard(
          icon: Icons.water_drop,
          value: '2.5 L',
          label: 'Water Intake',
          color: const Color(0xFFE4F3FF), 
          iconColor: const Color(0xFF70B3F2),
          onTap: () {}, // Can add navigation later
        ),
        InfoCard(
          icon: Icons.add,
          label: 'Add New',
          color: const Color(0xFFEAEAEA),
          iconColor: const Color(0xFF3A3A3A),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddNewRecordsPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}

// --- A Reusable Widget for the Info Cards ---
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.icon,
    this.value,
    required this.label,
    required this.color,
    required this.iconColor,
    this.onTap, // <-- 1. ADDED: The onTap parameter
  });

  final IconData icon;
  final String? value;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback? onTap; // <-- 2. ADDED: The onTap property

  @override
  Widget build(BuildContext context) {
    // 3. WRAPPED: The Container is now in an InkWell to make it tappable
    return InkWell(
      onTap: onTap, // <-- 4. USED: Assign the onTap callback
      borderRadius:
          BorderRadius.circular(20), // <-- 5. ADDED: For a clean ripple effect
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