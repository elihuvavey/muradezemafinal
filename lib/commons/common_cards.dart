import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muradezema/commons/custom_images.dart';
import 'package:provider/provider.dart';
import '../provider/dark_mode.dart';
import '../provider/favorite_provider.dart';

class BookTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String price;
  final String description;
  final bool isPurchased;
  final String? type;
  final int? id;

  BookTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.price,
    required this.description,
    required this.isPurchased,
    this.type,
    this.id,
  });

  @override
  Widget build(BuildContext context) {
    return _ModernCard(
      isPurchased: isPurchased,
      imagePath: imagePath,
      title: title,
      subtitle: description,
      tag: price,
      icon: Icons.menu_book_rounded,
      type: type,
      id: id,
      itemType: 'book',
    );
  }
}

class VideoTile extends StatelessWidget {
  final String thumbnailUrl;
  final String title;
  final String duration;
  final String description;
  final bool isPurchased;
  final String? type;
  final int? id;

  const VideoTile({
    super.key,
    required this.thumbnailUrl,
    required this.title,
    required this.duration,
    required this.description,
    this.type,
    this.id,
    required this.isPurchased,
  });

  @override
  Widget build(BuildContext context) {
    return _ModernCard(
      isPurchased: isPurchased,
      imagePath: thumbnailUrl,
      title: title,
      subtitle: description,
      tag: duration,
      icon: Icons.play_circle_fill_rounded,
      type: type,
      id: id,
      itemType: 'video',
    );
  }
}

class _ModernCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String tag;
  final IconData icon;
  final String? type;
  final int? id;
  final String itemType;
  final bool isPurchased;

  _ModernCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.icon,
    this.type,
    this.id,
    required this.itemType,
    required this.isPurchased,
  });

  @override
  State<_ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<_ModernCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkModeProvider>(context).isDarkMode;
    final cardColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 1. Image with fixed aspect
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CustomNetworkImageView(
                imageUrl: widget.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                fallbackImageUrl:
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1974&auto=format&fit=crop',
              ),
            ),

            // 2. Favorite icon
            if (widget.id != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    favoriteProvider.toggleFavorite(
                      isPurchased: widget.isPurchased,
                      widget.itemType,
                      widget.id.toString(),
                      title: widget.title,
                      description: widget.subtitle,
                      image: widget.imagePath,
                    );
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      favoriteProvider.isFavorite(
                              widget.itemType, widget.id.toString())
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: favoriteProvider.isFavorite(
                              widget.itemType, widget.id.toString())
                          ? Colors.orange
                          : Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),

            // 3. Tag badge
            Positioned(
              bottom: 8,
              left: 8,
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(widget.icon, size: 14, color: Colors.white),
                        SizedBox(width: 4.w),
                        SizedBox(
                          width: 33.w,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.tag,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (widget.type != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SizedBox(
                        width: 40.w,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.type!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
