import 'package:muradezema/utils/dio_client.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:muradezema/provider/album_provider.dart';
import 'package:muradezema/provider/audio_category.dart';
import 'package:muradezema/provider/top_selling_provider.dart';
import 'package:muradezema/screens/audio/player_task.dart';
import 'package:muradezema/utils/endpoint.dart';
import 'package:provider/provider.dart';
import '../commons/custom_top_selling.dart';
import '../utils/user_prefs.dart';
import '../utils/api_services.dart';
import '../commons/audio_card.dart';
import '../commons/book_title.dart';
import '../commons/category_chip.dart';
import '../commons/custom_appbar.dart';
import '../commons/custom_bottom_nav.dart';
import '../commons/custom_input.dart';
import '../commons/custom_text.dart';
import '../provider/dark_mode.dart';
import '../provider/profile_provider.dart';
import '../utils/nav_constants.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'payment_screen.dart';

final _noScreenshot = NoScreenshot.instance;

class AudioHomeScreen extends StatefulWidget {
  const AudioHomeScreen({super.key});

  @override
  State<AudioHomeScreen> createState() => _AudioHomeScreenState();
}

class _AudioHomeScreenState extends State<AudioHomeScreen> {
  int _currentIndex = 1;
  int selectedCategoryIndex = 0;
  int selectedCatId = 0;

