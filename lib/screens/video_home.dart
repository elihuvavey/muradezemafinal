import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:muradezema/commons/custom_top_selling.dart';
import 'package:muradezema/provider/top_selling_provider.dart';
import 'package:muradezema/utils/endpoint.dart';
import 'package:provider/provider.dart';
import '../provider/profile_provider.dart';

import 'package:muradezema/commons/video_card.dart';
import 'package:muradezema/commons/category_chip.dart';
import 'package:muradezema/commons/custom_appbar.dart';
import 'package:muradezema/commons/custom_bottom_nav.dart';
import 'package:muradezema/commons/custom_input.dart';
import 'package:muradezema/commons/custom_text.dart';
import 'package:muradezema/provider/dark_mode.dart';
import 'package:muradezema/provider/video_category.dart';
import 'package:muradezema/provider/video_category_detail.dart';
import 'package:muradezema/utils/nav_constants.dart';
import '../utils/api_services.dart';
import '../utils/user_prefs.dart';
import 'payment_screen.dart';

class VideoHomeScreen extends StatefulWidget {
  const VideoHomeScreen({super.key});

  @override
  State<VideoHomeScreen> createState() => _VideoHomeScreenState();
}

class _VideoHomeScreenState extends State<VideoHomeScreen> {
  int _currentIndex = 2;
  int selectedCategoryIndex = 0;
  int selectedCatId = 1; // default category id

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VideoCategoryProvider>(context, listen: false)
          .fetchPodcasts();
      Provider.of<VideoCategoryDetailProvider>(context, listen: false)
          .fetchCategoryDetail(selectedCatId);
      Provider.of<TopSellingProvider>(context, listen: false)
          .loadTopSellingAudio('video');
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    Color backgroundColor =
        isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xfff0eded);
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    Color tabColor = isDarkMode ? Colors.white24 : Colors.black26;

    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor:
                isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            title: Row(
              children: [
                Icon(Icons.exit_to_app_rounded, color: Colors.redAccent),
                const SizedBox(width: 12),
                Text(
                  "Exit App?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            content: Text(
              "Are you sure you want to exit the app?",
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  "No, Stay",
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.check, size: 18),
                label: const Text("Yes, Exit"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );

        if (shouldExit) {
          // Use one of the two below based on your platform
          if (Platform.isAndroid) {
            SystemNavigator.pop(); // for Android
          } else {
            exit(0); // for iOS or general fallback
          }
        }

        return false; // prevent default back navigation
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: MyCustomAppBar(
          title: '',
          onBack: () => Navigator.of(context).pop(),
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(
                  context, NavigationConstants.notifications),
              icon: const Icon(Icons.notifications, color: Color(0xffB4A0B1)),
            ),
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: () =>
                  Provider.of<DarkModeProvider>(context, listen: false)
                      .toggleDarkMode(),
            ),
            Consumer<ProfileProvider>(
              builder: (context, value, child) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, NavigationConstants.profile);
                                    },
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.orange,
                                      backgroundImage: NetworkImage(
                                        value.profile?.image ?? '',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    value.profile?.fullName ?? '',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    value.profile?.email ?? '',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );

                                      final api = ApiClient();
                                      final response = await api.post(
                                        '${ApiConstants.baseUrl}/logout',
                                        headers: {
                                          'Authorization':
                                              'Bearer ${HivePrefs.getString('token')}',
                                          'Accept': 'application/json'
                                        },
                                      );
                                      debugPrint('response $response');

                                      if (response['status'] == 200) {
                                        Navigator.pop(
                                            context); // Close loading dialog
                                        Navigator.pop(
                                            context); // Close profile dialog
                                        Navigator.pushNamed(context,
                                            NavigationConstants.loginPage);
                                        HivePrefs.clear();
                                      } else {
                                        Navigator.pushNamed(context,
                                            NavigationConstants.loginPage);
                                        HivePrefs.clear();
                                      }
                                    },
                                    icon: const Icon(Icons.logout),
                                    label: const Text('Logout'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.orange,
                      radius: 22,
                      child: ClipOval(
                        child: Image.network(
                          value.profile?.image ?? '',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  CustomText('Find Your',
                      color: const Color(0xff96979B),
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                  CustomText('VIDEO BOOKS',
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  const SizedBox(height: 10),
                  CustomInputField(
                    hintText: 'Search for audio book, video',
                    icon: Icons.search,
                    isSearch: true,
                    index: 2,
                  ),
                  const SizedBox(height: 20),
                  Consumer<VideoCategoryProvider>(
                    builder: (context, categoryProvider, child) => SizedBox(
                      height: 40.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoryProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = categoryProvider.categories[index];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedCategoryIndex = index;
                                selectedCatId = category.id ?? 1;
                              });
                              Provider.of<VideoCategoryDetailProvider>(context,
                                      listen: false)
                                  .fetchCategoryDetail(selectedCatId);
                            },
                            child: CategoryChip(
                              label: category.title ?? '',
                              color: tabColor,
                              isSelected: selectedCategoryIndex == index,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  children: [
                    Consumer<VideoCategoryDetailProvider>(
                      builder: (context, detailProvider, child) {
                        final category = detailProvider.categoryDetail;
                        if (detailProvider.isLoading) {
                          return Center(
                            child: LoadingAnimationWidget.inkDrop(
                                color: textColor, size: 30.h),
                          );
                        }
                        if (category == null ||
                            (category.seasons.isEmpty &&
                                category.episodes.isEmpty)) {
                          return Center(
                              child: Text('No seasons or episodes available.'));
                        }
                        return SizedBox(
                          height: 220,
                          child: ListView.builder(
                            itemCount: category.seasons.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final season = category.seasons[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: InkWell(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    NavigationConstants.allVideos,
                                    arguments: {
                                      'id': season.id,
                                      'artistName': season.title,
                                      'artistImage':
                                         season.image
                                    },
                                  ),
                                  child: VideoCard(
                                    price: (season.priceInLocal is num)
                                        ? (season.priceInLocal as num)
                                            .toDouble()
                                        : 0.0,
                                    isPurchased: season.isPurchased,
                                    thumbnailUrl: season.image,
                                    description: category.description,
                                    videoCount: season.episodeCount,
                                    imagePath: category.image,
                                    title: season.title,
                                    episodes: season.podcastId,
                                    id: season.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText('Top Selling Videos',
                            fontSize: 16.sp,
                            color: textColor,
                            fontWeight: FontWeight.bold),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, NavigationConstants.topSellingList,
                                arguments: {'type': 'video'});
                          },
                          child: CustomText('View all',
                              color: textColor, fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(
                      child: Consumer<TopSellingProvider>(
                        builder: (context, detailProvider, child) {
                          final category = detailProvider.sales;
                          if (category.isEmpty) {
                            return Center(
                                child: Text('No episodes available.'));
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: category.length,
                            itemBuilder: (context, index) {
                              final episode = category[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: InkWell(
                                  onTap: episode.product.isPurchased
                                      ? () {
                                          Navigator.pushNamed(context,
                                              NavigationConstants.videoPlayer,
                                              arguments: {
                                                'id': episode.product.id
                                              });
                                        }
                                      : () {
                                          bool? isLocal =
                                              HivePrefs.getBool('isLocal');

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => PaymentPage(
                                                    isCategory: false,
                                                    phone: 'phone',
                                                    price: isLocal ?? false
                                                        ? int.parse(episode
                                                            .product
                                                            .priceInLocal)
                                                        : int.parse(episode
                                                            .product
                                                            .priceInLocal),
                                                    productId:
                                                        episode.product.id,
                                                    type: 'audio')),
                                          );
                                        },
                                  child: TopSellingCard(
                                    category: 'Video',
                                    isPurchased: episode.product.isPurchased,
                                    imagePath: episode.product.image,
                                    title: episode.product.title,
                                    subtitle: episode.product.description,
                                    // duration: episode.product.duration,
                                    id: episode.product.id,
                                    price:
                                        episode.product.priceInLocal.toString(),
                                    foreignPrice: episode.product.priceInForeign
                                        .toString(),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            )
          ],
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
             if (index == 0) {
              Navigator.pushNamed(context, NavigationConstants.bookHome);
            } else if (index == 1) {
              Navigator.pushNamed(context, NavigationConstants.audioHome);
            } else if (index == 2) {
              Navigator.pushNamed(context, NavigationConstants.videoHome);
            } else {
              Navigator.pushNamed(context, NavigationConstants.purchased);
            }
          },
        ),
      ),
    );
  }
}
