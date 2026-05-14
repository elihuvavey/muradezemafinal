class BookSeason {
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
  final String? audio;
  final List<Season>? season;

  BookSeason({
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
    this.audio,
    this.season,
  });

  factory BookSeason.fromJson(Map<String, dynamic> json) {
    return BookSeason(
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
      audio: json['audio'] as String?,
      season: json['season'] != null && json['season'] is List
          ? (json['season'] as List)
              .map((e) => Season.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class Season {
  final int? id;
  final String? title;
  final String? audiobookId;
  final String? createdAt;
  final String? updatedAt;
  final int? episodeCount;
  final String? image;
  final bool? isPurchased;
  final double? priceInLocal;
  final double? priceInForeign;

  Season({
    this.id,
    this.title,
    this.audiobookId,
    this.createdAt,
    this.updatedAt,
    this.episodeCount,
    this.image,
    this.isPurchased,
    this.priceInForeign,
    this.priceInLocal
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] as int?,
      title: json['title'] as String?,
      audiobookId: json['audiobook_id'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      episodeCount: json['episode_count'],
      isPurchased: json['is_purchased'],
      image: json['image'],
      priceInForeign: json['price_in_foreign'] == null
          ? null
          : (json['price_in_foreign'] is num
              ? (json['price_in_foreign'] as num).toDouble()
              : double.tryParse(json['price_in_foreign'].toString())),
      priceInLocal: json['price_in_local'] == null
          ? null
          : (json['price_in_local'] is num
              ? (json['price_in_local'] as num).toDouble()
              : double.tryParse(json['price_in_local'].toString())),
    );
  }
}
