import 'package:flutter/material.dart';
import 'package:testing/pages/search_page.dart';
import 'package:testing/pages/settings_page.dart';
import '../pages/home_page.dart';



class NavigationBarTest extends StatefulWidget {
  const NavigationBarTest({super.key});

  @override
  State<NavigationBarTest> createState() => _NavigationBarTestState();
}

class _NavigationBarTestState extends State<NavigationBarTest> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),     
    SearchPage(),    
    SettingsPage(),  
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: Theme(
            data: Theme.of(context).copyWith(
              navigationBarTheme: NavigationBarThemeData(
                indicatorColor: const Color(0xFFD4C5FE),
              ),
            ),
            child: NavigationBar(
              backgroundColor: const Color(0xFFF1EDFD),
              height: 80,
              elevation: 0,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              
              destinations: const [
                NavigationDestination(
                  selectedIcon: Icon(Icons.home, color: Color(0xFF5D3EBC)),
                  icon: Icon(Icons.home, color: Colors.black54),
                  label: 'Home',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.search, color: Color(0xFF5D3EBC)),
                  icon: Icon(Icons.search, color: Colors.black54),
                  label: 'Search',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.settings, color: Color(0xFF5D3EBC)),
                  icon: Icon(Icons.settings, color: Colors.black54),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
      
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}