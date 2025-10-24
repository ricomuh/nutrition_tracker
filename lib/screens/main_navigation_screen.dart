import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/app_lifecycle_provider.dart';
import '../services/widget_action_service.dart';
import 'home_screen.dart';
import 'add_food_screen.dart';
import 'monthly_stats_screen.dart';
import 'profile_screen.dart';
import 'daily_analysis_screen.dart';
import 'quick_camera_screen.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAppLifecycleIntegration();

      // Initialize widget action service
      WidgetActionService().initialize(context);
    });
  }

  void _setupAppLifecycleIntegration() {
    final nutritionProvider = context.read<NutritionProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final appLifecycleProvider = context.read<AppLifecycleProvider>();

    // Setup callback for when nutrition data changes
    nutritionProvider.setOnDataChanged(() {
      appLifecycleProvider.updateAppData(
        entries: nutritionProvider.entries,
        userProfile: settingsProvider.userProfile,
        date: _selectedDate,
      );
    });
  }

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

  void _openQuickCamera() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuickCameraScreen(
          selectedDate: _selectedDate,
          onSaveSuccess: () {
            // Refresh home screen after adding food from quick camera
            setState(() {
              _homeKey = UniqueKey();
              _monthlyStatsKey = UniqueKey();
            });
          },
        ),
      ),
    );
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
          iconSize: 24,
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
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: "camera",
                  onPressed: _openQuickCamera,
                  backgroundColor: Colors.green[600],
                  tooltip: 'Quick Camera',
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                  ),
                ),
                FloatingActionButton(
                  heroTag: "analysis",
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            DailyAnalysisScreen(selectedDate: _selectedDate),
                      ),
                    );
                  },
                  backgroundColor: Colors.purple[600],
                  tooltip: 'AI Analysis',
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          : null,
    );
  }
}
