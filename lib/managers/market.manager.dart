import 'dart:math';

class MarketManager {
  /// Map des prix actuels par ressource.
  final Map<String, double> prices = {};

  /// Historique des prix par ressource.
  final Map<String, List<double>> _priceHistory = {};

  /// Le coefficient de volatilité pour les variations de prix.
  double volatility;

  final Random _random = Random();

  final Map<String, List<MarketTransaction>> _transactions = {};
  final int _maxHistorySize = 100;

  MarketManager({required List<String> resourceIds, this.volatility = 0.05}) {
    // Initialisation : tous les prix commencent à 1.0 et on crée l'historique initial.
    for (var id in resourceIds) {
      prices[id] = 1.0;
      _priceHistory[id] = [1.0];
    }
  }

  /// Met à jour les prix selon un modèle exponentiel :
  /// newPrice = currentPrice * exp( pressure * volatility + noise )
  /// où [pressure] est issu de supplyDemand (si fourni) et [noise] est un bruit aléatoire uniforme.
  void updatePrices(Map<String, double> supplyDemand) {
    prices.forEach((resourceId, currentPrice) {
      // Récupérer la pression fournie ou 0 si absente.
      final pressure = supplyDemand[resourceId] ?? 0.0;
      // Générer un bruit aléatoire uniforme entre -volatility/2 et +volatility/2.
      final noise = (_random.nextDouble() - 0.5) * volatility;
      // Calculer le rendement effectif.
      final effectiveReturn = pressure * volatility + noise;
      // Calculer le nouveau prix en appliquant une variation exponentielle.
      final newPrice = max(currentPrice * exp(effectiveReturn), 0.01);
      prices[resourceId] = newPrice;
      _priceHistory[resourceId]?.add(newPrice);
      // Conserver seulement les 100 derniers points.
      if (_priceHistory[resourceId]!.length > 100) {
        _priceHistory[resourceId]!.removeAt(0);
      }
    });
  }

  /// Retourne l'historique des prix pour la ressource identifiée par [resourceId].
  List<double> getPriceHistory(String resourceId) {
    return _priceHistory[resourceId] ?? [];
  }

  /// Simule une transaction d'achat.
  bool buy(String resourceId, BigInt quantity, double offeredPrice) {
    final currentPrice = prices[resourceId] ?? 1.0;
    return offeredPrice >= currentPrice;
  }

  /// Simule une transaction de vente.
  bool sell(String resourceId, BigInt quantity, double askedPrice) {
    final currentPrice = prices[resourceId] ?? 1.0;
    return askedPrice <= currentPrice;
  }

  /// Définit la nouvelle valeur de volatilité du marché.
  void setVolatility(double newVolatility) {
    volatility = newVolatility;
  }

  void addTransaction(String resourceId, MarketTransaction transaction) {
    if (!_transactions.containsKey(resourceId)) {
      _transactions[resourceId] = [];
    }
    _transactions[resourceId]!.add(transaction);
    
    // Conserver seulement les 100 derniers points.
    if (_transactions[resourceId]!.length > _maxHistorySize) {
      _transactions[resourceId]!.removeAt(0);
    }
  }

  List<MarketTransaction> getTransactionHistory(String resourceId) {
    return _transactions[resourceId] ?? [];
  }
}

class MarketTransaction {
  final DateTime timestamp;
  final BigInt quantity;
  final double price;
  final bool isBuy;

  MarketTransaction({
    required this.timestamp,
    required this.quantity,
    required this.price,
    required this.isBuy,
  });
}
