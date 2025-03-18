import 'package:flutter/material.dart';

class TradingPercentageSliders extends StatefulWidget {
  final double maxBuy; // valeur maximale réalisable pour l'achat
  final double maxSell; // valeur maximale réalisable pour la vente
  final Function(double buyPercent, double sellPercent) onChanged;

  const TradingPercentageSliders({
    super.key,
    required this.maxBuy,
    required this.maxSell,
    required this.onChanged,
  });

  @override
  State<TradingPercentageSliders> createState() =>
      _TradingPercentageSlidersState();
}

class _TradingPercentageSlidersState extends State<TradingPercentageSliders> {
  // Les valeurs sont en pourcentage (de 1 à 100)
  double _buyPercentage = 1;
  double _sellPercentage = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pourcentage d'achat",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [const Text("Min: 1%"), const Text("Max: 100%")],
        ),
        Slider(
          value: _buyPercentage,
          min: 1,
          max: 100,
          divisions: 99,
          label: "${_buyPercentage.toInt()}%",
          onChanged: (value) {
            setState(() {
              _buyPercentage = value;
            });
            widget.onChanged(_buyPercentage, _sellPercentage);
          },
        ),
        Text("Acheter: ${_buyPercentage.toInt()}%"),
        const SizedBox(height: 20),
        const Text(
          "Pourcentage de vente",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [const Text("Min: 1%"), const Text("Max: 100%")],
        ),
        Slider(
          value: _sellPercentage,
          min: 1,
          max: 100,
          divisions: 99,
          label: "${_sellPercentage.toInt()}%",
          onChanged: (value) {
            setState(() {
              _sellPercentage = value;
            });
            widget.onChanged(_buyPercentage, _sellPercentage);
          },
        ),
        Text("Vendre: ${_sellPercentage.toInt()}%"),
      ],
    );
  }
}
