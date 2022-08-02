import 'package:lekapp_supervisor/classes/Zone.dart';

class Activity {
  final String id;
  final String name;
  final String f_data;
  final String unt;
  final String qty;
  final String eff;
  final String activity_code;
  final String fk_building_site;
  final String fk_speciality;
  final String fk_speciality_role;
  final String fk_zone;
  late Zone? zone;

  Activity(
      {required this.id,
      required this.name,
      required this.f_data,
      required this.unt,
      required this.qty,
      required this.eff,
      required this.activity_code,
      required this.fk_building_site,
      required this.fk_speciality,
      required this.fk_speciality_role,
      required this.fk_zone,
      this.zone});

  factory Activity.fromJson(Map<String, dynamic> jsonData) {
    return Activity(
      id: jsonData['id'],
      name: jsonData['name'],
      f_data: jsonData['f_data'],
      unt: jsonData['unt'],
      qty: jsonData['qty'],
      eff: jsonData['eff'],
      activity_code: jsonData['activity_code'],
      fk_building_site: jsonData['fk_building_site'],
      fk_speciality: jsonData['fk_speciality'],
      fk_speciality_role: jsonData['fk_speciality_role'],
      fk_zone: jsonData['fk_zone'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'f_data': f_data,
        'unt': unt,
        'qty': qty,
        'eff': eff,
        'activity_code': activity_code,
        'fk_building_site': fk_building_site,
        'fk_speciality': fk_speciality,
        'fk_speciality_role': fk_speciality_role,
        'fk_zone': fk_zone,
      };
}
