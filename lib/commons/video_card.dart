import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../provider/favorite_provider.dart';
import '../screens/payment_screen.dart';
import '../utils/nav_constants.dart';
import 'custom_text.dart';

class VideoCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String episodes;
  final int? id;
  final int videoCount;
  final String description;
  final String thumbnailUrl;
  final bool isPurchased;
  final double price;

  const VideoCard({
    required this.imagePath,
    required this.title,
    required this.episodes,
    required this.id,
    required this.videoCount,
    required this.description,
    required this.thumbnailUrl,
    required this.isPurchased,
    required this.price,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            // Background Image
            Image.network(
              imagePath,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),

            // Dark Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // Top Overlay with Icons
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Episodes Badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.playlist_play,
                            size: 16.r, color: Colors.white),
                        SizedBox(width: 4.w),
                        CustomText(videoCount.toString(),
                            fontSize: 12.sp, color: Colors.white),
                      ],
                    ),
                  ),

                  // Favorite Icon
                  GestureDetector(
                    onTap: () {
                      Provider.of<FavoriteProvider>(context, listen: false)
                          .toggleFavorite(
                        isPurchased: isPurchased,
                        'video',
                        id.toString(),
                        title: title,
                        description: description,
                        image: thumbnailUrl,
                      );
                    },
                    child: Icon(
                      Provider.of<FavoriteProvider>(context)
                              .isFavorite('video', id.toString())
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.white,
                      size: 20.r,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Title and Play Button
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Play All Button
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                      ),
                      onPressed: isPurchased ? (){
                         Navigator.pushNamed(
                                    context,
                                    NavigationConstants.allVideos,
                                    arguments: {
                                      'id': id,
                                      'artistName': title,
                                      'artistImage':
                                          "https://yt3.googleusercontent.com/c1__fQjiBX3tYvE5cfrp2SeK3EnybEvA-qjesXv3Rv-RrwMp7jm4yKxEamHNIELN3WDjlLut=s900-c-k-c0x00ffffff-no-rj"
                                    },
                                  );
                      } :  () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PaymentPage(
                                        isCategory: true,
                                        phone: 'phone',
                                        price: price.toInt(),
                                        productId: id ?? 0,
                                        type: 'video')),
                              );
                            },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8),
                        child:   Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: isPurchased
                                      ? [Color(0xFF43CEA2), Color(0xFF185A9D)]
                                      : [Color(0xFFFF9800), Color(0xFFFF5722)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(6.r),
                              child: Icon(
                                isPurchased ? Icons.play_arrow : Icons.lock,
                                size: 10.r,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: CustomText(
                                isPurchased ? "Play" : "Purchase",
                                fontSize: 12.sp,  
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        
                        ),
                      ),
                    ),
                  ),

                  // Title Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12.r),
                        bottomRight: Radius.circular(12.r),
                      ),
                    ),
                    child: CustomText(
                      title,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
