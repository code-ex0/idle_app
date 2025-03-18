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
          return const Center(child: Text('Pas de données'));
        }
        final spots = _generateSpots(priceHistory, fixedCount);
        final minY = priceHistory.reduce((a, b) => a < b ? a : b);
        final maxY = priceHistory.reduce((a, b) => a > b ? a : b);

        return Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: fixedCount * 20.0,
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                duration: Duration.zero,
                LineChartData(
                  minX: 0,
                  maxX: fixedCount - 1,
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Colors.grey),
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: fixedCount / 10,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: (maxY - minY) == 0 ? 1 : (maxY - minY) / 5,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toStringAsFixed(1));
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue.withValues(alpha: 0.3),
                            Colors.black38,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
