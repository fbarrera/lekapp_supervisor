class Speciality {
  final String id;
  final String name;
  final String fk_building_site;

  Speciality({required this.id, required this.name, required this.fk_building_site});

  factory Speciality.fromJson(Map<String, dynamic> jsonData) {
    return Speciality(
      id: jsonData['id'],
      name: jsonData['name'],
      fk_building_site: jsonData['fk_building_site'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'fk_building_site': fk_building_site,
      };
}
