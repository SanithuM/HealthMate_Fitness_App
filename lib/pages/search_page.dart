import 'package:flutter/material.dart';
import '../database/db_connection.dart';
import '../services/add_new_records.dart';
import 'package:intl/intl.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // --- STATE VARIABLES ---
  final SearchController _searchController = SearchController();
  // Master list of all records from the DB
  List<Map<String, dynamic>> _allRecords = [];
  // The list that gets displayed (and filtered)
  List<Map<String, dynamic>> _filteredHistory = [];
  bool _isLoading = true;

  // --- DATABASE FUNCTIONS ---
  @override
  void initState() {
    super.initState();
    // Load all records when the page first opens
    _loadRecords();
  }

  // Fetches all records from the database
  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
    });
    final dbHelper = DatabaseHelper.instance;
    final records = await dbHelper.queryAllRecords();
    setState(() {
      _allRecords = records;
      _filteredHistory = records; // Initially, show all records
      _isLoading = false;
    });
  }

  // Filters the list based on the search query
  void _filterRecords(String query) {
    List<Map<String, dynamic>> filteredList;
    if (query.isEmpty) {
      filteredList = _allRecords;
    } else {
      // Filter by checking if the 'date' string contains the query
      filteredList = _allRecords
          .where((record) => record['date'].toString().contains(query))
          .toList();
    }
    setState(() {
      _filteredHistory = filteredList;
    });
  }

  // --- NAVIGATION & ACTIONS ---

  // Opens the date picker to help with searching
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      _searchController.text = formattedDate; // Put the date in the search bar
      _filterRecords(formattedDate); // Trigger the filter
    }
  }

  // Navigates to the update page
  void _navigateToUpdate(Map<String, dynamic> record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Pass the tapped record to the page
        builder: (context) => AddNewRecordsPage(existingRecord: record),
      ),
      // After returning from the edit page, reload the records
    ).then((_) => _loadRecords());
  }

  // Deletes a record by its ID
  Future<void> _deleteRecord(int id) async {
    // Show a confirmation dialog first
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record?'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // If the user confirmed, proceed with deletion
    if (confirm == true) {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.deleteRecord(id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Record Deleted!'),
          backgroundColor: Colors.red,
        ),
      );
      _loadRecords(); // Refresh the list
    }
  }

  // --- DISPOSE ---
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record History'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // --- THE SEARCH BAR ---
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Search by date (YYYY-MM-DD)',
                    // Call _filterRecords every time the text changes
                    onChanged: _filterRecords,
                    trailing: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _selectDate, // Open date picker
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterRecords('');
                        },
                      ),
                    ],
                  ),
                ),
                // --- THE RESULTS LIST ---
                Expanded(
                  child: _filteredHistory.isEmpty
                      ? const Center(
                          child: Text(
                            'No records found.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredHistory.length,
                          itemBuilder: (context, index) {
                            final record = _filteredHistory[index];
                            return _buildRecordCard(record);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // --- HELPER WIDGET for the list item ---
  Widget _buildRecordCard(Map<String, dynamic> record) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          Icons.note_alt_outlined,
          color: Theme.of(context).primaryColor, // Use app theme color
        ),
        title: Text(
          // Format the date for better readability
          DateFormat.yMMMMd().format(DateTime.parse(record['date'])),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Steps: ${record['steps']} | Kcal: ${record['calories']} | Water: ${record['water']}ml',
        ),
        // --- ACTION BUTTONS ---
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- EDIT BUTTON ---
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              onPressed: () => _navigateToUpdate(record),
            ),
            // --- DELETE BUTTON ---
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteRecord(record['id']),
            ),
          ],
        ),
      ),
    );
  }
}