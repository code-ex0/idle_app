// lib/managers/market_manager.dart
import 'dart:math';

class MarketManager {
  // Map de prix par ressource (exemple : "wood" => 1.0)
  final Map<String, double> prices = {};

  // Paramètre de volatilité (exemple : 0.05 = ±5%)
  final double volatility;

  MarketManager({required List<String> resourceIds, this.volatility = 0.05}) {
    // Initialisation : tous les prix commencent à 1.0 (ou selon une logique)
    for (var id in resourceIds) {
      prices[id] = 1.0;
    }
  }

  /// Met à jour les prix selon un algorithme simple d'offre/demande.
  /// Vous pouvez passer ici des informations sur les volumes de vente, stocks, etc.
  void updatePrices(Map<String, double> supplyDemand) {
    // supplyDemand : resourceId -> un indice de pression de vente (positif = plus de vente, négatif = plus d'achat)
    prices.forEach((resourceId, currentPrice) {
      // Récupérer la pression de vente pour cette ressource (par défaut 0)
      final pressure = supplyDemand[resourceId] ?? 0.0;
      // Calcul simple : variation proportionnelle à la volatilité et à la pression.
      final delta = currentPrice * volatility * pressure;
      // Mettre à jour le prix, en s'assurant qu'il ne devienne pas négatif.
      prices[resourceId] = max(currentPrice + delta, 0.01);
    });
  }

  /// Simule une transaction d'achat.
  bool buy(String resourceId, int quantity, double offeredPrice) {
    final currentPrice = prices[resourceId] ?? 1.0;
    if (offeredPrice >= currentPrice) {
      // La transaction est validée.
      return true;
    }
    return false;
  }

  /// Simule une transaction de vente.
  bool sell(String resourceId, int quantity, double askedPrice) {
    final currentPrice = prices[resourceId] ?? 1.0;
    if (askedPrice <= currentPrice) {
      return true;
    }
    return false;
  }
}
