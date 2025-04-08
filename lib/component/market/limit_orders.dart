import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:test_1/managers/market.manager.dart';
import 'package:test_1/services/game_state.service.dart';

class LimitOrdersList extends StatelessWidget {
  final String resourceId;
  
  const LimitOrdersList({
    super.key,
    required this.resourceId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        final colorScheme = Theme.of(context).colorScheme;
        final limitOrders = gameState.getLimitOrders(resourceId)
          .where((order) => order.status == OrderStatus.pending)
          .toList();
        
        if (limitOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 48,
                  color: colorScheme.onSurface.withAlpha(77),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun ordre limite en attente',
                  style: TextStyle(
                    color: colorScheme.onSurface.withAlpha(128),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showAddLimitOrderDialog(context, gameState),
                  icon: const Icon(Icons.add),
                  label: const Text('Nouvel ordre limite'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ordres limites actifs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (limitOrders.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            gameState.forceExecuteLimitOrders();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Vérification des ordres limites en cours...'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Rafraîchir'),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        color: colorScheme.primary,
                        onPressed: () => _showAddLimitOrderDialog(context, gameState),
                        tooltip: 'Nouvel ordre limite',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: limitOrders.length,
                itemBuilder: (context, index) {
                  final order = limitOrders[index];
                  final isLongTime = DateTime.now().difference(order.createdAt).inHours > 1;
                  
                  final dateFormat = isLongTime
                      ? DateFormat('dd/MM HH:mm')
                      : DateFormat('HH:mm');
                  
                  final formattedDate = dateFormat.format(order.createdAt);
                  final orderType = order.type == OrderType.buy ? 'Achat' : 'Vente';
                  final color = order.type == OrderType.buy ? Colors.green : Colors.red;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: colorScheme.outline.withAlpha(51),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withAlpha(26),
                        child: Icon(
                          order.type == OrderType.buy ? Icons.arrow_downward : Icons.arrow_upward,
                          color: color,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        '$orderType de ${order.quantity} $resourceId si le prix ${order.type == OrderType.buy ? 'descend à' : 'monte à'} \$${order.targetPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                      subtitle: Text(
                        'Créé le $formattedDate',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withAlpha(128)),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.grey,
                        onPressed: () {
                          gameState.cancelLimitOrder(resourceId, order.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Ordre limite annulé'),
                              backgroundColor: colorScheme.error,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        tooltip: 'Annuler',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showAddLimitOrderDialog(BuildContext context, GameState gameState) {
    final currentPrice = gameState.marketManager.prices[resourceId] ?? 1.0;
    final resource = gameState.resourceManager.resources[resourceId];
    if (resource == null) return;
    
    bool isBuyOrder = true;
    double targetPrice = currentPrice;
    int quantity = 1;
    
    // Contrôleurs pour les champs texte
    final priceController = TextEditingController(text: targetPrice.toStringAsFixed(2));
    final quantityController = TextEditingController(text: quantity.toString());
    
    // Fonction pour mettre à jour les valeurs
    void updatePriceFromText() {
      try {
        final newPrice = double.parse(priceController.text);
        if (newPrice > 0) {
          targetPrice = newPrice;
        }
      } catch (e) {
        // Ignorer en cas d'erreur de parsing
      }
    }
    
    void updateQuantityFromText() {
      try {
        final newQuantity = int.parse(quantityController.text);
        if (newQuantity > 0) {
          quantity = newQuantity;
        }
      } catch (e) {
        // Ignorer en cas d'erreur de parsing
      }
    }
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final colorScheme = Theme.of(context).colorScheme;
            final buyDisabled = isBuyOrder && targetPrice > currentPrice;
            final sellDisabled = !isBuyOrder && targetPrice < currentPrice;
            
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Row(
                      children: [
                        Text(
                          'Nouvel ordre limite',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Prix: \$${currentPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    
                    // Type d'ordre
                    Text(
                      'Type d\'ordre',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface.withAlpha(128),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isBuyOrder = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isBuyOrder 
                                      ? Colors.green.withAlpha(51) 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "ACHAT",
                                  style: TextStyle(
                                    color: isBuyOrder ? Colors.green : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isBuyOrder = false;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: !isBuyOrder 
                                      ? Colors.red.withAlpha(51) 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "VENTE",
                                  style: TextStyle(
                                    color: !isBuyOrder ? Colors.red : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Prix cible
                    Row(
                      children: [
                        Text(
                          'Prix cible',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface.withAlpha(128),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isBuyOrder ? 'Acheter si ≤' : 'Vendre si ≥',
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Slider avec champ texte pour le prix
                    Row(
                      children: [
                        Text('\$'),
                        Expanded(
                          child: Slider(
                            value: targetPrice,
                            min: currentPrice * 0.5,
                            max: currentPrice * 1.5,
                            divisions: 100,
                            activeColor: isBuyOrder ? Colors.green : Colors.red,
                            onChanged: (value) {
                              setState(() {
                                targetPrice = value;
                                priceController.text = value.toStringAsFixed(2);
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          height: 28,
                          child: TextField(
                            controller: priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: Colors.grey.withAlpha(77)),
                              ),
                            ),
                            onChanged: (value) {
                              try {
                                final newPrice = double.parse(value);
                                setState(() {
                                  if (newPrice > 0) {
                                    targetPrice = newPrice;
                                  }
                                });
                              } catch (e) {
                                // Ignorer
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    if (isBuyOrder && buyDisabled || !isBuyOrder && sellDisabled)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        isBuyOrder 
                            ? 'Prix cible doit être < prix actuel' 
                            : 'Prix cible doit être > prix actuel',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Quantité avec champ texte
                    Row(
                      children: [
                        Text(
                          'Quantité',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface.withAlpha(128),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                          onPressed: quantity > 1 ? () {
                            setState(() {
                              quantity--;
                              quantityController.text = quantity.toString();
                            });
                          } : null,
                          color: Colors.grey,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 50,
                          height: 28,
                          child: TextField(
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: Colors.grey.withAlpha(77)),
                              ),
                            ),
                            onChanged: (value) {
                              try {
                                final newQuantity = int.parse(value);
                                setState(() {
                                  if (newQuantity > 0) {
                                    quantity = newQuantity;
                                  }
                                });
                              } catch (e) {
                                // Ignorer
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          onPressed: () {
                            setState(() {
                              quantity++;
                              quantityController.text = quantity.toString();
                            });
                          },
                          color: Colors.grey,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Résumé plus compact
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isBuyOrder ? Colors.green : Colors.red).withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBuyOrder
                                ? 'Vous passerez un ordre d\'achat de $quantity $resourceId à \$${targetPrice.toStringAsFixed(2)}.' 
                                : 'Vous passerez un ordre de vente de $quantity $resourceId à \$${targetPrice.toStringAsFixed(2)}.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isBuyOrder
                                ? 'Coût total: \$${(targetPrice * quantity).toStringAsFixed(2)} • Exécuté quand prix ≤ ${targetPrice.toStringAsFixed(2)}'
                                : 'Gain total: \$${(targetPrice * quantity).toStringAsFixed(2)} • Exécuté quand prix ≥ ${targetPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurface.withAlpha(178),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Boutons
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Annuler'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: (isBuyOrder && targetPrice >= currentPrice || !isBuyOrder && targetPrice <= currentPrice)
                                ? null
                                : () {
                                    // Mettre à jour les valeurs à partir des champs texte
                                    updatePriceFromText();
                                    updateQuantityFromText();
                                    
                                    final success = isBuyOrder
                                        ? gameState.createBuyLimitOrder(
                                            resourceId,
                                            BigInt.from(quantity),
                                            targetPrice,
                                          )
                                        : gameState.createSellLimitOrder(
                                            resourceId,
                                            BigInt.from(quantity),
                                            targetPrice,
                                          );
                                    
                                    if (success) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isBuyOrder
                                                ? 'Ordre d\'achat limite créé avec succès'
                                                : 'Ordre de vente limite créé avec succès'
                                          ),
                                          backgroundColor: isBuyOrder ? Colors.green : Colors.red,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Erreur lors de la création de l\'ordre limite'),
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isBuyOrder ? Colors.green : Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Créer'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
} 