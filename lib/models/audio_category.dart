class AudioModel {
  final int? id;
  final String? name;
  final String? genre;
  final String? dob;
  final String? country;
  final String? bio;
  final String? website;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  AudioModel({
    this.id,
    this.name,
    this.genre,
    this.dob,
    this.country,
    this.bio,
    this.website,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      id: json['id'],
      name: json['name'],
      genre: json['genre'],
      dob: json['dob'],
      country: json['country'],
      bio: json['bio'],
      website: json['website'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
