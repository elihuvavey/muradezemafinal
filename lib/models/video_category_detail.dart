class VideoCategoryDetail {
  final int id;
  final String title;
  final String description;
  final String image;
  final String type;
  final String schedule;
  final String day;
  final String startTime;
  final String endTime;
  final String author;
  final String views;
  final String createdAt;
  final String updatedAt;
  final String? userId;
  final int isPremium;
  final List<Season> seasons;
  final List<Episode> episodes;

  VideoCategoryDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.type,
    required this.schedule,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.author,
    required this.views,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    required this.isPremium,
    required this.seasons,
    required this.episodes,
  });

  factory VideoCategoryDetail.fromJson(Map<String, dynamic> json) {
    var seasonsJson = json['season'] as List? ?? [];
    var episodesJson = json['episode'] as List? ?? [];

    return VideoCategoryDetail(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      type: json['type'] ?? '',
      schedule: json['schedule'] ?? '',
      day: json['day'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      author: json['author']?.toString() ?? '',
      views: json['views']?.toString() ?? '0',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      userId: json['user_id']?.toString(),
      isPremium: int.tryParse(json['is_premium']?.toString() ?? '0') ?? 0,
      seasons: seasonsJson.map((s) => Season.fromJson(s)).toList(),
      episodes: episodesJson.map((e) => Episode.fromJson(e)).toList(),
    );
  }
}

class Season {
  final int id;
  final String title;
  final String image;
  final String priceInLocal;
  final String priceInForeign;
  final String podcastId;
  final String createdAt;
  final String updatedAt;
  final int episodeCount;
  final bool isPurchased;

  Season({
    required this.id,
    required this.title,
    required this.image,
    required this.priceInLocal,
    required this.priceInForeign,
    required this.podcastId,
    required this.createdAt,
    required this.updatedAt,
    required this.episodeCount,
    required this.isPurchased
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      priceInLocal: json['price_in_local']?.toString() ?? '',
      priceInForeign: json['price_in_foreign']?.toString() ?? '',
      podcastId: json['podcast_id']?.toString() ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      episodeCount: int.tryParse(json['episode_count']?.toString() ?? '0') ?? 0,
      isPurchased: json['is_purchased']
    );
  }
}

class Episode {
  final int id;

  Episode({required this.id});

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
    );
  }
}
