import 'package:test_1/interfaces/building.interface.dart';

class BuildingGroup {
  final Building config;
  BigInt count;
  List<int> listDurabilitys;

  BuildingGroup({required this.config})
    : count = BigInt.zero,
      listDurabilitys = [];

  void addUnit() {
    count += BigInt.one;
    if (!config.infiniteDurability) {
      listDurabilitys.add(config.durability);
    }
  }

  void degrade(int degradationPerTick) {
    if (!config.infiniteDurability && count > BigInt.zero) {
      for (int i = 0; i < count.toInt(); i++) {
        listDurabilitys[i] -= degradationPerTick;
      }
      listDurabilitys.removeWhere((durability) => durability <= 0);
      count = BigInt.from(listDurabilitys.length);
    }
  }

  BigInt totalProduction(String resourceId) {
    BigInt prod = config.production[resourceId] ?? BigInt.zero;
    return prod * count;
  }

  // get the building with the lowest durability
  int get lowestDurability {
    if (config.infiniteDurability) return 0;
    if (listDurabilitys.isEmpty) return config.durability;
    return listDurabilitys.reduce(
      (value, element) => value < element ? value : element,
    );
  }
}
