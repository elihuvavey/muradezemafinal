import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:muradezema/commons/custom_images.dart';
import 'package:muradezema/provider/purchase_provider.dart';
import 'package:muradezema/provider/search_purchased.dart' as search;
import 'package:muradezema/screens/audio/player_task.dart';
import 'package:provider/provider.dart';
import '../provider/favorite_provider.dart';
import '../provider/profile_provider.dart';

import '../commons/custom_appbar.dart';
import '../commons/custom_bottom_nav.dart';
import '../main.dart';
import '../provider/dark_mode.dart';
import '../utils/api_services.dart';
import '../utils/nav_constants.dart';
import '../utils/user_prefs.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PurchasedFilesPage extends StatefulWidget {
  const PurchasedFilesPage({super.key});

  @override
  State<PurchasedFilesPage> createState() => _PurchasedFilesPageState();
}

class _PurchasedFilesPageState extends State<PurchasedFilesPage> {
  int _selectedCategoryIndex = 0; // 0 = Audio, 1 = Video, 2 = Book
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDataBasedOnCategory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchDataBasedOnCategory() {
    final provider = Provider.of<PurchaseProvider>(context, listen: false);
    if (_selectedCategoryIndex == 0) {
      provider.fetchPurchases(type: 'audio');
    } else if (_selectedCategoryIndex == 1) {
      provider.fetchPurchases(type: 'video');
    } else if (_selectedCategoryIndex == 2) {
      provider.fetchPurchases(type: 'book');
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      _fetchDataBasedOnCategory();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final searchProvider =
        Provider.of<search.SearchPurchasesProvider>(context, listen: false);
    String type = 'audio';
    if (_selectedCategoryIndex == 1) {
      type = 'video';
    } else if (_selectedCategoryIndex == 2) {
      type = 'book';
    }

    searchProvider.fetchPurchases(query: query, type: type);
  }

  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    Color backgroundColor = isDarkMode ? Color(0xFF1C1C1E) : Color(0xfff0eded);
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    final size = MediaQuery.of(context).size;

    final purchaseProvider = Provider.of<PurchaseProvider>(context);
    final purchasedItems = purchaseProvider.items;
    final isLoading = purchaseProvider.isLoading;

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
          if (Platform.isAndroid) {
            SystemNavigator.pop(); // for Android
          } else {
            exit(0); // for iOS or general fallback
          }
        }

