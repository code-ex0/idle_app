import 'dart:math';
import 'package:flutter/foundation.dart';

class MarketManager {
  /// Map des prix actuels par ressource.
  final Map<String, double> prices = {};

  /// Historique des prix par ressource.
  final Map<String, List<double>> _priceHistory = {};

  /// Le coefficient de volatilité pour les variations de prix.
  double volatility;

  final Random _random = Random();

  final Map<String, List<MarketTransaction>> _transactions = {};
  final Map<String, List<LimitOrder>> _limitOrders = {};
  final Map<String, List<LimitOrder>> _executedLimitOrders = {};

  final int _maxHistorySize = 100;

  MarketManager({required List<String> resourceIds, this.volatility = 0.05}) {
    if (resourceIds.isEmpty) {
      throw Exception(
        'La liste des ressources ne peut pas être vide pour initialiser le MarketManager',
      );
    }

    // Initialisation : tous les prix commencent à 1.0 et on crée l'historique initial.
    for (var id in resourceIds) {
      prices[id] = 1.0;
      _priceHistory[id] = [1.0];
      _limitOrders[id] = [];
      _executedLimitOrders[id] = [];
    }

    debugPrint(
      'MarketManager initialisé avec ${resourceIds.length} ressources',
    );
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

      // Vérifier si des ordres limites peuvent être exécutés avec ce nouveau prix
      _checkLimitOrders(resourceId, newPrice);
    });
  }

  /// Vérifie et marque les ordres limites prêts à être exécutés
  void _checkLimitOrders(String resourceId, double currentPrice) {
    final orders = _limitOrders[resourceId];
    if (orders == null || orders.isEmpty) return;

    // On garde tous les ordres dans la liste, mais on marque ceux qui sont prêts à être exécutés
    for (final order in orders) {
      if (order.shouldExecute(currentPrice)) {
        order.status = OrderStatus.readyToExecute;
        order.executionPrice = currentPrice;
      }
    }
  }

  /// Retourne l'historique des prix pour la ressource identifiée par [resourceId].
  List<double> getPriceHistory(String resourceId) {
    // Si pas d'historique ou historique vide, on génère un historique vide et on lance une exception
    if (!_priceHistory.containsKey(resourceId) ||
        _priceHistory[resourceId]!.isEmpty) {
      _priceHistory[resourceId] = [prices[resourceId] ?? 1.0];
      throw Exception(
        'Aucun historique de prix disponible pour la ressource: $resourceId',
      );
    }

    return _priceHistory[resourceId]!;
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

  /// Ajoute un ordre limite pour une ressource
  void addLimitOrder(String resourceId, LimitOrder order) {
    if (!_limitOrders.containsKey(resourceId)) {
      _limitOrders[resourceId] = [];
    }
    _limitOrders[resourceId]!.add(order);
  }

  /// Récupère tous les ordres limites actifs pour une ressource
  List<LimitOrder> getLimitOrders(String resourceId) {
    return _limitOrders[resourceId] ?? [];
  }

  /// Annule un ordre limite spécifique
  bool cancelLimitOrder(String resourceId, String orderId) {
    final orders = _limitOrders[resourceId];
    if (orders == null) return false;

    final initialLength = orders.length;
    _limitOrders[resourceId] =
        orders.where((order) => order.id != orderId).toList();

    return initialLength != _limitOrders[resourceId]!.length;
  }

  /// Récupère les ordres limites prêts à être exécutés
  List<LimitOrder> getReadyLimitOrders(String resourceId) {
    final orders = _limitOrders[resourceId];
    if (orders == null) return [];

    final readyOrders =
        orders
            .where((order) => order.status == OrderStatus.readyToExecute)
            .toList();
    return readyOrders;
  }

  /// Récupère l'historique des ordres limites exécutés
  List<LimitOrder> getExecutedLimitOrders(String resourceId) {
    return _executedLimitOrders[resourceId] ?? [];
  }

  /// Ajoute un ordre exécuté à l'historique
  void addExecutedLimitOrder(String resourceId, LimitOrder order) {
    if (!_executedLimitOrders.containsKey(resourceId)) {
      _executedLimitOrders[resourceId] = [];
    }
    _executedLimitOrders[resourceId]!.add(order);

    // Conserver uniquement les derniers ordres
    if (_executedLimitOrders[resourceId]!.length > _maxHistorySize) {
      _executedLimitOrders[resourceId]!.removeAt(0);
    }
  }

  /// Supprime les ordres exécutés de la liste active
  void removeExecutedOrders(String resourceId, List<String> orderIds) {
    final orders = _limitOrders[resourceId];
    if (orders == null || orders.isEmpty) return;
    _limitOrders[resourceId] =
        orders.where((order) => !orderIds.contains(order.id)).toList();
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

enum OrderType {
  buy, // Achat (se déclenche quand le prix baisse sous le seuil)
  sell, // Vente (se déclenche quand le prix monte au-dessus du seuil)
}

enum OrderStatus {
  pending, // En attente
  readyToExecute, // Prêt à être exécuté (prix atteint)
  executed, // Exécuté
  canceled, // Annulé
  expired, // Expiré
}

class LimitOrder {
  final String id;
  final OrderType type;
  final String resourceId;
  final BigInt quantity;
  final double targetPrice;
  final DateTime createdAt;
  final DateTime? expiresAt;

  OrderStatus status;
  double? executionPrice;
  DateTime? executedAt;

  LimitOrder({
    required this.id,
    required this.type,
    required this.resourceId,
    required this.quantity,
    required this.targetPrice,
    required this.createdAt,
    this.expiresAt,
    this.status = OrderStatus.pending,
    this.executionPrice,
    this.executedAt,
  });

  /// Vérifie si l'ordre doit être exécuté en fonction du prix actuel
  bool shouldExecute(double currentPrice) {
    // Vérifier si l'ordre a expiré
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) {
      status = OrderStatus.expired;
      return false;
    }

    // Vérifier si l'ordre est déjà exécuté ou annulé
    if (status == OrderStatus.executed ||
        status == OrderStatus.canceled ||
        status == OrderStatus.expired) {
      return false;
    }

    // Pour un ordre d'achat, le prix doit être inférieur ou égal au prix cible
    if (type == OrderType.buy && currentPrice <= targetPrice) {
      return true;
    }

    // Pour un ordre de vente, le prix doit être supérieur ou égal au prix cible
    if (type == OrderType.sell && currentPrice >= targetPrice) {
      return true;
    }

    return false;
  }

  /// Marque l'ordre comme exécuté
  void markAsExecuted(double price) {
    executionPrice = price;
    executedAt = DateTime.now();
    status = OrderStatus.executed;
  }

  /// Annule l'ordre
  void cancel() {
    status = OrderStatus.canceled;
  }
}
