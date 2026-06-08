import 'package:muradezema/utils/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:muradezema/screens/book_list.dart';
import 'package:muradezema/screens/video_player_screen.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../provider/favorite_provider.dart';
import '../provider/dark_mode.dart';
import '../utils/nav_constants.dart';
import '../utils/user_prefs.dart';
import 'audio/player_task.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'payment_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    Color backgroundColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;
    Color secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text('Favorites', style: TextStyle(color: textColor)),
          backgroundColor: backgroundColor,
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Audio'),
              Tab(text: 'Video'),
              Tab(text: 'Book'),
            ],
            labelColor: Colors.orange,
            unselectedLabelColor: secondaryTextColor,
            indicatorColor: Colors.orange,
            dividerColor: isDarkMode ? Colors.white24 : Colors.black12,
          ),
        ),
        body: TabBarView(
          children: [
            _FavoriteList(type: 'audio'),
            _FavoriteList(type: 'video'),
            _FavoriteList(type: 'book'),
          ],
        ),
      ),
    );
  }
}

class _FavoriteList extends StatelessWidget {
  final String type;

  const _FavoriteList({required this.type});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    Color backgroundColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;
    Color secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    Color cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    Color iconColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        final favorites = favoriteProvider.getFavoritesByType(type);

        if (favorites.isEmpty) {
          return Center(
            child: Text(
              'No $type favorites yet',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final favorite = favorites.values.elementAt(index);
            final id = favorites.keys.elementAt(index);

            return InkWell(
              onTap: () async {
                if (type == 'audio') {
                  final Dio dio = createDio();
                  try {
                    final response = await dio.post(
                      "${dotenv.env['BASE_URL']}/audio/episodes/$id/play",
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
                            favorite['duration']?.split(":") ?? ['0', '0'];
                        final minutes = int.tryParse(parts[0]) ?? 0;
                        final seconds = int.tryParse(parts[1]) ?? 0;
                        final duration =
                            Duration(minutes: minutes, seconds: seconds);
                        await (audioHandler as AudioPlayerHandler)
                            .loadMediaItem(
                          id: audioUrl,
                          title: favorite['title'] ?? '',
                          album: favorite['description'] ?? '',
                          artist: favorite['description'] ?? '',
                          artUri: Uri.parse(favorite['image'] ?? ''),
                          duration: duration,
                        );
                        audioHandler.play();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MainScreen(
                              id: audioUrl,
                              title: favorite['title'] ?? '',
                              album: favorite['description'] ?? '',
                              artist: favorite['description'] ?? '',
                              artUri: Uri.parse(favorite['image'] ?? ''),
                              duration: duration,
                            ),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    debugPrint('Error fetching audio: $e');
                  }
                }

                if (type == 'book')  {
                  debugPrint('favorite: ${favorite['isPurchased']}');
                if(favorite['isPurchased'] == true) { try {
                    final resp = await createDio()
                        .get('${dotenv.env['BASE_URL']}/books/$id/read',
                         options: Options(
                                headers: {
                                  'Authorization':
                                      'Bearer ${HivePrefs.getString('token')}',
                                },
                              ));
                    final pdfUrl = resp.data['pdf'] as String;
                    if (pdfUrl.isNotEmpty) {
                      Navigator.pushNamed(
                          context, NavigationConstants.bookReader,
                          arguments: {
                            'filePath': pdfUrl,
                            'fileType': 'pdf',
                          });
                    }
                  } catch (e) {
                    debugPrint('Error loading PDF: $e');
                  }
                } else {
                  debugPrint('favorite: ${favorite['id']} title: ${favorite['title']} image: ${favorite['image']}');
              
                                // bool? isLocal = HivePrefs.getBool('isLocal');
                               Navigator.pushNamed(
                      context,
                      NavigationConstants.bookHome,
                      arguments: {
                        'id': favorite['id']??0,
                        'bookTitle': favorite['title'],
                        'bookImage': favorite['image']
                      },
                    );
                              
                }
                }
                if (type == 'video') {
                  try {
                    final response = await createDio().get(
                      "${dotenv.env['BASE_URL']}/video/episodes/$id/play",
                      options: Options(
                        headers: {
                          'Accept': 'application/json',
                          'Authorization':
                              'Bearer ${HivePrefs.getString('token')}',
                        },
                        validateStatus: (status) => status! < 500,
                      ),
                    );

                    if (response.statusCode == 200 &&
                        response.data['success'] == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(),
                          settings: RouteSettings(
                            arguments: {
                              'videoUrl': response.data['video'],
                              'name': favorite['title'] ?? '',
                              'title': favorite['description'] ?? '',
                            },
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('Error loading video: $e');
                  }
                }
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: cardColor,
                elevation: isDarkMode ? 0 : 2,
                child: ListTile(
                  leading: favorite['image'] != null &&
                          favorite['image'].toString().isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            favorite['image'],
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 56,
                                height: 56,
                                color: isDarkMode
                                    ? Colors.grey[700]
                                    : Colors.grey[300],
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: iconColor,
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey[700]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            type == 'audio'
                                ? Icons.audio_file
                                : type == 'video'
                                    ? Icons.video_file
                                    : Icons.book,
                            color: iconColor,
                          ),
                        ),
                  title: Text(
                    favorite['title'] ?? 'Untitled',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  subtitle: favorite['description'] != null &&
                          favorite['description'].toString().isNotEmpty
                      ? Text(
                          favorite['description'],
                          style: TextStyle(
                            color: secondaryTextColor,
                          ),
                        )
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      favoriteProvider.removeFavorite(type, id);
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
