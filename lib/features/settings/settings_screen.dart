import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../data/providers.dart';
import '../../data/repositories/in_app_purchase_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(inAppPurchaseRepositoryProvider).isPremium;
    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Account Status'),
            subtitle: Text(isPremium ? 'Premium Active' : 'Free Account'),
            trailing: !isPremium
                ? ElevatedButton(
              onPressed: () => ref.read(inAppPurchaseRepositoryProvider).purchasePremium(),
              child: const Text('Upgrade to Premium'),
            )
                : null,
          ),
          const ListTile(
            title: Text('Premium Features'),
            subtitle: Text('Unlock advanced analytics, unlimited supplies, and custom notifications.'),
          ),
          ListTile(
            title: const Text('Default Low Stock Threshold'),
            subtitle: Consumer(
              builder: (context, ref, child) {
                final threshold = ref.watch(defaultLowStockThresholdProvider);
                return Slider(
                  value: threshold,
                  min: 1.0,
                  max: 50.0,
                  divisions: 49,
                  label: threshold.toStringAsFixed(1),
                  onChanged: (value) => ref.read(defaultLowStockThresholdProvider.notifier).state = value,
                );
              },
            ),
          ),
          ListTile(
            title: const Text('Default Postpone Duration (Minutes)'),
            subtitle: Consumer(
              builder: (context, ref, child) {
                final minutes = ref.watch(defaultPostponeMinutesProvider);
                return Slider(
                  value: minutes.toDouble(),
                  min: 10,
                  max: 120,
                  divisions: 11,
                  label: minutes.toString(),
                  onChanged: (value) => ref.read(defaultPostponeMinutesProvider.notifier).state = value.round(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}