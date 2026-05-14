class Podcast {
  final int? id;
  final String? title;
  final String? artist;
  final String? subtitle;
  final String? albumArtist;
  final String? album;
  final String? language;
  final String? description;
  final String? year;
  final String? duration;
  final String? releaseDate;
  final String? albumId;
  final String? permaUrl;
  final String? image;
  final int? views;
  final bool? isPremium;
  final String? url;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Podcast({
    this.id,
    this.title,
    this.artist,
    this.subtitle,
    this.albumArtist,
    this.album,
    this.language,
    this.description,
    this.year,
    this.duration,
    this.releaseDate,
    this.albumId,
    this.permaUrl,
    this.image,
    this.views,
    this.isPremium,
    this.url,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      title: json['title'] as String?,
      artist: json['artist'] as String?,
      subtitle: json['subtitle'] as String?,
      albumArtist: json['album_artist'] as String?,
      album: json['album'] as String?,
      language: json['language']?.toString(),
      description: json['description'] as String?,
      year: json['year']?.toString(),
      duration: json['duration'] as String?,
      releaseDate: json['release_date'] as String?,
      albumId: json['album_id']?.toString(),
      permaUrl: json['perma_url'] as String?,
      image: json['image'] as String?,
      views: json['views'] != null ? int.tryParse(json['views'].toString()) : null,
      isPremium: json['is_premium'] != null ? json['is_premium'].toString() == '1' : null,
      url: json['url'] as String?,
      category: json['category'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  static List<Podcast> fromJsonList(List<dynamic> list) {
    return list.map((item) => Podcast.fromJson(item)).toList();
  }
}
