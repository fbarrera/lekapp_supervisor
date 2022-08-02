class ActivityRegistry {
  final String id;
  final String hh;
  final String fk_building_site;
  final String fk_activity;
  final String fk_speciality;
  final String fk_speciality_role;
  final String base64_image;
  final String workers;
  final String activity_date;
  final String activity_date_f;
  final String p_avance;
  final String comment;
  final String machinery;
  final String activity_code;

  ActivityRegistry(
      {
        required this.id,
        required this.hh,
        required this.fk_building_site,
        required this.fk_activity,
        required this.fk_speciality,
        required this.fk_speciality_role,
        required this.base64_image,
        required this.workers,
        required this.activity_date,
        required this.activity_date_f,
        required this.p_avance,
        required this.comment,
        required this.machinery,
        required this.activity_code});

  factory ActivityRegistry.fromJson(Map<String, dynamic> jsonData) {
    return ActivityRegistry(
        id: jsonData['id'],
        hh: jsonData['hh'],
        fk_building_site: jsonData['fk_building_site'],
        fk_activity: jsonData['fk_activity'],
        fk_speciality: jsonData['fk_speciality'],
        fk_speciality_role: jsonData['fk_speciality_role'],
        base64_image: jsonData['base64_image'],
        workers: jsonData['workers'],
        activity_date: jsonData['activity_date'],
        activity_date_f: jsonData['activity_date_f'],
        p_avance: jsonData['p_avance'],
        comment: jsonData['comment'],
        machinery: jsonData['machinery'],
        activity_code: jsonData['activity_code']);
  }

  Map<String, dynamic> toJson() => {
        'hh': hh,
        'id': id,
        'fk_building_site': fk_building_site,
        'fk_activity': fk_activity,
        'fk_speciality': fk_speciality,
        'fk_speciality_role': fk_speciality_role,
        'base64_image': base64_image,
        'workers': workers,
        'activity_date': activity_date,
        'activity_date_f': activity_date_f,
        'p_avance': p_avance,
        'comment': comment,
        'machinery': machinery,
        'activity_code': activity_code,
      };
}
