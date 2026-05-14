class VideoCategory {
  final int? id;
  final String? title;
  final String? description;
  final bool? isPremium;
  final String? image;
  final String? type;
  final String? schedule;
  final String? day;
  final String? startTime;
  final String? endTime;
  final String? author;
  final int? views;
  final String? createdAt;
  final String? updatedAt;
  final int? userId;

  VideoCategory({
    this.id,
    this.title,
    this.description,
    this.isPremium,
    this.image,
    this.type,
    this.schedule,
    this.day,
    this.startTime,
    this.endTime,
    this.author,
    this.views,
    this.createdAt,
    this.updatedAt,
    this.userId,
  });

  factory VideoCategory.fromJson(Map<String, dynamic> json) {
    return VideoCategory(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      isPremium: json['is_premium'] is bool
          ? json['is_premium']
          : (json['is_premium']?.toString().toLowerCase() == 'true' ||
              json['is_premium']?.toString() == '1'),
      image: json['image']?.toString(),
      type: json['type']?.toString(),
      schedule: json['schedule']?.toString(),
      day: json['day']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      author: json['author']?.toString(),
      views: json['views'] is int ? json['views'] : int.tryParse(json['views']?.toString() ?? ''),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? ''),
    );
  }
}
