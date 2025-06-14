import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/notifications.dart';
import 'core/theme.dart';
import 'data/repositories/in_app_purchase_repository.dart';
import 'data/repositories/medication_repository.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  final container = ProviderContainer();
  await container.read(medicationRepositoryProvider).seedSampleData();
  await container.read(inAppPurchaseRepositoryProvider).initialize();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: HomeScreen(),
    );
  }
}