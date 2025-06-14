import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../data/database/database.dart';
import '../../data/repositories/supply_repository.dart';

class SuppliesScreen extends ConsumerWidget {
  const SuppliesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplies = ref.watch(supplyRepositoryProvider).watchSupplies();
    return Scaffold(
      appBar: AppBar(title: const Text('Supplies')),
      body: StreamBuilder(
        stream: supplies,
        builder: (context, AsyncSnapshot<List<Supply>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No supplies added.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final supply = snapshot.data![index];
              return ListTile(
                title: Text(supply.name),
                subtitle: Text('Quantity: ${supply.quantity}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => showEditSupplyDialog(context, ref, supply),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => ref.read(supplyRepositoryProvider).deleteSupply(supply.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddSupplyDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

void showAddSupplyDialog(BuildContext context, WidgetRef ref) {
  String name = '';
  double quantity = 1.0;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Supply'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Name'),
            onChanged: (value) => name = value,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
            onChanged: (value) => quantity = double.tryParse(value) ?? 1.0,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (name.isNotEmpty && quantity > 0) {
              final supply = SuppliesCompanion(
                name: Value(name),
                quantity: Value(quantity),
              );
              ref.read(supplyRepositoryProvider).addSupply(supply);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

void showEditSupplyDialog(BuildContext context, WidgetRef ref, Supply supply) {
  String name = supply.name;
  double quantity = supply.quantity;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Supply'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Name'),
            controller: TextEditingController(text: name),
            onChanged: (value) => name = value,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: quantity.toString()),
            onChanged: (value) => quantity = double.tryParse(value) ?? 1.0,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (name.isNotEmpty && quantity > 0) {
              final updatedSupply = SuppliesCompanion(
                name: Value(name),
                quantity: Value(quantity),
              );
              ref.read(supplyRepositoryProvider).updateSupply(supply.id, updatedSupply);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}