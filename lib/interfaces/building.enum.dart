enum BuildingType { sawmill, quarry, foundry, workshop }

BuildingType buildingTypeFromJson(String value) {
  switch (value) {
    case 'sawmill':
      return BuildingType.sawmill;
    case 'quarry':
      return BuildingType.quarry;
    case 'foundry':
      return BuildingType.foundry;
    case 'workshop':
      return BuildingType.workshop;
    default:
      throw Exception('Unknown BuildingType value: $value');
  }
}
