import 'package:flutter/material.dart';

class MarketAdvancedPage extends StatelessWidget {
  const MarketAdvancedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marché Avancé')),
      body: const Center(
        child: Text(
          'Graphique et fonctionnalités avancées à venir...',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
