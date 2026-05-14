class RelatedAudio {
  final int? id;
  final String? audioId;
  final String? name;
  final String? image;
  final String? type;
  final String? audioDuration;
  final String? description;
  final String? isPremium;
  final String? played;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final String? podcastId;
  final String? seasonId;
  final String? priceInLocal;
  final String? priceInForeign;
  final bool? isPurchased;

  RelatedAudio({
    this.id,
    this.audioId,
    this.name,
    this.image,
    this.type,
    this.audioDuration,
    this.description,
    this.isPremium,
    this.played,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.podcastId,
    this.seasonId,
    this.priceInLocal,
    this.priceInForeign,
    this.isPurchased,
  });

  factory RelatedAudio.fromJson(Map<String, dynamic> json) {
    return RelatedAudio(
      id: json['id'] as int?,
      audioId: json['audio_id']?.toString(),
      name: json['name']?.toString(),
      image: json['image']?.toString(),
      type: json['type']?.toString(),
      audioDuration: json['audio_duration']?.toString(),
      description: json['description']?.toString(),
      isPremium: json['is_premium']?.toString(),
      played: json['played']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      podcastId: json['podcast_id']?.toString(),
      seasonId: json['season_id']?.toString(),
      priceInLocal: json['price_in_local']?.toString(),
      priceInForeign: json['price_in_foreign']?.toString(),
      isPurchased: json['is_purchased'] as bool?,
    );
  }
}
