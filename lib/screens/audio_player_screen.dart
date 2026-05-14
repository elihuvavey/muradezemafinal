import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:muradezema/commons/custom_text.dart';
import 'package:provider/provider.dart';

import '../commons/custom_bottom_nav.dart';
import '../commons/mini_audio_player.dart';
import '../provider/audio_manager.dart';
import '../provider/related_audio_provider.dart';
import '../utils/nav_constants.dart';
import '../provider/favorite_provider.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  final Duration _position = Duration.zero;
  bool isPlaying = false;
  int _currentIndex = 3;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String audioUrl = '';

  @override
  void initState() {
    super.initState();
    _initializeAudioHandler();
    setAudio();
  }

  Future<void> _initializeAudioHandler() async {
    // audioHandler = await AudioService.init(
    //   builder: () => MyAudioHandler(),
    //   config: const AudioServiceConfig(
    //     androidNotificationChannelId: 'com.example.audio',
    //     androidNotificationChannelName: 'Audio Playback',
    //     androidNotificationOngoing: true,
    //   ),
    // );
    setState(() {}); // Ensure UI updates after initializing the handler
  }

//  Future<void> _initAudio(String url) async {
//     try {
//       await _audioPlayer.setUrl(url);
//       _duration = _audioPlayer.duration ?? Duration.zero;
//       setState(() {});
//     } catch (e) {
//       print("Error loading audio: $e");
//     }
//   }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> setAudio() async {
    try {
      await _audioPlayer.setUrl(audioUrl);
      _duration = _audioPlayer.duration ?? Duration.zero;
      setState(() {});
    } catch (e) {
      debugPrint('Error setting audio URL: $e');
    }
  }

  String? auido;

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    String name = arguments?['name'];
    String image = arguments?['image'];
    String title = arguments?['title'];
    audioUrl = arguments?['audio'];
    final provider = Provider.of<RelatedAudioProvider>(context, listen: false);
    if (provider.isLoading) {
      provider.fetchRelatedAudios(arguments?['id']);
    }

    final audioManager = Provider.of<AudioManager>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF141414), Color(0xFF1C1C1E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20, bottom: 10, top: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Playing from Audio Book',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                              width: 48), // Balance the back button width
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Title or Speaker name
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white70, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      // Album Artwork
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          image,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: LoadingAnimationWidget.inkDrop(
                                color: Colors.orange,
                                size: 20.h,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.broken_image,
                              size: 250,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Track Title and Artist
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                      ),
                      Text(
                        name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 24),
                      // Playback Slider and Time
                      Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.orangeAccent,
                              inactiveTrackColor: Colors.white30,
                              thumbColor: Colors.orangeAccent,
                              overlayColor:
                                  Colors.orangeAccent.withOpacity(0.2),
                              trackHeight: 3,
                            ),
                            child: Slider(
                              value: _position.inSeconds.toDouble(),
                              min: 0,
                              max: _duration.inSeconds.toDouble() > 0
                                  ? _duration.inSeconds.toDouble()
                                  : 1,
                              onChanged: (value) {
                                setState(() {
                                  _audioPlayer
                                      .seek(Duration(seconds: value.toInt()));
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(_position),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  _formatDuration(_duration),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Player Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(
                              Provider.of<FavoriteProvider>(context).isFavorite(
                                      'audio',
                                      arguments?['id']?.toString() ?? '')
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                            color: Colors.white70,
                            iconSize: 28,
                            onPressed: () {
                              if (arguments?['id'] != null) {
                                Provider.of<FavoriteProvider>(context,
                                        listen: false)
                                    .toggleFavorite(
                                  isPurchased: false,
                                  'audio',
                                  arguments!['id'].toString(),
                                  title: title,
                                  description: arguments?['description'] ?? '',
                                  image: image,
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_previous),
                            color: Colors.white,
                            iconSize: 32,
                            onPressed: () {
                              // Handle skip previous action
                            },
                          ),
                          // Play/Pause Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                              backgroundColor: Colors.orangeAccent,
                            ),
                            onPressed: () async {
                              if (isPlaying) {
                                await _audioPlayer.pause();
                              } else {
                                audioManager.playAudio(audioUrl, title, image);

                                // await _audioPlayer.play();
                              }
                            },
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next),
                            color: Colors.white,
                            iconSize: 32,
                            onPressed: () {
                              // Handle skip next action
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            color: Colors.white70,
                            iconSize: 28,
                            onPressed: () {},
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          Text(
                            'Related Audios',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Consumer<RelatedAudioProvider>(
                            builder: (context, relatedAudioProvider, child) {
                              final audios = relatedAudioProvider.relatedAudios;

                              if (audios.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No related audios found.',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: audios.length,
                                itemBuilder: (context, index) {
                                  final audio = audios[index];

                                  return GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2A2A2E),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              audio.image ?? '',
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: Colors.grey[800],
                                                  child: const Icon(
                                                      Icons.music_note,
                                                      color: Colors.white54),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  audio.name ?? 'Untitled',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  audio.description ?? '',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.play_arrow,
                                              color: Colors.white70),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayer(),
          ), // Mini player always visible
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
    );
  }
}
