class Area {
  final String id;
  final String name;
  final String fk_building_site;

  Area({
    required this.id,
    required this.name,
    required this.fk_building_site,
  });

  factory Area.fromJson(Map<String, dynamic> jsonData) {
    return Area(
      id: jsonData['id'],
      name: jsonData['name'],
      fk_building_site: jsonData['fk_building_site'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'fk_building_site': fk_building_site,
      };
}
