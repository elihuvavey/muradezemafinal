import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muradezema/commons/custom_images.dart';
import 'package:provider/provider.dart';

import '../provider/dark_mode.dart';
import '../provider/favorite_provider.dart';

class AudioTitle extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final String price;
  final String? type;
  final int? id;
  final bool? isPurchased;
  final VoidCallback? onTap;

  const AudioTitle({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.price,
    this.type,
    this.isPurchased,
    this.id,
    this.onTap,
  });

  @override
  State<AudioTitle> createState() => _AudioTitleState();
}

class _AudioTitleState extends State<AudioTitle> {
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    final Color backgroundColor =
        isDarkMode ? const Color(0xFF23232A) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color subTextColor =
        isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
                  colors: [const Color(0xFF23232A), const Color(0xFF2C2C2E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.white, Colors.grey[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.25)
                  : Colors.grey.withOpacity(0.13),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with overlays
              Stack(
                children: [
                  // Audio cover image with glass overlay
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(22)),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          CustomNetworkImageView(
                            imageUrl: widget.imagePath,
                            fallbackImageUrl: 'https://via.placeholder.com/300',
                            fit: BoxFit.cover,
                           
                          ),
                          Positioned.fill(
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                              child: Container(
                                color: Colors.black.withOpacity(0.04),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        if (widget.id != null) {
                          Provider.of<FavoriteProvider>(context, listen: false)
                              .toggleFavorite(
                            isPurchased: false,
                            'audio',
                            widget.id.toString(),
                            title: widget.title,
                            description: widget.description,
                            image: widget.imagePath,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: backgroundColor.withOpacity(0.85),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            Provider.of<FavoriteProvider>(context).isFavorite(
                                    'audio', widget.id?.toString() ?? '')
                                ? Icons.favorite
                                : Icons.favorite_border,
                            key: ValueKey(Provider.of<FavoriteProvider>(context)
                                .isFavorite(
                                    'audio', widget.id?.toString() ?? '')),
                            color: Provider.of<FavoriteProvider>(context)
                                    .isFavorite(
                                        'audio', widget.id?.toString() ?? '')
                                ? Colors.redAccent
                                : Colors.grey,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Audio badge
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurpleAccent.withOpacity(0.12),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.audiotrack_rounded,
                              size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            "Audio",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.2,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      widget.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: subTextColor,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Price
                  widget.price == "0 Birr" || widget.isPurchased == true ? const SizedBox.shrink() :   Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange, Colors.deepOrangeAccent],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                           widget.price,
                            style:  TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            color: Colors.deepPurpleAccent, size: 22),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookTile extends StatefulWidget {
  final String imagePath;
  final String title;
  final String price;
  final String description;
  final String? type;
  final bool isPurchased;
  final int? id;
  final VoidCallback? onTap;

  const BookTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.price,
    required this.description,
    required this.isPurchased,
    this.type,
    this.id,
    this.onTap,
  });

  @override
  State<BookTile> createState() => _BookTileState();
}

class _BookTileState extends State<BookTile> {
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    final Color backgroundColor =
        isDarkMode ? const Color(0xFF23232A) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color subTextColor =
        isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
                  colors: [const Color(0xFF23232A), const Color(0xFF2C2C2E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.white, Colors.grey[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.25)
                  : Colors.grey.withOpacity(0.13),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with overlays
              Stack(
                children: [
                  // Book cover image with glass overlay
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(22)),
                    child: AspectRatio(
                      aspectRatio: 3 / 3,
                      child: Stack(
                        children: [
                          CustomNetworkImageView(
                            imageUrl: widget.imagePath,
                            fallbackImageUrl:
                                'https://via.placeholder.com/300x450',
                            fit: BoxFit.cover,
                          ),
                          Positioned.fill(
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                              child: Container(
                                color: Colors.black.withOpacity(0.04),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        if (widget.id != null) {
                          Provider.of<FavoriteProvider>(context, listen: false)
                              .toggleFavorite(
                            isPurchased: widget.isPurchased,
                            'book',
                            widget.id.toString(),
                            title: widget.title,
                            description: widget.description,
                            image: widget.imagePath,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: backgroundColor.withOpacity(0.85),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            Provider.of<FavoriteProvider>(context).isFavorite(
                                    'book', widget.id?.toString() ?? '')
                                ? Icons.favorite
                                : Icons.favorite_border,
                            key: ValueKey(Provider.of<FavoriteProvider>(context)
                                .isFavorite(
                                    'book', widget.id?.toString() ?? '')),
                            color: Provider.of<FavoriteProvider>(context)
                                    .isFavorite(
                                        'book', widget.id?.toString() ?? '')
                                ? Colors.redAccent
                                : Colors.grey,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Book badge
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.12),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.book, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            "Book",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.2,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      widget.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: subTextColor,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Price
                 widget.price == "0 Birr" || widget.isPurchased == true ? SizedBox.shrink() :    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange, Colors.deepOrangeAccent],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.price,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            color: Colors.blueAccent, size: 22),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoTile extends StatefulWidget {
  final String thumbnailUrl;
  final String title;
  final String duration;
  final String description;
  final String? type;
  final int videoCount;
  final String price;
  final int? id;
  final bool? isPurchased;
  final VoidCallback? onTap;

  const VideoTile({
    required this.thumbnailUrl,
    required this.title,
    required this.duration,
    required this.description,
    required this.videoCount,
    required this.price,
    this.type,
    this.isPurchased,
    this.id,
    this.onTap,
    super.key,
  });

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    final Color backgroundColor =
        isDarkMode ? const Color(0xFF23232A) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color subTextColor =
        isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
                  colors: [const Color(0xFF23232A), const Color(0xFF2C2C2E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.white, Colors.grey[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.25)
                  : Colors.grey.withOpacity(0.13),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail with overlays
              Stack(
                children: [
                  // Video thumbnail with glass overlay
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(22)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        children: [
                          CustomNetworkImageView(
                            imageUrl: widget.thumbnailUrl,
                            fallbackImageUrl:
                                'https://via.placeholder.com/300x169',
                            fit: BoxFit.cover,
                          ),
                          Positioned.fill(
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                              child: Container(
                                color: Colors.black.withOpacity(0.04),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        if (widget.id != null) {
                          Provider.of<FavoriteProvider>(context, listen: false)
                              .toggleFavorite(
                            isPurchased: false,
                            'video',
                            widget.id.toString(),
                            title: widget.title,
                            description: widget.description,
                            image: widget.thumbnailUrl,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: backgroundColor.withOpacity(0.85),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            Provider.of<FavoriteProvider>(context).isFavorite(
                                    'video', widget.id?.toString() ?? '')
                                ? Icons.favorite
                                : Icons.favorite_border,
                            key: ValueKey(Provider.of<FavoriteProvider>(context)
                                .isFavorite(
                                    'video', widget.id?.toString() ?? '')),
                            color: Provider.of<FavoriteProvider>(context)
                                    .isFavorite(
                                        'video', widget.id?.toString() ?? '')
                                ? Colors.redAccent
                                : Colors.grey,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Video badge
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.12),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.play_circle_outline,
                              size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            "Video",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Duration overlay
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer,
                              size: 13, color: Colors.white70),
                          const SizedBox(width: 3),
                          Text(
                            widget.duration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.2,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      widget.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: subTextColor,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Video count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange, Colors.deepOrangeAccent],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${widget.videoCount} videos',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            color: Colors.redAccent, size: 22),
                      ],
                    ),

                    SizedBox(height: 20.h,),

                    widget.price == "0 Birr" || widget.price == '0' || widget.isPurchased == true
                        ? const SizedBox.shrink()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey,
                                      Colors.blueGrey
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.price,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                             
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
