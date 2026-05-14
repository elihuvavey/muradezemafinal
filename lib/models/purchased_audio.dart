class PurchasedAudio {
  final String id;
  final String title;
  final String description;
  final String image;
  final String duration;

  PurchasedAudio({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'duration': duration,
    };
  }

  factory PurchasedAudio.fromJson(Map<String, dynamic> json) {
    return PurchasedAudio(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
    );
  }
}
