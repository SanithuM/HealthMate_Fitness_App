import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_connection.dart'; 


class AddNewRecordsPage extends StatefulWidget {
  final Map<String, dynamic>? existingRecord;

  const AddNewRecordsPage({
    super.key,
    this.existingRecord,
  });

  @override
  State<AddNewRecordsPage> createState() => _AddNewRecordsPageState();
}

class _AddNewRecordsPageState extends State<AddNewRecordsPage> {
  final _stepsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _waterController = TextEditingController();

  bool _isUpdateMode = false;
  int? _existingRecordId;

  @override
  void initState() {
    super.initState();

    if (widget.existingRecord != null) {
      _isUpdateMode = true;
      _existingRecordId = widget.existingRecord!['id'];
      _stepsController.text = widget.existingRecord!['steps'].toString();
      _caloriesController.text = widget.existingRecord!['calories'].toString();
      _waterController.text = widget.existingRecord!['water'].toString();
    }
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _stepsController.clear();
    _caloriesController.clear();
    _waterController.clear();
  }

  // --- SAVERECORD ---
  void _saveRecord() async {
    final dbHelper = DatabaseHelper.instance;

    final int steps = int.tryParse(_stepsController.text) ?? 0;
    final int calories = int.tryParse(_caloriesController.text) ?? 0;
    final int water = int.tryParse(_waterController.text) ?? 0;

    if (steps == 0 && calories == 0 && water == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one value.'),
          backgroundColor: Colors.red,
        ),
      );
      return; 
    }

    // Try...catch block for database operations ---
    try {
      if (_isUpdateMode) {
        // --- Handle UPDATE ---
        Map<String, dynamic> row = {
          'id': _existingRecordId,
          'date': widget.existingRecord!['date'],
          'steps': steps,
          'calories': calories,
          'water': water,
        };

        await dbHelper.updateRecord(row); 
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record Updated!'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        // --- Handle ADD NEW ---
        final String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

        Map<String, dynamic> row = {
          'date': date,
          'steps': steps,
          'calories': calories,
          'water': water,
        };

        await dbHelper.insertRecord(row); 
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record Saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (!mounted) return;
      Navigator.pop(context);

    } catch (e) {
      // --- Error handling ---
      print("Error saving record: $e");
      // Check if mounted before showing the error SnackBar too!
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving record: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isUpdateMode ? 'Update Record' : 'Add New Record'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: _stepsController,
              label: 'Steps',
              icon: Icons.directions_walk,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _caloriesController,
              label: 'Calories Burned',
              icon: Icons.local_fire_department,
              suffixText: 'kcal',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _waterController,
              label: 'Water Intake',
              icon: Icons.water_drop,
              suffixText: 'ml',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearFields,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: const Text('Clear',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveRecord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D3EBC),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isUpdateMode ? 'Update' : 'Save',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? suffixText,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixText: suffixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: Color(0xFF5D3EBC),
            width: 2.0,
          ),
        ),
      ),
    );
  }
}