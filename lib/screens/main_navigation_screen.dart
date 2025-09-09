import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'add_food_screen.dart';
import 'monthly_stats_screen.dart';
import 'profile_screen.dart';
import 'daily_analysis_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  DateTime _selectedDate = DateTime.now();
  Key _monthlyStatsKey = UniqueKey();
  Key _homeKey = UniqueKey();

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  void _onFoodSaved() {
    // Navigate to home tab after successful food entry
    setState(() {
      _currentIndex = 0;
      // Force rebuild of both home and monthly stats
      _monthlyStatsKey = UniqueKey();
      _homeKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            key: _homeKey,
            selectedDate: _selectedDate,
            onDateChanged: _onDateChanged,
          ),
          AddFoodScreen(
            selectedDate: _selectedDate,
            onSaveSuccess: _onFoodSaved,
          ),
          MonthlyStatsScreen(key: _monthlyStatsKey),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green[700],
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 28,
          elevation: 0,
          backgroundColor: Colors.transparent,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded),
              activeIcon: Icon(Icons.add_circle_rounded),
              label: 'Add Food',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        DailyAnalysisScreen(selectedDate: _selectedDate),
                  ),
                );
              },
              backgroundColor: Colors.purple[600],
              child: const Icon(Icons.psychology_rounded, color: Colors.white),
              tooltip: 'AI Analysis',
            )
          : null,
    );
  }
}
