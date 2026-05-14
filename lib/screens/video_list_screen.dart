import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:muradezema/commons/custom_images.dart';
import 'package:muradezema/provider/related_video_provider.dart';
import 'package:muradezema/screens/payment_screen.dart';
import 'package:provider/provider.dart';
import '../utils/nav_constants.dart';
import '../utils/user_prefs.dart';

class RelatedEpisodesScreen extends StatefulWidget {
  const RelatedEpisodesScreen({super.key});

  @override
  State<RelatedEpisodesScreen> createState() => _RelatedEpisodesScreenState();
}

class _RelatedEpisodesScreenState extends State<RelatedEpisodesScreen> {
  int? _seasonId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int newSeasonId = args['id'];

    // Fetch related videos only if they haven't been fetched yet
    if (_seasonId != newSeasonId) {
      _seasonId = newSeasonId;
      Provider.of<RelatedVideoProvider>(context, listen: false)
          .fetchRelatedVideos(newSeasonId);
    }
  }

  bool isBought = false;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String artistName = args['artistName'];
    final String artistImage = args['artistImage'];

    final relatedVideoProvider = Provider.of<RelatedVideoProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          artistName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Artist Image
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomNetworkImageView(
                imageUrl: artistImage,
                fallbackImageUrl:
                    'https://yt3.googleusercontent.com/c1__fQjiBX3tYvE5cfrp2SeK3EnybEvA-qjesXv3Rv-RrwMp7jm4yKxEamHNIELN3WDjlLut=s900-c-k-c0x00ffffff-no-rj',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Top Videos",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: relatedVideoProvider.isLoading
                ? Center(
                    child: LoadingAnimationWidget.inkDrop(
                    color: Colors.orange,
                    size: 30,
                  ))
                : relatedVideoProvider.errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          "No videos",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : relatedVideoProvider.relatedVideos.isEmpty
                        ? const Center(
                            child: Text(
                              "No related videos available.",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            itemCount:
                                relatedVideoProvider.relatedVideos.length,
                            itemBuilder: (context, index) {
                              final episode =
                                  relatedVideoProvider.relatedVideos[index];
                              return InkWell(
                                onTap: episode.isPurchased??false
                                 ?  () {
                                  Navigator.pushNamed(
                                    context,
                                    NavigationConstants.videoPlayer,
                                    arguments: {
                                      'id': episode.id,
                                      "name": episode.name,
                                      'image': episode.image,
                                      "title": episode.description
                                    },
                                  );
                                }:(){
                                  bool? isLocal = HivePrefs.getBool('isLocal');

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => PaymentPage(
                                                      isCategory: false,
                                                      phone: 'phone',
                                                      price: isLocal??false
                                                          ? int.parse(episode
                                                                  .priceInLocal ??
                                                              '0')
                                                          : int.parse(episode
                                                                  .priceInForeign ??
                                                              '0'),
                                                      productId:
                                                          episode.id ?? 0,
                                                      type: 'video')),
                                            );
                                },
                                child: ListTile(
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.orange.withOpacity(0.8),
                                    ),
                                    child: const Icon(
                                      Icons.video_collection_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    episode.name ?? '',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    episode.audioDuration ?? '',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.7)),
                                  ),
                                  trailing: episode.isPurchased??false
                                      ? IconButton(
                                          icon: const Icon(
                                              Icons.play_circle_fill,
                                              color: Colors.orange,
                                              size: 32),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              NavigationConstants.videoPlayer,
                                              arguments: {
                                                "name": episode.name,
                                                'image': episode.image,
                                                "title": episode.description
                                              },
                                            );
                                          },
                                        )
                                      : IconButton(
                                          onPressed: () async {
                                            bool? isLocal = HivePrefs.getBool('isLocal');

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => PaymentPage(
                                                      isCategory: false,
                                                      phone: 'phone',
                                                      price: isLocal??false
                                                          ? int.parse(episode
                                                                  .priceInLocal ??
                                                              '0')
                                                          : int.parse(episode
                                                                  .priceInForeign ??
                                                              '0'),
                                                      productId:
                                                          episode.id ?? 0,
                                                      type: 'video')),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.download_for_offline,
                                            color: Colors.lightGreen,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
     
    );
  }
}
