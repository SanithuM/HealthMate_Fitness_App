import 'package:flutter/material.dart';
import '../database/db_connection.dart';
import 'user_session.dart';
import 'dart:io'; // We'll need this for File
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:path_provider/path_provider.dart'; // For saving images
import 'package:path/path.dart' as p; // For joining paths

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _dbHelper = DatabaseHelper.instance;
  final _usernameController = TextEditingController();
  
  // This will hold the path to the new profile picture
  String _profilePicPath = ''; 
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    _currentUser = UserSession().currentUser;
    if (_currentUser != null) {
      _usernameController.text = _currentUser!['username'];
      setState(() {
        _profilePicPath = _currentUser!['profile_photo'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // --- Image Picker Logic ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Ask user to pick from Gallery
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // 1. Get the app's private document directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      // 2. Create a unique file name
      final String fileName = p.basename(image.path);
      // 3. Copy the image from the gallery to the app's private directory
      final File newImage = await File(image.path).copy('${appDir.path}/$fileName');

      // 4. Update the state to show the new image
      setState(() {
        _profilePicPath = newImage.path;
      });
    }
  }

  // --- Save Logic ---
  void _saveProfile() async {
    if (_currentUser == null) return;

    final newUsername = _usernameController.text;

    // Create the updated row map
    Map<String, dynamic> updatedRow = {
      ..._currentUser!, // Spread existing user data
      'username': newUsername,
      'profile_photo': _profilePicPath,
    };

    // Update the database
    await _dbHelper.updateUser(updatedRow);

    // Update the session
    UserSession().currentUser = updatedRow;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile Updated!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- Profile Picture Section ---
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    // Check if the path is a file or a network image
                    // This is a simple check, 'http' is for URLs, 'File' is for local
                    backgroundImage: _profilePicPath.isNotEmpty
                        ? (_profilePicPath.startsWith('http')
                            ? NetworkImage(_profilePicPath)
                            : FileImage(File(_profilePicPath))) as ImageProvider
                        : null, // Fallback
                    child: _profilePicPath.isEmpty
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF5D3EBC),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- Username Field ---
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),

            // --- Save Button ---
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D3EBC),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 0), // Full width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}