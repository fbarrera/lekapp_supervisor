import 'package:lekapp_supervisor/classes/Zone.dart';
import 'ActivityRegistry.dart';

class ActivityRegistries {
  final List<ActivityRegistry> activityRegistries;

  ActivityRegistries({required this.activityRegistries});

  factory ActivityRegistries.fromJson(Map<String, dynamic> jsonData) {
    List ar = jsonData['activity_registries'];
    return ActivityRegistries(
      activityRegistries:
          ar.map((item) => ActivityRegistry.fromJson(item)).toList(),
    );
  }

  List<ActivityRegistry> toList() {
    return this.activityRegistries;
  }

  Map<String, dynamic> toJson() => {
        'activity_registries': activityRegistries,
      };

  Map<String, dynamic> toInternalDatabase(String ownerEmail) => {
        ownerEmail: activityRegistries,
      };
}
