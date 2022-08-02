class SpecialityRole {
  final String id;
  final String name;
  final String hh;
  final String fk_building_site;
  final String fk_speciality;

  SpecialityRole(
      {required this.id, required this.name, required this.hh, required this.fk_building_site, required this.fk_speciality});

  factory SpecialityRole.fromJson(Map<String, dynamic> jsonData) {
    return SpecialityRole(
        id: jsonData['id'],
        name: jsonData['name'],
        hh: jsonData['hh'],
        fk_building_site: jsonData['fk_building_site'],
        fk_speciality: jsonData['fk_speciality']);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'fk_building_site': fk_building_site,
        'fk_speciality': fk_speciality,
        'hh': hh
      };
}
