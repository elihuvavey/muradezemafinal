import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muradezema/commons/custom_images.dart';
import 'package:muradezema/utils/nav_constants.dart';
import 'package:provider/provider.dart';
import '../provider/dark_mode.dart';

class AlbumListScreen extends StatelessWidget {
  final String artistName;
  final String artistImage;
  final List<Map<String, String>> albums;
  final String type;

  const AlbumListScreen(
      {super.key,
      required this.artistName,
      required this.artistImage,
      required this.albums,
      required this.type});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    Color bgColor =
        isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xfff0eded);
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artist Banner
            Stack(
              children: [
                Hero(
                  tag: artistImage,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.r),
                      bottomRight: Radius.circular(30.r),
                    ),
                    child: CustomNetworkImageView(
                      imageUrl: artistImage,
                      fallbackImageUrl:
                          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80',
                      width: double.infinity,
                      height: 250.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 250.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.r),
                      bottomRight: Radius.circular(30.r),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20.h,
                  left: 20.w,
                  child: Text(
                    artistName,
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black45,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                '${type.toUpperCase()} Albums',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Album List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  final album = albums[index];
                  return GestureDetector(
                    onTap: () {
                      print("album $album");
                      print(
                          'datas ${album["title"]} ${album['id']} $artistImage');
                     
                    
                        if (type == 'audio') {
                          Navigator.pushNamed(
                              context, NavigationConstants.allAudios,
                               arguments: {
                              'id': int.parse(album['id'] ?? '0'),
                              'artistName': album["title"],
                              'artistImage': artistImage
                            },
                          );
                        } else if (type == 'video') {
                          Navigator.pushNamed(
                              context, NavigationConstants.allVideos,
                               arguments: {
                          'id': int.parse(album['id'] ?? '0'),
                          'artistName': album["title"],
                          'artistImage': artistImage
                        },);
                        } else if (type == 'book') {
                          Navigator.pushNamed(
                              context, NavigationConstants.bookList,
                              arguments: {
                                'id': int.parse(album["id"]??'0'),
                                'bookTitle': album['title'],
                                'bookImage': artistImage
                              });
                        }
                      
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          )
                        ],
                        border: Border.all(
                          color: isDarkMode ? Colors.white24 : Colors.black12,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Album cover
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.r),
                              bottomLeft: Radius.circular(20.r),
                            ),
                            child: CustomNetworkImageView(
                              fallbackImageUrl:
                                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80',
                              imageUrl: album['cover'] ?? '',
                              width: 100.w,
                              height: 100.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          // Album details
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    album['title'] ?? '',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    'Released: ${album['year'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: isDarkMode
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${album['songs_count'] ?? 0} ${type}s',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: isDarkMode
                                          ? Colors.white38
                                          : Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 16.w),
                            child: Icon(
                             type == "book" ? Icons.menu_book_rounded : Icons.play_circle_fill,
                              size: 36.sp,
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
