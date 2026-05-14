class Episode {
  final int id;
  final String name;
  final String image;
  final String type;
  final String duration;
  final String description;

  Episode({
    required this.id,
    required this.name,
    required this.image,
    required this.type,
    required this.duration,
    required this.description,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      type: json['type'],
      duration: json['audio_duration'],
      description: json['description'],
    );
  }
}
