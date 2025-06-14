import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/in_app_purchase_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(inAppPurchaseRepositoryProvider).isPremium;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
        ],
      ),
    );
  }
}