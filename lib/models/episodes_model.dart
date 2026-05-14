class SeasonEpisode {
  final int? id;
  final String? audioId;
  final String? name;
  final String? image;
  final String? type;
  final String? audioDuration;
  final String? description;
  final String? isPremium;
  final String? played;
  final String? priceInLocal;
  final String? priceInForeign;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final String? podcastId;
  final String? seasonId;

  SeasonEpisode({
    this.id,
    this.audioId,
    this.name,
    this.image,
    this.type,
    this.audioDuration,
    this.description,
    this.isPremium,
    this.played,
    this.priceInLocal,
    this.priceInForeign,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.podcastId,
    this.seasonId,
  });

  factory SeasonEpisode.fromJson(Map<String, dynamic> json) {
    return SeasonEpisode(
      id: json['id'],
      audioId: json['audio_id'],
      name: json['name'],
      image: json['image'],
      type: json['type'],
      audioDuration: json['audio_duration'],
      description: json['description'],
      isPremium: json['is_premium'],
      played: json['played'],
      priceInLocal: json['price_in_local'],
      priceInForeign: json['price_in_foreign'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      podcastId: json['podcast_id'],
      seasonId: json['season_id'],
    );
  }
}
