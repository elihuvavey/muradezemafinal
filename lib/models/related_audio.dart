class RelatedAudio {
  final int id;
  final String name;
  final String image;
  final String audioDuration;
  final String description;

  RelatedAudio({
    required this.id,
    required this.name,
    required this.image,
    required this.audioDuration,
    required this.description,
  });

  factory RelatedAudio.fromJson(Map<String, dynamic> json) {
    return RelatedAudio(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      audioDuration: json['audio_duration'],
      description: json['description'],
    );
  }
}
