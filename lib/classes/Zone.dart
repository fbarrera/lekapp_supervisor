class Zone {
  final String id;
  final String name;
  final String fk_building_site;
  final String fk_area;

  Zone({
    required this.id,
    required this.name,
    required this.fk_building_site,
    required this.fk_area,
  });

  factory Zone.fromJson(Map<String, dynamic> jsonData) {
    return Zone(
      id: jsonData['id'],
      name: jsonData['name'],
      fk_building_site: jsonData['fk_building_site'],
      fk_area: jsonData['fk_area'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'fk_building_site': fk_building_site,
        'fk_area': fk_area,
      };
}
