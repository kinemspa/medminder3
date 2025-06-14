import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dose_history/dose_history_screen.dart';
import '../analytics/analytics_screen.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  _InsightsScreenState createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DoseHistoryScreen(),
      AnalyticsScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        bottom: TabBar(
          onTap: (index) => setState(() => _selectedIndex = index),
          tabs: const [
            Tab(text: 'History'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: screens[_selectedIndex],
    );
  }
}