class Book {
  final int? id;
  final String? title;
  final String? author;
  final String? views;
  final String? narrator;
  final String? description;
  final String? duration;
  final String? language;
  final String? genre;
  final String? publisher;
  final String? releaseDate;
  final String? url;
  final String? image;
  final String? isPremium;
  final String? createdAt;
  final String? updatedAt;

  Book({
    this.id,
    this.title,
    this.author,
    this.views,
    this.narrator,
    this.description,
    this.duration,
    this.language,
    this.genre,
    this.publisher,
    this.releaseDate,
    this.url,
    this.image,
    this.isPremium,
    this.createdAt,
    this.updatedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as int?,
      title: json['title'] as String?,
      author: json['author'] as String?,
      views: json['views'] as String?,
      narrator: json['narrator'] as String?,
      description: json['description'] as String?,
      duration: json['duration'] as String?,
      language: json['language'] as String?,
      genre: json['genre'] as String?,
      publisher: json['publisher'] as String?,
      releaseDate: json['release_date'] as String?,
      url: json['url'] as String?,
      image: json['image'] as String?,
      isPremium: json['is_premium'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