        return false; // prevent default back navigation
      },
      child: Scaffold(
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
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
        backgroundColor: backgroundColor,
        appBar: MyCustomAppBar(
          title: '',
          onBack: () => Navigator.of(context).pop(),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(
                    context, NavigationConstants.favoriteScreen);
              },
              icon: const Icon(Icons.favorite, color: Color(0xffB4A0B1)),
            ),
            IconButton(
              icon: Icon(Icons.brightness_6),
              onPressed: () {
                Provider.of<DarkModeProvider>(context, listen: false)
                    .toggleDarkMode();
              },
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
                                        dotenv.env['BASE_URL']! + '/logout',
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: 6.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Find Your",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff96979B),
                        fontSize: 14.sp),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Purchased files",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold, color: textColor),
                  ),
                ),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                        context, NavigationConstants.searchPurchased);
                  },
                  child: TextField(
                    controller: _searchController,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: "Search for audio book, video",
                      hintStyle: TextStyle(color: textColor),
                      prefixIcon: Icon(Icons.search, color: textColor),
                      filled: true,
                      fillColor: Colors.white12,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCategoryButton("Audio", 0),
                    _buildCategoryButton("Video", 1),
                    _buildCategoryButton("Book", 2),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isSearching
                      ? Consumer<search.SearchPurchasesProvider>(
                          builder: (context, searchProvider, child) {
                            if (searchProvider.isLoading) {
                              return Center(
                                child: LoadingAnimationWidget.staggeredDotsWave(
                                  color: Colors.orangeAccent,
                                  size: 50.h,
                                ),
                              );
                            }
                            if (searchProvider.errorMessage != null) {
                              return Center(
                                child: Text(
                                  searchProvider.errorMessage!,
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            }
                            if (searchProvider.results.isEmpty) {
                              return Center(
                                child: Text(
                                  "No results found",
                                  style: TextStyle(color: textColor),
                                ),
                              );
                            }
                            return GridView.builder(
                              itemCount: searchProvider.results.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: size.width > 600 ? 3 : 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.7,
                              ),
                              itemBuilder: (context, index) {
                                final item = searchProvider.results[index];
                                if (_selectedCategoryIndex == 0) {
                                  return _buildItemCard(item as PurchaseItem);
                                } else if (_selectedCategoryIndex == 1) {
                                  return _buildItemVideoCard(
                                      item as PurchaseItem);
                                } else {
                                  return _buildItemBookCard(
                                      item as PurchaseItem);
                                }
                              },
                            );
                          },
                        )
                      : isLoading
                          ? Center(
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: Colors.orangeAccent,
                                size: 50.h,
                              ),
                            )
                          : purchasedItems.isEmpty
                              ? Center(
                                  child: Text("No items found.",
                                      style: TextStyle(color: textColor)))
                              : GridView.builder(
                                  itemCount: purchasedItems.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: size.width > 600 ? 3 : 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.7,
                                  ),
                                  itemBuilder: (context, index) {
                                    final item = purchasedItems[index];
                                    if (_selectedCategoryIndex == 0) {
                                      return _buildItemCard(item);
                                    } else if (_selectedCategoryIndex == 1) {
                                      return _buildItemVideoCard(item);
                                    } else {
                                      return _buildItemBookCard(item);
                                    }
                                  },
                                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Update this method to trigger data fetch on tab switch
  Widget _buildCategoryButton(String label, int index) {
    final bool isSelected = _selectedCategoryIndex == index;
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategoryIndex = index;
          });
          _fetchDataBasedOnCategory(); // 👈 Fetch new data when button is tapped
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white70 : Colors.white12,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? textColor : textColor.withOpacity(0.3),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? textColor : textColor.withOpacity(0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(PurchaseItem item) {
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    Color backgroundColor =
        isDarkMode ? const Color.fromARGB(179, 202, 201, 201) : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    return InkWell(
      onTap: item.isCategory == true
          ? () {
              Navigator.pushNamed(context, NavigationConstants.allAudios,
                  arguments: {
                    'id': item.id,
                    'artistName': item.title,
                    'artistImage': item.image
                  });
            }
          : () async {
              final Dio dio = Dio();
              try {
                final response = await dio.post(
                  '${dotenv.env['BASE_URL']!}/audio/episodes/${item.id}/play',
                  options: Options(
                    headers: {
                      'Authorization': 'Bearer ${HivePrefs.getString('token')}',
                    },
                  ),
                );
                if (response.statusCode == 200) {
                  final audioUrl = response.data['audio'];
                  if (audioUrl.isNotEmpty) {
                    final parts = item.duration?.split(":") ?? ['0', '0'];
                    final minutes = int.tryParse(parts[0]) ?? 0;
                    final seconds = int.tryParse(parts[1]) ?? 0;
                    final duration =
                        Duration(minutes: minutes, seconds: seconds);
                    await (audioHandler as AudioPlayerHandler).loadMediaItem(
                      id: audioUrl,
                      title: item.title ?? '',
                      album: item.description ?? '',
                      artist: item.description ?? '',
                      artUri: Uri.parse(item.image ?? ''),
                      duration: duration,
                      // extras: {'episodeId': episode.id.toString()},
                    );
                    audioHandler.play();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MainScreen(
                          id: audioUrl,
                          title: item.title ?? '',
                          album: item.description ?? '',
                          artist: item.description ?? '',
                          artUri: Uri.parse(item.image ?? ''),
                          duration: duration,
                        ),
                      ),
                    );
                  }
                }
              } catch (e) {
                debugPrint('Error fetching audio: $e');
              }
            },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top image / waveform
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white30,
                    backgroundImage: NetworkImage(item.image ?? ''),
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                    "assets/images/wave.png",
                    height: 60.h,
                    width: 70.w,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
            // Title & details
            SizedBox(
              height: 8.h,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item.title ?? '',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
            ),
            // Author
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.description ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.3),
                ),
              ),
            ),
            // Duration
            SizedBox(
              height: 4.h,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.duration ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                ),
              ),
            ),
            const Spacer(),
            // Heart / Favorite icon row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Provider.of<FavoriteProvider>(context)
                            .isFavorite('audio', item.id.toString())
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.white,
                    size: 18.r,
                  ),
                  onPressed: () {
                    Provider.of<FavoriteProvider>(context, listen: false)
                          .toggleFavorite(
                        'audio',
                        item.id.toString(),
                        title: item.title.toString(),
                        description: item.description.toString(),
                        image: item.image.toString(),
                        isPurchased: item.isPurchased ?? false,
                      );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItemVideoCard(PurchaseItem item) {
    return InkWell(
      onTap: item.isCategory == true
          ? () {
              Navigator.pushNamed(context, NavigationConstants.allVideos,
                  arguments: {
                    'id': item.id,
                    'artistName': item.title,
                    'artistImage': item.image
                  });
            }
          : () {
              Navigator.pushNamed(context, NavigationConstants.videoPlayer);
            },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2), // Shadow direction
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomNetworkImageView(
                    imageUrl: item.image ?? '',
                    fallbackImageUrl:
                        'https://example.com/nonexistent-image.jpg',
                    height: 100.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ],
            ),
            // Title & details
            SizedBox(height: 8.h),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, top: 4),
              child: Text(
                item.name ?? '',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Author
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.description ?? '',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white70,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Video Duration
            SizedBox(height: 4.0),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    item.audioDuration ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white54,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Provider.of<FavoriteProvider>(context)
                            .isFavorite('video', item.id.toString())
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.white,
                    size: 18.r,
                  ),
                  onPressed: () {
                    
                    Provider.of<FavoriteProvider>(context, listen: false)
                          .toggleFavorite(
                        'video',
                        item.id.toString(),
                        title: item.title??'N/A',
                        description: item.description??'N/A',
                        image: item.image??'N/A',
                        isPurchased: item.isPurchased ?? false,
                      );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemBookCard(PurchaseItem item) {
    return InkWell(
      onTap: item.isCategory == true
          ? () {
              Navigator.pushNamed(context, NavigationConstants.bookList,
                  arguments: {
                    'id': item.id,
                    'bookTitle': item.title,
                    'bookImage': item.image
                  });
            }
          : () {
              Navigator.pushNamed(
                context,
                NavigationConstants.bookReader,
                arguments: {
                  'filePath': item.pdf ?? '',
                  'fileType': 'pdf',
                },
              );
            },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              spreadRadius: 2,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: CustomNetworkImageView(
                imageUrl: item.image ?? '',
                fallbackImageUrl: 'https://example.com/nonexistent-image.jpg',
                height: 100.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? '',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.description ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'author',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white54,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Provider.of<FavoriteProvider>(context)
                              .isFavorite('book', item.id.toString())
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.white,
                      size: 18.r,
                    ),
                    onPressed: () {
                      Provider.of<FavoriteProvider>(context, listen: false)
                          .toggleFavorite(
                        'book',
                        item.id.toString(),
                        title: item.title.toString(),
                        description: item.description.toString(),
                        image: item.image.toString(),
                        isPurchased: item.isPurchased ?? false,
                      );
                    },
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
