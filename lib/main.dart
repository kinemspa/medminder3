import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/notifications.dart';
import 'core/stock_checker.dart';
import 'core/theme.dart';
import 'data/providers.dart';
import 'data/repositories/in_app_purchase_repository.dart';
import 'data/repositories/medication_repository.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  final container = ProviderContainer();
  await container.read(medicationRepositoryProvider).seedSampleData();
  await container.read(inAppPurchaseRepositoryProvider).initialize();
  await container.read(stockCheckerProvider).checkLowStock();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}