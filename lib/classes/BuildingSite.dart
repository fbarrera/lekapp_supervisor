class BuildingSite {
  final String id;
  final String name;

  BuildingSite({required this.id, required this.name});

  factory BuildingSite.fromJson(Map<String, dynamic> jsonData) {
    return BuildingSite(id: jsonData['id'], name: jsonData['name']);
  }

  Map<String, dynamic> toJson() => {'name': name, 'id': id};
}
