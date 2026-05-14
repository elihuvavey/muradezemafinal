import 'package:flutter/material.dart';
import 'package:muradezema/utils/endpoint.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../provider/top_selling_provider.dart';
import '../commons/book_title.dart';
import '../utils/nav_constants.dart';
import '../utils/user_prefs.dart';
import 'audio/player_task.dart';
import 'payment_screen.dart';
import 'video_player_screen.dart';

class TopSellingListScreen extends StatelessWidget {
  const TopSellingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String type = arguments?['type'] ?? 'Items';
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Selling ${type[0].toUpperCase()}${type.substring(1)}',
            style: TextStyle(color: Colors.white)),
      ),
      body: type == 'audio'
          ? Consumer<TopSellingProvider>(
              builder: (context, value, child) {
                if (value.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (value.sales.isEmpty) {
                  return Center(child: Text('No top selling ${type}s found.'));
                }
                return ListView.builder(
                  itemCount: value.sales.length,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () async {
                      final Dio dio = Dio();
                      try {
                        final response = await dio.post(
                          "${ApiConstants.baseUrl}/audio/episodes/${value.sales[index].product.id}/play",
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
                                  artist:
                                      value.sales[index].product.description,
                                  artUri: Uri.parse(
                                      value.sales[index].product.image),
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
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: AudioTitle(
                        imagePath: value.sales[index].product.image,
                        title: value.sales[index].product.title,
                        description: value.sales[index].product.description,
                        price:
                            value.sales[index].product.priceInLocal.toString(),
                        id: value.sales[index].product.id,
                      ),
                    ),
                  ),
                );
              },
            )
          : type == 'video'
              ? SizedBox(
                  child: Consumer<TopSellingProvider>(
                    builder: (context, detailProvider, child) {
                      final category = detailProvider.sales;
                      if (category.isEmpty) {
                        return Center(child: Text('No episodes available.'));
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: category.length,
                        itemBuilder: (context, index) {
                          final episode = category[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: InkWell(
                              onTap: episode.product.isPurchased
                                  ? () async {
                                      debugPrint('h');
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.orange,
                                          ),
                                        ),
                                      );
                                      try {
                                        final response = await Dio().get(
                                          "${ApiConstants.baseUrl}/video/episodes/${episode.product.id}/play",
                                          options: Options(
                                            headers: {
                                              'Accept': 'application/json',
                                              'Authorization':
                                                  'Bearer ${HivePrefs.getString('token')}',
                                            },
                                            validateStatus: (status) =>
                                                status! < 500,
                                          ),
                                        );
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop(); // Remove progress dialog

                                        // Check for the specific message
                                        if (response.data
                                                is Map<String, dynamic> &&
                                            response.data['message'] ==
                                                "You need to purchase this episode to play it.") {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title:
                                                  const Text('Access Denied'),
                                              content: Text(
                                                  response.data['message']),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else if (response.statusCode == 200 &&
                                            response.data['success'] == true) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  VideoPlayerScreen(),
                                              settings: RouteSettings(
                                                arguments: {
                                                  'videoUrl':
                                                      response.data['video'],
                                                  'name': episode.product.title,
                                                  'title': episode
                                                      .product.description,
                                                },
                                              ),
                                            ),
                                          );
                                        } else {
                                          // Handle other unexpected responses
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Error'),
                                              content: Text(
                                                response.data['message']
                                                        ?.toString() ??
                                                    'An unexpected error occurred.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop(); // Remove progress dialog
                                        debugPrint('Error loading video: $e');
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Error'),
                                            content:
                                                Text('Error loading video: $e'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PaymentPage(
                                                isCategory: false,
                                                phone: 'phone',
                                                price: int.parse(episode
                                                    .product.priceInLocal),
                                                productId: episode.product.id,
                                                type: 'video')),
                                      );
                                    },
                              child: VideoTile(
                                price: HivePrefs.getBool('isLocal') == true
                                    ? "${episode.product.priceInLocal} ETB"
                                    : "\$${episode.product.priceInForeign}",
                                videoCount: 1,
                                thumbnailUrl: episode.product.image,
                                title: episode.product.title,
                                description: episode.product.description,
                                duration: episode.product.duration,
                                id: episode.product.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              : Consumer<TopSellingProvider>(
                  builder: (context, value, child) => SizedBox(
                    height: 320,
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: value.sales.length,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.all(4),
                          child: InkWell(
                            onTap: value.sales[index].product.isPurchased
                                ? () async {
                                    try {
                                      final resp = await Dio().get(
                                          '${ApiConstants.baseUrl}/books/${value.sales[index].product.id}/read');
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
                                      debugPrint('Error loading PDF: $e');
                                    }
                                  }
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PaymentPage(
                                              isCategory: false,
                                              phone: 'phone',
                                              price: int.parse(value
                                                  .sales[index]
                                                  .product
                                                  .priceInLocal),
                                              productId:
                                                  value.sales[index].product.id,
                                              type: 'video')),
                                    );
                                  },
                            child: BookTile(
                              isPurchased:
                                  value.sales[index].product.isPurchased,
                              imagePath: value.sales[index].product.image,
                              title: value.sales[index].product.title,
                              description:
                                  value.sales[index].product.description,
                              price: value.sales[index].product.priceInLocal
                                  .toString(),
                              id: value.sales[index].product.id,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
