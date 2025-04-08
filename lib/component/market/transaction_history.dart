import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:test_1/managers/market.manager.dart';
import 'package:test_1/services/game_state.service.dart';

class TransactionHistory extends StatelessWidget {
  final String resourceId;
  
  const TransactionHistory({
    super.key,
    required this.resourceId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        final colorScheme = Theme.of(context).colorScheme;
        
        // Récupérer les transactions et les ordres limites exécutés
        final transactions = gameState.marketManager.getTransactionHistory(resourceId);
        final executedOrders = gameState.marketManager.getExecutedLimitOrders(resourceId);
        
        // Créer une liste combinée pour l'affichage
        final combinedHistory = <HistoryItem>[];
        
        // Ajouter les transactions
        for (final transaction in transactions) {
          combinedHistory.add(
            TransactionItem(
              timestamp: transaction.timestamp,
              quantity: transaction.quantity,
              price: transaction.price,
              isBuy: transaction.isBuy,
              isOrderExecution: false,
            ),
          );
        }
        
        // Ajouter les ordres limites exécutés
        for (final order in executedOrders) {
          if (order.status == OrderStatus.executed && order.executedAt != null) {
            // Vérifier s'il y a un doublon (transaction déjà enregistrée)
            bool isDuplicate = false;
            for (final item in combinedHistory) {
              if (item is TransactionItem && 
                  (item.timestamp.difference(order.executedAt!).inSeconds.abs() < 2) && 
                  item.quantity == order.quantity && 
                  item.price == (order.executionPrice ?? order.targetPrice) &&
                  item.isBuy == (order.type == OrderType.buy)) {
                isDuplicate = true;
                break;
              }
            }
            
            if (!isDuplicate) {
              combinedHistory.add(
                TransactionItem(
                  timestamp: order.executedAt!,
                  quantity: order.quantity,
                  price: order.executionPrice ?? order.targetPrice,
                  isBuy: order.type == OrderType.buy,
                  isOrderExecution: true,
                  orderTargetPrice: order.targetPrice,
                ),
              );
            }
          }
        }
        
        // Trier par date (plus récentes d'abord)
        combinedHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        if (combinedHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: colorScheme.onSurface.withAlpha(77),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune transaction pour le moment',
                  style: TextStyle(
                    color: colorScheme.onSurface.withAlpha(128),
                    fontSize: 16,
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
              child: Text(
                'Historique des transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: combinedHistory.length,
                itemBuilder: (context, index) {
                  final item = combinedHistory[index];
                  
                  if (item is TransactionItem) {
                    return _buildTransactionCard(context, item, colorScheme, resourceId);
                  }
                  
                  // Fallback (ne devrait jamais arriver)
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildTransactionCard(
    BuildContext context, 
    TransactionItem item, 
    ColorScheme colorScheme,
    String resourceId,
  ) {
    final isToday = item.timestamp.day == DateTime.now().day &&
                   item.timestamp.month == DateTime.now().month &&
                   item.timestamp.year == DateTime.now().year;
    
    final dateFormat = isToday 
        ? DateFormat('HH:mm') 
        : DateFormat('dd/MM/yy HH:mm');
    
    final formattedDate = dateFormat.format(item.timestamp);
    final transactionType = item.isBuy ? 'Achat' : 'Vente';
    final color = item.isBuy ? Colors.green : Colors.red;
    final icon = item.isOrderExecution 
        ? (item.isBuy ? Icons.playlist_add_check : Icons.playlist_remove) 
        : (item.isBuy ? Icons.add_circle : Icons.remove_circle);
    
    final subtitle = item.isOrderExecution
        ? 'Ordre limite exécuté à \$${item.price.toStringAsFixed(2)} • $formattedDate'
        : 'Prix: \$${item.price.toStringAsFixed(2)} • $formattedDate';
    
    final total = (item.price * item.quantity.toDouble()).toStringAsFixed(2);
    final action = item.isBuy ? '-\$$total' : '+\$$total';
    
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
            icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          '$transactionType de ${item.quantity} $resourceId',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withAlpha(179)),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              action,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (item.isOrderExecution && item.orderTargetPrice != null)
              Text(
                'Cible: \$${item.orderTargetPrice!.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurface.withAlpha(128),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Base class pour les éléments d'historique
abstract class HistoryItem {
  final DateTime timestamp;
  
  HistoryItem({required this.timestamp});
}

/// Item pour représenter une transaction ou un ordre exécuté
class TransactionItem extends HistoryItem {
  final BigInt quantity;
  final double price;
  final bool isBuy;
  final bool isOrderExecution;
  final double? orderTargetPrice;
  
  TransactionItem({
    required super.timestamp,
    required this.quantity,
    required this.price,
    required this.isBuy,
    required this.isOrderExecution,
    this.orderTargetPrice,
  });
} 