import 'Zone.dart';
import 'Area.dart';
import 'Activity.dart';
import 'BuildingSite.dart';
import 'Speciality.dart';
import 'SpecialityRole.dart';

class SessionLogin {
  final String email;
  final String password;
  final String name;
  final List<Speciality> specialities;
  final List<BuildingSite> buildingSites;
  final List<Activity> activities;
  final List<Zone> zones;
  final List<Area> areas;
  final List<SpecialityRole> specialityRoles;

  SessionLogin({
    required this.email,
    required this.password,
    required this.name,
    required this.specialities,
    required this.buildingSites,
    required this.activities,
    required this.zones,
    required this.areas,
    required this.specialityRoles,
  });

  factory SessionLogin.fromJson(Map<String, dynamic> jsonData) {
    List b = jsonData['building_sites'];
    List s = jsonData['specialities'];
    List a = jsonData['activities'];
    List z = jsonData['zones'];
    List ar = jsonData['areas'];
    List sr = jsonData['speciality_roles'];
    return SessionLogin(
      email: jsonData['email'],
      name: jsonData['name'],
      specialities: s
          .map(
            (item) => Speciality.fromJson(item),
          )
          .toList(),
      buildingSites: b
          .map(
            (item) => BuildingSite.fromJson(item),
          )
          .toList(),
      activities: a
          .map(
            (item) => Activity.fromJson(item),
          )
          .toList(),
      zones: z
          .map(
            (item) => Zone.fromJson(item),
          )
          .toList(),
      areas: ar
          .map(
            (item) => Area.fromJson(item),
          )
          .toList(),
      specialityRoles: sr
          .map(
            (item) => SpecialityRole.fromJson(item),
          )
          .toList(),
      password: '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'specialities': specialities,
        'building_sites': buildingSites,
        'activities': activities,
        'zones': zones,
        'areas': areas,
        'speciality_roles': specialityRoles,
      };
}
