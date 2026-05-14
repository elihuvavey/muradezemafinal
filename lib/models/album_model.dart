class AlbumModel {
  final int? id;
  final String? artistId;
  final String? title;
  final String? image;
  final double? priceInLocal;
  final double? priceInForeign;
  final String? year;
  final String? createdAt;
  final String? updatedAt;
  final String? songsCount;
  final bool? isPurchased;

  AlbumModel({
    this.id,
    this.artistId,
    this.title,
    this.image,
    this.priceInLocal,
    this.priceInForeign,
    this.year,
    this.songsCount,
    this.createdAt,
    this.updatedAt,
    this.isPurchased,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    String? parseString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      return value.toString();
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return AlbumModel(
      id: parseInt(json['id']),
      artistId: parseString(json['artist_id']),
      title: parseString(json['title']),
      image: parseString(json['image']),
      priceInLocal: parseDouble(json['price_in_local']),
      priceInForeign: parseDouble(json['price_in_foreign']),
      year: parseString(json['year']),
      songsCount: parseString(json['songs_count']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
      isPurchased: json['is_purchased'] is bool
          ? json['is_purchased']
          : (json['is_purchased'] is String
              ? json['is_purchased'].toLowerCase() == 'true'
              : null),
    );
  }
}
