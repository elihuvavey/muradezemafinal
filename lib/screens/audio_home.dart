import 'package:muradezema/utils/dio_client.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:muradezema/commons/custom_bottom_nav.dart';
import 'package:muradezema/commons/custom_top_selling.dart';
import 'package:muradezema/provider/top_selling_provider.dart';
import 'package:provider/provider.dart';

import '../commons/book_card.dart';
import '../provider/profile_provider.dart';

import '../commons/category_chip.dart';
import '../commons/custom_appbar.dart';
import '../commons/custom_input.dart';
import '../commons/custom_text.dart';
import '../provider/book.dart';
import '../provider/book_season.dart';
import '../provider/dark_mode.dart';
import '../utils/api_services.dart';
import '../utils/endpoint.dart';
import '../utils/nav_constants.dart';
import '../utils/user_prefs.dart';
import 'payment_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BookHomeScreen extends StatefulWidget {
  const BookHomeScreen({super.key});

  @override
  State<BookHomeScreen> createState() => _BookHomeScreenState();
}

class _BookHomeScreenState extends State<BookHomeScreen> {
  int _currentIndex = 0;
  int selectedCategoryIndex = 0;
  int selectedCatId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(context, listen: false).fetchBooks();
      Provider.of<TopSellingProvider>(context, listen: false)
          .loadTopSellingAudio('book');
    });
  }

  String bookImage = '';

  @override
  Widget build(BuildContext context) {
    final audioCategory = Provider.of<BookProvider>(context);
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;

    Color backgroundColor =
        isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xfff0eded);
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    Color tabColor = isDarkMode ? Colors.white24 : Colors.black26;
    if (audioCategory.books.isNotEmpty) {
      bookImage = audioCategory.books.first.image ?? '';
    }

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
              icon: const Icon(Icons.notifications, color: Color(0xffB4A0B1)),
            ),
            IconButton(
              icon: const Icon(Icons.brightness_6),
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
                                        "${dotenv.env['BASE_URL']}/logout",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Static non-scrollable section
            Padding(
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
                  CustomInputField(
                    hintText: 'Search for audio book, video',
                    icon: Icons.search,
                    isSearch: true,
                    index: 1,
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // Scrollable section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (audioCategory.books.isEmpty)
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
                          itemCount: audioCategory.books.length,
                          itemBuilder: (context, index) {
                            final category = audioCategory.books[index];
                            if (selectedCatId == 0 && index == 0) {
                              selectedCatId = category.id ?? 1;
                              Provider.of<BookSeasonProvider>(context,
                                      listen: false)
                                  .fetchBooks(selectedCatId);
                            }
                            return InkWell(
                              onTap: () async {
                                int podcastId = category.id ?? 1;
                                await Provider.of<BookSeasonProvider>(context,
                                        listen: false)
                                    .fetchBooks(podcastId);
                                setState(() {
                                  selectedCategoryIndex = index;
                                  selectedCatId = podcastId;
                                  bookImage = category.image ?? '';
                                  debugPrint('book image $bookImage');
                                });
                              },
                              child: CategoryChip(
                                label: category.title ?? 'N/A',
                                color: tabColor,
                                isSelected: selectedCategoryIndex == index,
                              ),
                            );
                          },
                        ),
                      ),
                    SizedBox(height: 20.h),
                    Consumer<BookSeasonProvider>(
                      builder: (context, albumProvider, child) {
                        if (albumProvider.books.isEmpty) {
                          return Center(child: Text('No books available.'));
                        }
                        return Column(
                          children: albumProvider.books.map((book) {
                            if (book.season == null || book.season!.isEmpty) {
                              return const Center(child: Text('No books'));
                            }

                            return SizedBox(
                              height: 220.h,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: book.season?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final s = book.season?[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        NavigationConstants.bookList,
                                        arguments: {
                                          'id': s?.id,
                                          'bookTitle': s?.title,
                                          'bookImage': s?.image ?? bookImage
                                        },
                                      );
                                    },
                                    child: BookCard(
                                        id: s?.id ?? 0,
                                        isPurchased: s?.isPurchased ?? false,
                                        imagePath: s?.image ?? bookImage,
                                        title: s?.title ?? 'Unknown Season',
                                        episodes: s?.episodeCount ?? 0,
                                        price: s?.priceInLocal ?? 0.0),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          'Top Selling Books',
                          fontSize: 16.sp,
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, NavigationConstants.topSellingList,
                                arguments: {'type': 'book'});
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
                      builder: (context, value, child) => SizedBox(
                        // height: 320.h,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: value.sales.length,
                          itemBuilder: (context, index) => InkWell(
                            onTap: value.sales[index].product.isPurchased
                                ? () async {
                                    debugPrint('hey');
                                    debugPrint(
                                        'Tapped on purchased top selling book: id=${value.sales[index].product.id}, title=${value.sales[index].product.title}');
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                    try {
                                      final resp = await createDio().get(
                                          '${ApiConstants.baseUrl}/books/${value.sales[index].product.id}/read',
                                          options: Options(
                                            headers: {
                                              'Authorization':
                                                  'Bearer ${HivePrefs.getString('token')}',
                                            },
                                          ));
                                      debugPrint('Response: $resp');
                                      Navigator.of(context)
                                          .pop(); // Remove progress dialog
                                      final pdfUrl = resp.data['pdf'] as String;
                                      if (pdfUrl.isNotEmpty) {
                                        Navigator.pushNamed(context,
                                            NavigationConstants.bookReader,
                                            arguments: {
                                              'filePath': pdfUrl,
                                              'fileType': 'pdf',
                                            });
                                      }
                                    } catch (e) {
                                      Navigator.of(context)
                                          .pop(); // Remove progress dialog
                                      debugPrint('Error loading PDF: $e');
                                    }
                                  }
                                : () {
                                    debugPrint('hedy');

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PaymentPage(
                                            isCategory: false,
                                            phone: 'phone',
                                            price: int.parse(value.sales[index]
                                                .product.priceInLocal),
                                            productId:
                                                value.sales[index].product.id,
                                            type: 'book'),
                                      ),
                                    );
                                  },
                            child: Padding(
                              padding: EdgeInsets.all(4.r),
                              child: TopSellingCard(
                                imagePath: value.sales[index].product.image,
                                title: value.sales[index].product.title,
                                subtitle:
                                    value.sales[index].product.description,
                                price: value.sales[index].product.priceInLocal
                                    .toString(),
                                id: value.sales[index].product.id,
                                isPurchased:
                                    value.sales[index].product.isPurchased,
                                foreignPrice: value
                                    .sales[index].product.priceInForeign
                                    .toString(),
                                category: 'Book',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
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
    );
  }
}
