import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:muradezema/provider/album_provider.dart';
// import 'package:muradezema/provider/book_list_provider.dart';
import 'package:muradezema/screens/album_list_screen.dart';
import 'package:muradezema/utils/nav_constants.dart';
import 'package:provider/provider.dart';
import '../provider/book_season.dart';
import '../provider/dark_mode.dart';
import '../provider/search_provider.dart';
import '../commons/book_title.dart';
import '../provider/video_category_detail.dart';
import '../utils/user_prefs.dart';
import 'audio/player_task.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'payment_screen.dart';

enum ContentType { audio, book, video }

class SearchScreen extends StatefulWidget {
  final int initialTab;
  const SearchScreen({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late TabController _mainController;
  late TabController _audioController;
  late TabController _bookController;
  late TabController _videoController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _mainController = TabController(
      length: ContentType.values.length,
      vsync: this,
      initialIndex: widget.initialTab,
    );

    _audioController = TabController(length: 3, vsync: this);
    _bookController = TabController(length: 3, vsync: this);
    _videoController = TabController(length: 3, vsync: this);

    _mainController.addListener(() {
      if (_mainController.indexIsChanging) return;
      _audioController.index = 0;
      _bookController.index = 0;
      _videoController.index = 0;
      _performSearch();
    });

    _audioController.addListener(_performSearch);
    _bookController.addListener(_performSearch);
    _videoController.addListener(_performSearch);

    _searchController.addListener(() {
      _performSearch();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _performSearch());
  }

  @override
  void dispose() {
    _mainController.dispose();
    _audioController.dispose();
    _bookController.dispose();
    _videoController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim().isEmpty
        ? 'mur'
        : _searchController.text.trim();
    final type = ContentType.values[_mainController.index].name;
    Provider.of<SearchProvider>(context, listen: false).search(query, type);
  }

  Widget _buildModernTabs() {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    final selectedColor = Colors.orange;
    // final unselectedColor = isDarkMode ? Colors.white24 : Colors.black12;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ContentType.values.asMap().entries.map((entry) {
            int i = entry.key;
            String label = entry.value.name.toUpperCase();

            final isSelected = _mainController.index == i;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _mainController.animateTo(i);
                  });
                  _performSearch();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? selectedColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String makeFirstCharLower(String input) {
    if (input.isEmpty) return input;
    return input[0].toLowerCase() + input.substring(1);
  }

  Widget _buildSubTabs(TabController ctl, List<String> labels) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Column(
      children: [
        TabBar(
          controller: ctl,
          isScrollable: true,
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
          unselectedLabelColor: textColor.withOpacity(0.5),
          indicator: UnderlineTabIndicator(
            borderSide: const BorderSide(width: 3.0, color: Colors.orange),
            insets: const EdgeInsets.symmetric(horizontal: 16),
          ),
          tabs: labels.map((l) => Tab(text: l)).toList(),
        ),
        Expanded(
          child: Consumer<SearchProvider>(
            builder: (context, prov, _) {
              if (prov.isLoading) {
                return Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.orangeAccent,
                    size: 40.h,
                  ),
                );
              }
              if (prov.errorMessage != null) {
                return Center(
                    child: Text(prov.errorMessage!,
                        style: TextStyle(color: textColor)));
              }

              final sections = prov.result?.sections ?? {};
              final key = makeFirstCharLower(labels[ctl.index]);
              final items = sections[key] ?? [];

              if (items.isEmpty) {
                return Center(
                    child: Text('No results found',
                        style: TextStyle(color: textColor)));
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: GridView.builder(
                  key: ValueKey(key),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    debugPrint('bar ${items[i]}');
                    final item = items[i];
                    final imageUrl = item['image'] ?? 'N/A';
                    final title = item['title'] ?? item['name'] ?? 'N/A';
                    final String price = item['price_in_local'] ?? '0';
                    // final String foreignPrice = item['price_in_local'] ?? '0';

                    final desc = item['description'] ?? item['bio'] ?? 'N/A';
                    final id = item['id'] ?? 'N/A';

                    switch (_mainController.index) {
                      case 0:
                        return InkWell(
                          onTap: () async {
                            if (labels[ctl.index] == 'Songs' &&
                                item["is_purchased"] == true) {
                              final Dio dio = Dio();
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
                                  debugPrint('response ${response.data}');
                                  final audioUrl = response.data['audio'];
                                  if (audioUrl.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MainScreen(
                                          id: audioUrl,
                                          title: title,
                                          album: desc,
                                          artist: desc,
                                          artUri: Uri.parse(imageUrl),
                                          duration: Duration(seconds: 30),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                debugPrint('Error fetching audio: $e');
                              }
                            } else if (labels[ctl.index] == 'Albums' &&
                                item["is_purchased"] == true) {
                              debugPrint('id $id');
                              Navigator.pushNamed(
                                context,
                                NavigationConstants.allAudios,
                                arguments: {
                                  'id': id,
                                  'artistName': title,
                                  'artistImage': imageUrl
                                },
                              );
                            } else if (labels[ctl.index] == "Artists") {
                              final albumProvider = Provider.of<AlbumProvider>(
                                  context,
                                  listen: false);

                              albumProvider
                                  .fetchAlbums(artistId: id, page: 1)
                                  .then((_) {
                                final albums = albumProvider.albums;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AlbumListScreen(
                                      type: "audio",
                                      artistName: albums.first.title ?? '',
                                      artistImage: albums.first.image ?? '',
                                      albums: albums
                                          .map((album) => {
                                                'title': album.title ?? '',
                                                'year':
                                                    album.year?.toString() ??
                                                        '',
                                                'cover': '',
                                                'id': album.id.toString(),
                                                'songs_count':
                                                    album.songsCount.toString()
                                              })
                                          .toList(),
                                    ),
                                  ),
                                );
                              });
                            } else if (labels[ctl.index] != "Artists" ||
                                item["is_purchased"] == false) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PaymentPage(
                                        isCategory:
                                            labels[ctl.index] == "Albums",
                                        phone: 'phone',
                                        price: int.parse(price),
                                        productId: id ?? 0,
                                        type: "audio")),
                              );
                            }
                          },
                          child: AudioTitle(
                            isPurchased: item['is_purchased'],
                            imagePath: imageUrl,
                            title: title,
                            price: '$price Birr',
                            description: desc,
                            type: labels[ctl.index],
                            id: id,
                          ),
                        );
                      case 1:
                        return InkWell(
                          onTap: () async {
                            final label = labels[ctl.index];
                            debugPrint('Tapped book label: $label');
                            if (label == 'SeasonAudioBooks' &&
                                item["is_purchased"] == true) {
                              Navigator.pushNamed(
                                context,
                                NavigationConstants.bookList,
                                arguments: {
                                  'id': id,
                                  'bookTitle': title,
                                  'bookImage': imageUrl
                                },
                              );
                            } else if (label == 'EpisodeAudioBooks' &&
                                item["is_purchased"] == true) {
                              try {
                                final resp = await Dio().get(
                                    "${dotenv.env['BASE_URL']}/books/$id/read",
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
                            } else if (label == "AudioBooks") {
                              final albumProvider =
                                  Provider.of<BookSeasonProvider>(context,
                                      listen: false);

                              albumProvider.fetchBooks(id).then((_) {
                                final books = albumProvider.books;
                                final book =
                                    books.isNotEmpty ? books.first : null;
                                if (book != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AlbumListScreen(
                                        type: "book",
                                        artistName: book.title ?? '',
                                        artistImage: book.image ?? '',
                                        albums: (book.season ?? [])
                                            .map((episode) => {
                                                  'title': episode.title ?? '',
                                                  'year': '',
                                                  'cover': book.image ?? '',
                                                  'id':
                                                      episode.id?.toString() ??
                                                          '',
                                                  'songs_count': ''
                                                })
                                            .toList(),
                                      ),
                                    ),
                                  );
                                }
                              });
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PaymentPage(
                                        isCategory: label == "SeasonAudioBooks",
                                        phone: 'phone',
                                        price: int.parse(price),
                                        productId: id ?? 0,
                                        type: 'book')),
                              );
                            }
                          },
                          child: BookTile(
                            imagePath: imageUrl,
                            title: title,
                            price: '$price Birr',
                            description: desc,
                            type: labels[ctl.index],
                            id: id,
                            isPurchased: item['is_purchased'] ?? false,
                          ),
                        );

                      case 2:
                        return InkWell(
                          onTap: () {
                            if (labels[ctl.index] == 'Episodes') {
                              Navigator.pushNamed(
                                context,
                                NavigationConstants.allVideos,
                                arguments: {
                                  'id': id,
                                  'artistName': title,
                                  'artistImage': imageUrl
                                },
                              );
                            } else if (labels[ctl.index] == 'Seasons' &&
                                item["is_purchased"] == true) {
                              Navigator.pushNamed(
                                context,
                                NavigationConstants.videoPlayer,
                                arguments: {
                                  'id': id,
                                  "name": title,
                                  'image': imageUrl,
                                  "title": title
                                },
                              );
                            } else if (labels[ctl.index] == 'Podcasts') {
                              final albumProvider =
                                  Provider.of<VideoCategoryDetailProvider>(
                                      context,
                                      listen: false);

                              albumProvider.fetchCategoryDetail(id).then((_) {
                                final albums = albumProvider.categoryDetail;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AlbumListScreen(
                                      type: "video",
                                      artistName: albums?.title ??
                                          '', // Make sure this exists
                                      artistImage: albums?.image ??
                                          '', // Replace with actual image URL
                                      albums: albums?.seasons
                                              .map((episode) => {
                                                    'title': episode.title,
                                                    'year': '',
                                                    'cover': albums.image,
                                                    'id': episode.id.toString(),
                                                    'songs_count': ''
                                                  })
                                              .toList() ??
                                          [],
                                    ),
                                  ),
                                );
                              });
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PaymentPage(
                                        isCategory:
                                            labels[ctl.index] == "Episodes",
                                        phone: 'phone',
                                        price: int.parse(price),
                                        productId: id ?? 0,
                                        type: 'video')),
                              );
                            }
                          },
                          child: VideoTile(
                              price: price,
                              thumbnailUrl: imageUrl,
                              title: title,
                              videoCount: 1,
                              isPurchased: item['is_purchased'],
                              duration: item['start_time'] ?? '',
                              description: desc,
                              type: labels[ctl.index],
                              id: id),
                        );
                      default:
                        return const SizedBox();
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    final backgroundColor =
        isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xfff0eded);
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: textColor.withOpacity(0.7)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear, color: textColor),
            onPressed: () {
              _searchController.clear();
              _performSearch();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildModernTabs(),
          Expanded(
            child: TabBarView(
              controller: _mainController,
              children: [
                _buildSubTabs(_audioController, ['Artists', 'Albums', 'Songs']),
                _buildSubTabs(_bookController,
                    ['AudioBooks', 'SeasonAudioBooks', 'EpisodeAudioBooks']),
                _buildSubTabs(
                    _videoController, ['Podcasts', 'Episodes', 'Seasons']),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