  void updateFcmToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM Token: $fcmToken');
    final api = ApiClient();
    debugPrint(
        '${ApiConstants.baseUrl}/api/store-device-token useridt ${HivePrefs.getInt('userId')} and device token $fcmToken');
    final response = await api.post(
      '${ApiConstants.baseUrl}/store-device-token',
      data: {'device_token': fcmToken, 'user_id': HivePrefs.getInt('userId')},
    );
    debugPrint('Response fcm token: $response');
  }

  @override
  void initState() {
    super.initState();
    _checkLocation();
    updateFcmToken();

    // disableScreenshot(); // Disabled for App Store screenshots
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Only show the country dialog if not already set
      bool hasSelectedCountry =
          HivePrefs.getBool('hasSelectedCountry') ?? false;
      if (!hasSelectedCountry) {
        await showCountryOrCurrencyDialog(context);
      }
      Provider.of<AudioCategoryProvider>(context, listen: false).fetchAudios();
      Provider.of<TopSellingProvider>(context, listen: false)
          .loadTopSellingAudio('audio');
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
    });
  }

  Future<void> _checkLocation() async {
    // bool result = await LocationUtils.isLocal();

    // print('result $result');
    // if (mounted) {
    //   setState(() {
    //     HivePrefs.saveBool('isLocal', result);
    //   });
    // }
  }

  void disableScreenshot() async {
    bool result = await _noScreenshot.screenshotOff();
    debugPrint('Screenshot Off: $result');
  }

  Future<void> showCountryOrCurrencyDialog(BuildContext context) async {
    String? selectedCountry;
    final List<String> countryList = [
      'Ethiopia',
      'Other',
    ];

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Where do you live currently?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Country",
                  border: OutlineInputBorder(),
                ),
                value: selectedCountry,
                items: countryList
                    .map((country) => DropdownMenuItem<String>(
                          value: country,
                          child: Text(country),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCountry = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: selectedCountry != null
                      ? () async {
                          // Save the selected country and set currency/isLocal
                          if (selectedCountry == 'Ethiopia') {
                            await HivePrefs.saveBool('isLocal', true);
                            await HivePrefs.saveString(
                                'selectedCurrency', 'ETB');
                          } else {
                            await HivePrefs.saveBool('isLocal', false);
                            await HivePrefs.saveString(
                                'selectedCurrency', 'USD');
                          }
                          await HivePrefs.saveString(
                              'selectedCountry', selectedCountry!);
                          await HivePrefs.saveBool('hasSelectedCountry', true);
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String artistImage = '';

  @override
  Widget build(BuildContext context) {
    final audioCategory = Provider.of<AudioCategoryProvider>(context);
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
          if (Platform.isAndroid) {
            SystemNavigator.pop(); // for Android
          } else {
            exit(0); // for iOS or general fallback
          }
        }

        return false; // prevent default back navigation
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.easeInOut,
          )),
          child: Scaffold(
            backgroundColor: backgroundColor,
            appBar: MyCustomAppBar(
              title: '',
              onBack: () {
                Navigator.of(context).pop();
              },
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      NavigationConstants.notifications,
                    );
                  },
                  icon:
                      const Icon(Icons.notifications, color: Color(0xffB4A0B1)),
                ),
                IconButton(
                  icon: const Icon(Icons.brightness_6),
                  onPressed: () {
                    Provider.of<DarkModeProvider>(context, listen: false)
                        .toggleDarkMode();
                  },
                ),
                Consumer<ProfileProvider>(builder: (context, value, child) {
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
                                        Navigator.pushNamed(context,
                                            NavigationConstants.profile);
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
                                        Navigator.pushNamed(context,
                                            NavigationConstants.loginPage);
                                        final response = await api.post(
                                          '${dotenv.env['BASE_URL']!}/logout',
                                          headers: {
                                            'Authorization':
                                                'Bearer ${HivePrefs.getString('token')}',
                                            'Accept': 'application/json'
                                          },
                                        );

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
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                }),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 6.h),
                  CustomText(
                    'Find Your',
                    color:
                        isDarkMode ? Colors.white38 : const Color(0xff96979B),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  CustomText(
                    'AUDIO BOOKS',
                    fontSize: 18.sp,
                    color: isDarkMode ? Colors.white : const Color(0xff1C1C1E),
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, NavigationConstants.search);
                    },
                    child: CustomInputField(
                      hintText: 'Search for audio book, video',
                      icon: Icons.search,
                      isSearch: true,
                      index: 0,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (audioCategory.audios.isEmpty)
                            Center(
                              child: LoadingAnimationWidget.inkDrop(
                                color: textColor,
                                size: 30.h,
                              ),
                            )
                          else
                            SizedBox(
                              height: 40.h,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: audioCategory.audios.length,
                                itemBuilder: (context, index) {
                                  final category = audioCategory.audios[index];
                                  if (selectedCatId == 0 && index == 0) {
                                    selectedCatId = category.id ?? 1;
                                    Provider.of<AlbumProvider>(context,
                                            listen: false)
                                        .fetchAlbums(
                                            artistId: selectedCatId, page: 1);
                                  }
                                  return InkWell(
                                    onTap: () async {
                                      int podcastId = category.id ?? 1;
                                      await Provider.of<AlbumProvider>(context,
                                              listen: false)
                                          .fetchAlbums(
                                              artistId: podcastId, page: 1);
                                      setState(() {
                                        selectedCategoryIndex = index;
                                        selectedCatId = podcastId;
                                        artistImage = category.image ?? '';
                                      });
                                    },
                                    child: CategoryChip(
                                      label: category.name ?? 'N/A',
                                      color: tabColor,
                                      isSelected:
                                          selectedCategoryIndex == index,
                                    ),
                                  );
                                },
                              ),
                            ),
                          SizedBox(height: 20.h),
                          Consumer<AlbumProvider>(
                            builder: (context, albumProvider, child) {
                              if (albumProvider.isLoading) {
                                return Center(
                                  child: LoadingAnimationWidget.inkDrop(
                                    color: textColor,
                                    size: 30.h,
                                  ),
                                );
                              }
                              if (albumProvider.errorMessage != null) {
                                // Navigator.pushNamed(
                                //   context,
                                //   NavigationConstants.loginPage,
                                // );
                              }
                              if (albumProvider.albums.isEmpty) {
                                return Center(
                                    child: Text('No audios available.'));
                              }
                              return SizedBox(
                                height: 220.h,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: albumProvider.albums.length,
                                  itemBuilder: (context, index) {
                                    final season = albumProvider.albums[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          NavigationConstants.allAudios,
                                          arguments: {
                                            'id': season.id,
                                            'artistName': season.title,
                                            'artistImage': season.image
                                          },
                                        );
                                      },
                                      child: AudioBookCard(
                                          isPurchased:
                                              season.isPurchased ?? false,
                                          imagePath: season.image ?? '',
                                          title:
                                              season.title ?? 'Unknown Season',
                                          episodes: season.title.toString(),
                                          id: season.id,
                                          price: season.priceInLocal?.toInt(),
                                          songCount: season.songsCount ?? '0'),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 20.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                'Top Selling Audios',
                                fontSize: 16.sp,
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context,
                                      NavigationConstants.topSellingList,
                                      arguments: {'type': 'audio'});
                                },
                                child: CustomText(
                                  'View all',
                                  fontSize: 14.sp,
                                  color: textColor,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Consumer<TopSellingProvider>(
                            builder: (context, value, child) =>
                                ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: value.sales.length,
                              itemBuilder: (context, index) => InkWell(
                                onTap: value.sales[index].product.isPurchased
                                    ? () async {
                                        final Dio dio = createDio();
                                        try {
                                          final response = await dio.post(
                                            '${dotenv.env['BASE_URL']!}/audio/episodes/${value.sales[index].product.id}/play',
                                            options: Options(
                                              headers: {
                                                'Authorization':
                                                    'Bearer ${HivePrefs.getString('token')}',
                                              },
                                            ),
                                          );
                                          if (response.statusCode == 200) {
                                            final audioUrl =
                                                response.data['audio'];
                                            if (audioUrl.isNotEmpty) {
                                              final parts = value
                                                  .sales[index].product.duration
                                                  .split(":");
                                              final minutes =
                                                  int.tryParse(parts[0]) ?? 0;
                                              final seconds =
                                                  int.tryParse(parts[1]) ?? 0;
                                              final duration = Duration(
                                                  minutes: minutes,
                                                  seconds: seconds);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => MainScreen(
                                                    id: audioUrl,
                                                    title: value.sales[index]
                                                        .product.title,
                                                    album: value.sales[index]
                                                        .product.description,
                                                    artist: value.sales[index]
                                                        .product.description,
                                                    artUri: Uri.parse(value
                                                        .sales[index]
                                                        .product
                                                        .image),
                                                    duration: duration,
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        } catch (e) {}
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
                                                      ? int.parse(value
                                                          .sales[index]
                                                          .product
                                                          .priceInLocal)
                                                      : int.parse(value
                                                          .sales[index]
                                                          .product
                                                          .priceInForeign),
                                                  productId: value
                                                      .sales[index].product.id,
                                                  type: 'audio')),
                                        );
                                      },
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: TopSellingCard(
                                    isPurchased:
                                        value.sales[index].product.isPurchased,
                                    imagePath: value.sales[index].product.image,
                                    title: value.sales[index].product.title,
                                    subtitle:
                                        value.sales[index].product.description,
                                    price: value
                                        .sales[index].product.priceInLocal
                                        .toString(),
                                    foreignPrice: value
                                        .sales[index].product.priceInForeign
                                        .toString(),
                                    id: value.sales[index].product.id,
                                    category: 'Audio',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
          ),
        ),
      ),
    );
  }
}

