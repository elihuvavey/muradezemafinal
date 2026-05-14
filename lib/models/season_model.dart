class Season {
  final int? id;
  final String? title;
  final String? podcastId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Season({
    this.id,
    this.title,
    this.podcastId,
    this.createdAt,
    this.updatedAt,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      title: json['title'] as String?,
      podcastId: json['podcast_id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  static List<Season> fromJsonList(List<dynamic> list) {
    return list.map((item) => Season.fromJson(item)).toList();
  }
}
