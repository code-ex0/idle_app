import 'package:test_1/interfaces/building.interface.dart';

class BuildingGroup {
  final Building config;
  BigInt count;
  List<BigInt> listDurabilitys;
  BigInt currentDurability;

  BuildingGroup({
    required this.config,
  }) : count = BigInt.zero,
       listDurabilitys = [],
       currentDurability = config.durability;

  void addUnit() {
    count += BigInt.one;
    listDurabilitys.add(config.durability);
  }

  void addUnits(BigInt amount) {
    if (amount <= BigInt.zero) return;
    
    for (BigInt i = BigInt.zero; i < amount; i += BigInt.one) {
      addUnit();
    }
  }

  void degrade(BigInt degradationPerTick) {
    if (!config.infiniteDurability && count > BigInt.zero) {
      for (BigInt i = BigInt.zero; i < count; i += BigInt.one) {
        final index = i.toInt();
        if (index < listDurabilitys.length) {
          listDurabilitys[index] -= degradationPerTick;
          if (listDurabilitys[index] <= BigInt.zero) {
            listDurabilitys.removeAt(index);
          }
        }
      }
      count = BigInt.from(listDurabilitys.length);
    }
  }

  BigInt totalProduction(String resourceId) {
    BigInt prod = config.production[resourceId] ?? BigInt.zero;
    return prod * count;
  }

  BigInt get lowestDurability {
    if (listDurabilitys.isEmpty) return BigInt.zero;
    return listDurabilitys.reduce((a, b) => a < b ? a : b);
  }
}