class ViewAllTopSellingScreen extends StatelessWidget {
  const ViewAllTopSellingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Selling Audios'),
      ),
      body: Consumer<TopSellingProvider>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (value.sales.isEmpty) {
            return const Center(child: Text('No top selling audios found.'));
          }
          return ListView.builder(
            itemCount: value.sales.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () async {
                final Dio dio = createDio();
                try {
                  final response = await dio.post(
                    '${dotenv.env['BASE_URL']!}/audio/episodes/${value.sales[index].product.id}/play',
                    options: Options(
                      headers: {
                        'Authorization':
                            'Bearer ${HivePrefs.getString('token')}',
                      },
                    ),
                  );
                  if (response.statusCode == 200) {
                    final audioUrl = response.data['audio'];
                    if (audioUrl.isNotEmpty) {
                      final parts =
                          value.sales[index].product.duration.split(":");
                      final minutes = int.tryParse(parts[0]) ?? 0;
                      final seconds = int.tryParse(parts[1]) ?? 0;
                      final duration =
                          Duration(minutes: minutes, seconds: seconds);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MainScreen(
                            id: audioUrl,
                            title: value.sales[index].product.title,
                            album: value.sales[index].product.description,
                            artist: value.sales[index].product.description,
                            artUri: Uri.parse(value.sales[index].product.image),
                            duration: duration,
                          ),
                        ),
                      );
                    }
                  }
                } catch (e) {}
              },
              child: SizedBox(
                height: 4,
                child: AudioTitle(
                    imagePath: value.sales[index].product.image,
                    title: value.sales[index].product.title,
                    description: value.sales[index].product.description,
                    price: value.sales[index].product.priceInLocal.toString(),
                    id: value.sales[index].product.id),
              ),
            ),
          );
        },
      ),
    );
  }
}
