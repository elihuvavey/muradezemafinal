import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muradezema/commons/custom_images.dart';
import 'package:muradezema/provider/favorite_provider.dart';
import 'package:provider/provider.dart';

import '../provider/dark_mode.dart';
import '../screens/payment_screen.dart';
import '../utils/nav_constants.dart';
import 'custom_text.dart';

class AudioBookCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String episodes;
  final String songCount;
  int? id;
  int? price;
  bool isPurchased;

  AudioBookCard({
    required this.imagePath,
    required this.title,
    required this.episodes,
    required this.songCount,
    required this.isPurchased,
    this.id,
    this.price,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    Color backgroundColor = isDarkMode ? Color(0xFF1C1C1E) : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    return Container(
      width: 150.w,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomNetworkImageView(
              imageUrl: imagePath,
              fallbackImageUrl:
                  'https://yt3.googleusercontent.com/c1__fQjiBX3tYvE5cfrp2SeK3EnybEvA-qjesXv3Rv-RrwMp7jm4yKxEamHNIELN3WDjlLut=s900-c-k-c0x00ffffff-no-rj',
              width: 150.w,
              height: double.infinity,
            ),
          ),
          // Dark overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xff565B5C),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4.0, right: 4),
                              child: Icon(
                                Icons.music_note_outlined,
                                size: 16.r,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              width: 4.w,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 4.0, right: 4),
                                child: CustomText(
                                  songCount,
                                  fontSize: 14.sp,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Provider.of<FavoriteProvider>(context, listen: false)
                              .toggleFavorite(
                            isPurchased: isPurchased,
                            'audio',
                            id.toString(),
                            title: title,
                            description: episodes,
                            image: imagePath,
                          );
                        },
                        child: Icon(
                          Provider.of<FavoriteProvider>(context)
                                  .isFavorite('audio', id.toString())
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.white,
                          size: 18.r,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                SizedBox(height: 5.h),
                // Play all button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xff565B5C),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 4.w,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: InkWell(
                              onTap: isPurchased
                                  ? () {
                                      Navigator.pushNamed(
                                        context,
                                        NavigationConstants.allAudios,
                                        arguments: {
                                          'id': id ?? '',
                                          'artistName': title,
                                          'artistImage': imagePath
                                        },
                                      );
                                    }
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PaymentPage(
                                                isCategory: true,
                                                phone: 'phone',
                                                price: price ?? 0,
                                                productId: id ?? 0,
                                                type: 'audio')),
                                      );
                                    },
                              child: CustomText(
                                isPurchased ? "Play Now" : 'Pay Now',
                                fontSize: 14.sp,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, right: 10),
                          child: Icon(
                            Icons.fast_forward_outlined,
                            size: 16.r,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Color(0xff444444),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.r),
                          bottomRight: Radius.circular(8.r))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomText(
                      title,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
