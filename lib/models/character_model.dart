class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String image;
  final String originName;
  final String locationName;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.image,
    required this.originName,
    required this.locationName,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      status: json['status'] as String? ?? 'Unknown',
      species: json['species'] as String? ?? 'Unknown',
      type: json['type'] as String? ?? '',
      gender: json['gender'] as String? ?? 'Unknown',
      image: json['image'] as String? ?? '',
      originName: (json['origin'] != null && json['origin']['name'] != null)
          ? json['origin']['name'] as String
          : 'Unknown',
      locationName: (json['location'] != null && json['location']['name'] != null)
          ? json['location']['name'] as String
          : 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'type': type,
      'gender': gender,
      'image': image,
      'origin': {'name': originName},
      'location': {'name': locationName},
    };
  }
}
