import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/game_state.dart';
import 'package:test_1/interfaces/resource.interface.dart';

class MarketItem extends StatelessWidget {
  const MarketItem({super.key, required this.resource});

  final Resource resource;

  String get priceText {
    final sellPrice = (resource.value / 2).round();
    return 'Prix de vente: $sellPrice';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Column(
        children: <Widget>[
          ListTile(
            // Display an image for the resource in a fixed square.
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
              child: Image.asset(
                'assets/icon/${resource.id}.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.image, size: 30));
                },
              ),
            ),
            title: Text(resource.name),
            subtitle: Text(priceText),
            trailing: Column(
              // mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Display the quantity of the resource.
                Text('Stock: ${resource.amount}'),
                // const SizedBox(width: 8),
                // Display the value of the resource.
                Text(
                  '${context.read<GameState>().reateProduction(resource.id)} / s',
                ),
              ],
            ),
          ),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            spacing: 8,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  // Implement your sell logic here.
                  context.read<GameState>().sellResource(resource.id, 1);
                },
                child: const Text('Vendre'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
