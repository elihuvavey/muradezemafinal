class Video {
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

  Video({
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
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      audioId: json['audio_id'],
      name: json['name'],
      image: json['image'],
      type: json['type'],
      audioDuration: json['audio_duration'],
      description: json['description'],
      isPremium: json['is_premium'],
      played: json['played'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      podcastId: json['podcast_id']?.toString(),
      seasonId: json['season_id']?.toString(),
    );
  }
}
