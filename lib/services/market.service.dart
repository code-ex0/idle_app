import 'package:test_1/managers/market.manager.dart';

class MarketService {
  final MarketManager _marketManager;
  
  MarketService(this._marketManager);
  
  // Récupère l'historique des prix pour une ressource donnée.
  List<double> getPriceHistory(String resourceId) {
    try {
      return _marketManager.getPriceHistory(resourceId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'historique des prix: $e');
    }
  }
} 