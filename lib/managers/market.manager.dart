import 'dart:math';

class MarketManager {
  /// Map des prix actuels par ressource.
  final Map<String, double> prices = {};

  /// Historique des prix par ressource.
  final Map<String, List<double>> _priceHistory = {};

  /// Map accumulant la pression de marché pour chaque ressource.
  final Map<String, double> _pressureMap = {};

  /// Le coefficient de volatilité pour les variations de prix.
  final double volatility;

  final Random _random = Random();

  MarketManager({required List<String> resourceIds, this.volatility = 0.05}) {
    for (var id in resourceIds) {
      prices[id] = 1.0;
      _priceHistory[id] = [1.0];
      _pressureMap[id] = 0.0;
    }
  }

  /// Appelle cette fonction lors d'une transaction d'achat pour augmenter la pression positive.
  void addBuyPressure(String resourceId, double volume) {
    _pressureMap[resourceId] = (_pressureMap[resourceId] ?? 0.0) + volume;
  }

  /// Appelle cette fonction lors d'une transaction de vente pour augmenter la pression négative.
  void addSellPressure(String resourceId, double volume) {
    _pressureMap[resourceId] = (_pressureMap[resourceId] ?? 0.0) - volume;
  }

  /// Simule des événements de marché aléatoires pour rendre le graphique plus dynamique.
  /// Par exemple, avec une probabilité donnée, on génère un événement d'achat ou de vente.
  void simulateRandomMarketActivity() {
    prices.forEach((resourceId, currentPrice) {
      // Avec 30% de chance de déclencher un événement aléatoire pour chaque ressource.
      if (_random.nextDouble() < 0.3) {
        // Volume aléatoire entre 0 et 10.
        final volume = _random.nextDouble() * 10;
        if (_random.nextBool()) {
          addBuyPressure(resourceId, volume);
        } else {
          addSellPressure(resourceId, volume);
        }
      }
    });
  }

  /// Met à jour les prix en utilisant la pression accumulée et un bruit aléatoire.
  void updatePrices() {
    simulateRandomMarketActivity();
    prices.forEach((resourceId, currentPrice) {
      // Utilise la pression accumulée ; s'il n'y en a pas, génère un bruit aléatoire faible.
      final pressure =
          _pressureMap[resourceId] ?? (_random.nextDouble() * 2 - 1);
      // Calcul du rendement effectif par une formule exponentielle.
      final effectiveReturn = pressure * volatility;
      final newPrice = max(currentPrice * exp(effectiveReturn), 0.01);
      prices[resourceId] = newPrice;
      _priceHistory[resourceId]?.add(newPrice);
      // Limiter l'historique
      if (_priceHistory[resourceId]!.length > 100) {
        _priceHistory[resourceId]!.removeAt(0);
      }
      // Réinitialiser la pression pour la prochaine mise à jour.
      _pressureMap[resourceId] = 0.0;
    });
  }

  List<double> getPriceHistory(String resourceId) {
    return _priceHistory[resourceId] ?? [];
  }

  // Simule une transaction d'achat et met à jour la pression
  void buyMarket(String resourceId, int quantity) {
    addBuyPressure(resourceId, quantity.toDouble());
  }

  // Simule une transaction de vente et met à jour la pression
  void sellMarket(String resourceId, int quantity) {
    addSellPressure(resourceId, quantity.toDouble());
  }
}
