import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/services/game_state.service.dart';

class MarketChart extends StatelessWidget {
  final String resourceId;
  const MarketChart({super.key, required this.resourceId});

  List<FlSpot> _generateSpots(List<double> priceHistory, int fixedCount) {
    final int dataLength = priceHistory.length;
    // Si dataLength est inférieur à fixedCount, on décale pour que les données soient à droite.
    final int offset = fixedCount - dataLength;
    return List.generate(dataLength, (index) {
      return FlSpot((offset + index).toDouble(), priceHistory[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    const int fixedCount = 50;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        // Récupérer l'historique complet des prix pour la resource
        final fullHistory = gameState.marketManager.getPriceHistory(resourceId);
        // On affiche uniquement les derniers fixedCount points, ou tous s'il y en a moins.
        final priceHistory =
            fullHistory.length >= fixedCount
                ? fullHistory.sublist(fullHistory.length - fixedCount)
                : fullHistory;
                
        if (priceHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timeline_outlined,
                  size: 48,
                  color: colorScheme.onSurface.withAlpha(77),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pas de données disponibles',
                  style: TextStyle(
                    color: colorScheme.onSurface.withAlpha(128),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
        
        // Déterminer si la tendance est à la hausse ou à la baisse
        final firstPrice = priceHistory.first;
        final lastPrice = priceHistory.last;
        final isUp = lastPrice >= firstPrice;
        
        // Calculer les valeurs min et max et ajouter une marge de 5%
        double minY = priceHistory.reduce((a, b) => a < b ? a : b);
        double maxY = priceHistory.reduce((a, b) => a > b ? a : b);
        final range = maxY - minY;
        minY = minY - (range * 0.05);
        maxY = maxY + (range * 0.05);
        
        final mainColor = isUp ? Colors.green : Colors.red;
        final spots = _generateSpots(priceHistory, fixedCount);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: fixedCount - 1,
              minY: minY > 0 ? minY : 0,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                horizontalInterval: (maxY - minY) / 6 > 0 ? (maxY - minY) / 6 : 1.0,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withAlpha(26),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withAlpha(26),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: Colors.grey.withAlpha(51),
                  width: 1,
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    interval: (maxY - minY) / 6 > 0 ? (maxY - minY) / 6 : 1.0,
                    getTitlesWidget: (value, meta) {
                      // Ne pas afficher le titre si c'est proche de maxY ou minY
                      if (value == maxY || value == minY) return const SizedBox();
                      
                      return Container(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          value.toStringAsFixed(2),
                          style: TextStyle(
                            color: colorScheme.onSurface.withAlpha(153),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => colorScheme.surface.withAlpha(204),
                  tooltipMargin: 8,
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final index = spot.x.toInt();
                      final price = spot.y;
                      final formattedPrice = price.toStringAsFixed(2);
                      
                      return LineTooltipItem(
                        '$formattedPrice\$',
                        TextStyle(
                          color: mainColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: '\nIndex: $index',
                            style: TextStyle(
                              color: colorScheme.onSurface.withAlpha(153),
                              fontWeight: FontWeight.normal,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
                touchSpotThreshold: 20,
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: mainColor,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: false,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: mainColor,
                        strokeWidth: 1,
                        strokeColor: colorScheme.surface,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        mainColor.withAlpha(77),
                        mainColor.withAlpha(13),
                      ],
                    ),
                  ),
                ),
              ],
              // Ajout d'une ligne horizontale pour le dernier prix
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: lastPrice,
                    color: mainColor,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 5, bottom: 5),
                      style: TextStyle(
                        color: mainColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        backgroundColor: colorScheme.surface,
                      ),
                      labelResolver: (line) => '${lastPrice.toStringAsFixed(2)}\$',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
