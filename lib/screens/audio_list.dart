import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:muradezema/commons/custom_images.dart';
import 'package:muradezema/screens/audio/player_task.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:ui';
import 'dart:math';
import '../main.dart';
import '../provider/episode_provider.dart';
import '../provider/favorite_provider.dart';
import '../provider/purchase_provider.dart';
import '../utils/location_utils.dart';
import '../utils/nav_constants.dart';
import 'package:marquee/marquee.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/user_prefs.dart';
import 'payment_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ArtistAudioListScreen extends StatefulWidget {
  const ArtistAudioListScreen({super.key});

  @override
  State<ArtistAudioListScreen> createState() => _ArtistAudioListScreenState();
}

class _ArtistAudioListScreenState extends State<ArtistAudioListScreen> {
  int? _seasonId;
  final PanelController _panelController = PanelController();
  int currentIndex = 0;
  bool isRepeat = false;
  bool isShuffle = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Listen to playback state changes to handle song completion
    audioHandler.playbackState.listen((playbackState) {
      if (playbackState.processingState == AudioProcessingState.completed) {
        playNextSong();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int newSeasonId = args['id'];
    if (_seasonId != newSeasonId) {
      _seasonId = newSeasonId;
      Provider.of<SeasonEpisodeProvider>(context, listen: false)
          .loadSongs(_seasonId.toString());
    }
  }

  Future<void> playNextSong() async {
    final seasonEpisodeProvider =
        Provider.of<SeasonEpisodeProvider>(context, listen: false);
    final purchasedIds = HivePrefs.getStringList('purchased_audio_ids') ?? [];

    if (purchasedIds.isEmpty) return;

    debugPrint('Playing next song...');
    debugPrint('Current index: $currentIndex');
    debugPrint('Shuffle mode: $isShuffle');
    debugPrint('Repeat mode: $isRepeat');

    if (isShuffle) {
      // Get a random index different from current
      int nextIndex;
      do {
        nextIndex = _random.nextInt(purchasedIds.length);
      } while (nextIndex == currentIndex && purchasedIds.length > 1);

      final nextId = int.parse(purchasedIds[nextIndex]);
      debugPrint('Shuffle mode - Selected ID: $nextId');

      final nextSong = seasonEpisodeProvider.songs.firstWhere(
        (song) => song.id == nextId,
        orElse: () => seasonEpisodeProvider.songs[0],
      );
      currentIndex = seasonEpisodeProvider.songs.indexOf(nextSong);
      await playSong(nextSong);
    } else {
      // Find current song's index in purchased list
      final currentSongId =
          seasonEpisodeProvider.songs[currentIndex].id.toString();
      final currentPurchasedIndex = purchasedIds.indexOf(currentSongId);
      debugPrint('Current purchased index: $currentPurchasedIndex');

      if (currentPurchasedIndex < purchasedIds.length - 1) {
        // Play next purchased song
        final nextId = int.parse(purchasedIds[currentPurchasedIndex + 1]);
        debugPrint('Playing next song with ID: $nextId');

        final nextSong = seasonEpisodeProvider.songs.firstWhere(
          (song) => song.id == nextId,
          orElse: () => seasonEpisodeProvider.songs[0],
        );
        currentIndex = seasonEpisodeProvider.songs.indexOf(nextSong);
        await playSong(nextSong);
      } else if (isRepeat) {
        // Start from beginning if repeat is on
        final nextId = int.parse(purchasedIds[0]);
        debugPrint('Repeat mode - Playing first song with ID: $nextId');

        final nextSong = seasonEpisodeProvider.songs.firstWhere(
          (song) => song.id == nextId,
          orElse: () => seasonEpisodeProvider.songs[0],
        );
        currentIndex = seasonEpisodeProvider.songs.indexOf(nextSong);
        await playSong(nextSong);
      }
    }
  }

  Future<void> playPreviousSong() async {
    final seasonEpisodeProvider =
        Provider.of<SeasonEpisodeProvider>(context, listen: false);
    final purchasedIds = HivePrefs.getStringList('purchased_audio_ids') ?? [];

    if (purchasedIds.isEmpty) {
      debugPrint('No purchased IDs found');
      return;
    }

    debugPrint('Playing previous song...');
    debugPrint('Current index: $currentIndex');
    debugPrint('Shuffle mode: $isShuffle');
    debugPrint('Repeat mode: $isRepeat');

    if (isShuffle) {
      // Get a random index different from current
      int prevIndex;
      do {
        prevIndex = _random.nextInt(purchasedIds.length);
      } while (prevIndex == currentIndex && purchasedIds.length > 1);

      final prevId = int.parse(purchasedIds[prevIndex]);
      debugPrint('Shuffle mode - Selected ID: $prevId');

      final prevSong = seasonEpisodeProvider.songs.firstWhere(
        (song) => song.id == prevId,
        orElse: () => seasonEpisodeProvider.songs[0],
      );
      currentIndex = seasonEpisodeProvider.songs.indexOf(prevSong);
      await playSong(prevSong);
    } else {
      // Get current song
      if (currentIndex >= seasonEpisodeProvider.songs.length) {
        currentIndex = 0;
      }
      final currentSong = seasonEpisodeProvider.songs[currentIndex];
      final currentSongId = currentSong.id.toString();
      debugPrint('Current song ID: $currentSongId');

      // Find the index in purchased list
      final currentPurchasedIndex = purchasedIds.indexOf(currentSongId);
      debugPrint('Current purchased index: $currentPurchasedIndex');

      if (currentPurchasedIndex > 0) {
        // Play previous purchased song
        final prevId = int.parse(purchasedIds[currentPurchasedIndex - 1]);
        debugPrint('Playing previous song with ID: $prevId');

        final prevSong = seasonEpisodeProvider.songs.firstWhere(
          (song) => song.id == prevId,
          orElse: () => seasonEpisodeProvider.songs[0],
        );
        currentIndex = seasonEpisodeProvider.songs.indexOf(prevSong);
        await playSong(prevSong);
      } else if (isRepeat) {
        // Go to last song if repeat is on
        final prevId = int.parse(purchasedIds[purchasedIds.length - 1]);
        debugPrint('Repeat mode - Playing last song with ID: $prevId');

        final prevSong = seasonEpisodeProvider.songs.firstWhere(
          (song) => song.id == prevId,
          orElse: () => seasonEpisodeProvider.songs[0],
        );
        currentIndex = seasonEpisodeProvider.songs.indexOf(prevSong);
        await playSong(prevSong);
      }
    }
  }

  Future<void> playSong(dynamic episode) async {
    debugPrint('Attempting to play song: ${episode.title}');
    final Dio dio = Dio();
    try {
      debugPrint('Fetching audio URL from API...');
      final response = await dio.post(
        "${dotenv.env['BASE_URL']}/audio/episodes/${episode.id}/play",
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${HivePrefs.getString('token')}',
          },
        ),
      );

      debugPrint('API Response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final audioUrl = response.data['audio'];
        debugPrint('Received audio URL: $audioUrl');

        if (audioUrl != null && audioUrl.isNotEmpty) {
          // Validate audio URL format
          if (!audioUrl.startsWith('http')) {
            throw Exception('Invalid audio URL format: $audioUrl');
          }

          // Check if the file is accessible and get its content type
          try {
            debugPrint('Checking audio file accessibility...');
            final headResponse = await dio.head(audioUrl);
            final contentType = headResponse.headers.value('content-type');
            debugPrint('Content-Type: $contentType');

            if (headResponse.statusCode != 200) {
              throw Exception(
                  'Audio file not accessible. Status code: ${headResponse.statusCode}');
            }

            // Validate content type
            if (contentType == null ||
                (!contentType.contains('audio/') &&
                    !contentType.contains('video/'))) {
              throw Exception('Invalid content type: $contentType');
            }

            final parts = episode.duration?.split(":") ?? ['0', '0'];
            final minutes = int.tryParse(parts[0]) ?? 0;
            final seconds = int.tryParse(parts[1]) ?? 0;
            final duration = Duration(minutes: minutes, seconds: seconds);

            debugPrint('Loading media item into player...');
            await (audioHandler as AudioPlayerHandler).loadMediaItem(
              id: audioUrl,
              title: episode.title ?? '',
              album: episode.description ?? '',
              artist: episode.artistName ?? '',
              artUri: Uri.parse(artistImage),
              duration: duration,
            );

            debugPrint('Starting playback...');
            await audioHandler.play();
            debugPrint('Playback started successfully');
          } catch (e, stackTrace) {
            debugPrint('Error playing audio: $e');
            debugPrint('Stack trace: $stackTrace');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Unable to play audio: ${e.toString()}'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          throw Exception('Audio URL is empty');
        }
      } else {
        throw Exception(
            'Failed to get audio URL. Status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching audio: $e');
      debugPrint('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  bool isBought = false;

  // Combine streams for media state (mediaItem, position, duration)
  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest3<MediaItem?, Duration, Duration?, MediaState>(
        audioHandler.mediaItem,
        (audioHandler as AudioPlayerHandler).positionStream,
        (audioHandler as AudioPlayerHandler).durationStream,
        (mediaItem, position, duration) =>
            MediaState(mediaItem, position, duration),
      );

  // Mini player widget
  Widget _buildMiniPlayer() {
    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        if (mediaItem == null) {
          return Container(
            color: Colors.black87,
            child: Center(
              child: Text(
                'No track playing',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }
        return Container(
          color: Colors.black87,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Art + title/artist
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  mediaItem.artUri?.toString() ?? '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.music_note, color: Colors.white, size: 50),
                ),
              ),
              SizedBox(width: 12),
              // Title + Artist
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.5),
                      child: LayoutBuilder(builder: (ctx, constraints) {
                        final painter = TextPainter(
                          text: TextSpan(
                              text: mediaItem.title,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14)),
                          maxLines: 1,
                          textDirection: TextDirection.ltr,
                        )..layout(maxWidth: constraints.maxWidth);
                        final isOverflow = painter.didExceedMaxLines;
                        if (isOverflow) {
                          return SizedBox(
                            height: 20,
                            child: Marquee(
                              text: mediaItem.title,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                              velocity: 30.0,
                              blankSpace: 40.0,
                            ),
                          );
                        } else {
                          return Text(mediaItem.title,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis);
                        }
                      }),
                    ),
                    SizedBox(height: 2),
                    // Artist
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.5),
                      child: LayoutBuilder(builder: (ctx, constraints) {
                        final painter = TextPainter(
                          text: TextSpan(
                              text: mediaItem.artist ?? '',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          maxLines: 1,
                          textDirection: TextDirection.ltr,
                        )..layout(maxWidth: constraints.maxWidth);
                        final isOverflow = painter.didExceedMaxLines;
                        if (isOverflow) {
                          return SizedBox(
                            height: 18,
                            child: Marquee(
                              text: mediaItem.artist ?? '',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                              velocity: 25.0,
                              blankSpace: 30.0,
                            ),
                          );
                        } else {
                          return Text(mediaItem.artist ?? '',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis);
                        }
                      }),
                    ),
                  ],
                ),
              ),

              // Play/Pause button
              StreamBuilder<bool>(
                stream:
                    audioHandler.playbackState.map((s) => s.playing).distinct(),
                builder: (context, snap) {
                  final playing = snap.data ?? false;
                  return IconButton(
                    icon: Icon(playing ? Icons.pause : Icons.play_arrow,
                        color: Colors.white),
                    onPressed: () =>
                        playing ? audioHandler.pause() : audioHandler.play(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool isFavorite = false;

  void shareSong(String title, String url) {
    final message = '🎵 $title\nDownload from this link:\n$url';
    Share.share(message);
  }

  Widget _buildExpandedPlayer() {
    return StreamBuilder<MediaState>(
        stream: _mediaStateStream,
        builder: (context, snapshot) {
          final mediaState = snapshot.data;
          final mediaItem = mediaState?.mediaItem;
          if (mediaItem == null) {
            return Center(
              child: Text(
                'No track selected',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return Stack(
            children: [
              Positioned.fill(
                child: CustomNetworkImageView(
                  imageUrl: artistImage,
                  fallbackImageUrl:
                      'https://yt3.googleusercontent.com/c1__fQjiBX3tYvE5cfrp2SeK3EnybEvA-qjesXv3Rv-RrwMp7jm4yKxEamHNIELN3WDjlLut=s900-c-k-c0x00ffffff-no-rj',
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(color: Colors.black.withOpacity(0.6)),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.keyboard_arrow_down, color: Colors.white),
                          Text('Now Playing',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Provider.of<FavoriteProvider>(context,
                                          listen: false)
                                      .toggleFavorite(
                                    isPurchased: false,
                                    'audio',
                                    mediaItem.id,
                                    title: mediaItem.title,
                                    description: mediaItem.album ?? '',
                                    image: mediaItem.artUri?.toString() ?? '',
                                  );
                                },
                                icon: Icon(
                                  Provider.of<FavoriteProvider>(context)
                                          .isFavorite('audio', mediaItem.id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Provider.of<FavoriteProvider>(context)
                                          .isFavorite('audio', mediaItem.id)
                                      ? Colors.orange
                                      : Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  shareSong('Murade Zema',
                                      'https://play.google.com/store/apps/details?id=com.app.muradezema');
                                },
                                icon: Icon(Icons.share, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomNetworkImageView(
                                width: 240.h,
                                height: 240.h,
                                fit: BoxFit.cover,
                                imageUrl: artistImage,
                                fallbackImageUrl:
                                    'https://yt3.googleusercontent.com/c1__fQjiBX3tYvE5cfrp2SeK3EnybEvA-qjesXv3Rv-RrwMp7jm4yKxEamHNIELN3WDjlLut=s900-c-k-c0x00ffffff-no-rj',
                              ),
                              // Container(
                              //   width: 300,
                              //   height: 300,
                              //   color: Colors.black.withOpacity(0.4),
                              //   alignment: Alignment.center,
                              //   child: Text(
                              //     "Ali Bira",
                              //     textAlign: TextAlign.center,
                              //     style: TextStyle(
                              //       color: Colors.white,
                              //       fontSize: 20,
                              //       fontWeight: FontWeight.bold,
                              //       shadows: [
                              //         Shadow(
                              //             blurRadius: 4,
                              //             color: Colors.black54,
                              //             offset: Offset(1, 1)),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Title
                          LayoutBuilder(builder: (ctx, constraints) {
                            // measure
                            final painter = TextPainter(
                              text: TextSpan(
                                text: mediaItem.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              maxLines: 1,
                              textDirection: TextDirection.ltr,
                            )..layout(maxWidth: constraints.maxWidth);

                            if (painter.didExceedMaxLines) {
                              // overflow → marquee
                              return SizedBox(
                                height: 30, // enough for one line of 24pt text
                                child: Marquee(
                                  text: mediaItem.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  velocity: 30.0,
                                  blankSpace: 60.0,
                                ),
                              );
                            } else {
                              // fits → normal text
                              return Text(
                                mediaItem.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            }
                          }),
                          SizedBox(height: 4),

                          // Artist / Description
                          LayoutBuilder(builder: (ctx, constraints) {
                            final artist = mediaItem.artist ?? 'N/A';
                            final painter = TextPainter(
                              text: TextSpan(
                                text: artist,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              maxLines: 1,
                              textDirection: TextDirection.ltr,
                            )..layout(maxWidth: constraints.maxWidth);

                            if (painter.didExceedMaxLines) {
                              return SizedBox(
                                height: 22, // enough for one line of 16pt text
                                child: Marquee(
                                  text: artist,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                  velocity: 25.0,
                                  blankSpace: 40.0,
                                ),
                              );
                            } else {
                              return Text(
                                artist,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            }
                          }),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: StreamBuilder<MediaState>(
                        stream: _mediaStateStream,
                        builder: (context, snapshot) {
                          final mediaState = snapshot.data;
                          final position =
                              mediaState?.position ?? Duration.zero;
                          final duration =
                              mediaState?.duration ?? Duration.zero;

                          String format(Duration d) {
                            twoDigits(int n) => n.toString().padLeft(2, '0');
                            final minutes =
                                twoDigits(d.inMinutes.remainder(60));
                            final seconds =
                                twoDigits(d.inSeconds.remainder(60));
                            return '$minutes:$seconds';
                          }

                          return Row(
                            children: [
                              // Current position
                              Text(
                                format(position),
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),

                              // Seek bar expands to fill
                              Expanded(
                                child: SeekBar(
                                  duration: duration,
                                  position: position,
                                  onChanged: (position) {
                                    // This is optional - for UI updates while dragging
                                  },
                                  onChangeEnd: (position) {
                                    audioHandler.seek(position);
                                  },
                                ),
                              ),

                              // Total duration
                              Text(
                                format(duration),
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 32),
                      child: StreamBuilder<bool>(
                        stream: audioHandler.playbackState
                            .map((s) => s.playing)
                            .distinct(),
                        builder: (context, snapshot) {
                          final playing = snapshot.data ?? false;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _controlButton(Icons.shuffle, () {
                                toggleShuffle();
                              }, size: 22, active: isShuffle),
                              _controlButton(
                                  Icons.skip_previous_rounded, playPreviousSong,
                                  size: 22),
                              _controlButton(
                                playing
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                                () => playing
                                    ? audioHandler.pause()
                                    : audioHandler.play(),
                                active: true,
                                size: 44,
                              ),
                              _controlButton(
                                  Icons.skip_next_rounded, playNextSong,
                                  size: 22),
                              _controlButton(Icons.repeat, () {
                                toggleRepeat();
                              }, size: 22, active: isRepeat),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget _controlButton(IconData icon, VoidCallback onTap,
      {bool active = false, double size = 34}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon,
          color: active ? Colors.orangeAccent : Colors.white, size: size),
    );
  }

  String artistName = '';
  String artistImage = '';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    artistName = args['artistName'];
    artistImage = args['artistImage'];
    final seasonEpisodeProvider = Provider.of<SeasonEpisodeProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 80,
        maxHeight: MediaQuery.of(context).size.height,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        collapsed: _buildMiniPlayer(),
        panel: _buildExpandedPlayer(),
        body: Column(
          children: [
            SizedBox(height: 40.h),
            Text(
              artistName,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
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
                  width: 150.w,
                  height: 150.h,
                  fit: BoxFit.cover,
                  fallbackImageUrl:
                      'https://yt3.googleusercontent.com/c1__fQjiBX3tYvE5cfrp2SeK3EnybEvA-qjesXv3Rv-RrwMp7jm4yKxEamHNIELN3WDjlLut=s900-c-k-c0x00ffffff-no-rj',
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Top Tracks",
              style: TextStyle(
                  color: Colors.orange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: seasonEpisodeProvider.isLoading
                  ? Center(
                      child: LoadingAnimationWidget.inkDrop(
                          color: Colors.orange, size: 30))
                  : seasonEpisodeProvider.error != null
                      ? Center(
                          child: Text(seasonEpisodeProvider.error!,
                              style: TextStyle(color: Colors.white)))
                      : ListView.builder(
                          itemCount: seasonEpisodeProvider.songs.length,
                          itemBuilder: (context, index) {
                            final episode = seasonEpisodeProvider.songs[index];
                            return StreamBuilder<MediaItem?>(
                              stream: audioHandler.mediaItem,
                              builder: (context, snapshot) {
                                final mediaItem = snapshot.data;
                                final isPlaying =
                                    mediaItem?.extras?['episodeId'] ==
                                        episode.id.toString();
                                return InkWell(
                                  onTap: () async {
                                    if (episode.isPurchased == true) {
                                      currentIndex = index;
                                      await playSong(episode);
                                      _panelController.open();
                                    } else {
                                      bool? isLocal =
                                          HivePrefs.getBool('isLocal');

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PaymentPage(
                                                isCategory: false,
                                                phone: 'phone',
                                                price: isLocal ?? false
                                                    ? int.parse(
                                                        episode.priceInLocal ??
                                                            '0')
                                                    : int.parse(episode
                                                            .priceInForeign ??
                                                        '0'),
                                                productId: episode.id ?? 0,
                                                type: 'audio')),
                                      );
                                    }
                                  },
                                  child: ListTile(
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.orange.withOpacity(0.8),
                                      ),
                                      child: const Icon(Icons.music_note,
                                          color: Colors.white),
                                    ),
                                    title: Text(
                                      episode.title ?? '',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      episode.duration ?? '',
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.7)),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Provider.of<FavoriteProvider>(
                                                        context)
                                                    .isFavorite('audio',
                                                        episode.id.toString())
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color:
                                                Provider.of<FavoriteProvider>(
                                                            context)
                                                        .isFavorite(
                                                            'audio',
                                                            episode.id
                                                                .toString())
                                                    ? Colors.orange
                                                    : Colors.white,
                                          ),
                                          onPressed: () async {
                                            Provider.of<FavoriteProvider>(
                                                    context,
                                                    listen: false)
                                                .toggleFavorite(
                                              isPurchased: episode.isPurchased ?? false,
                                              'audio',
                                              episode.id.toString(),
                                              title: episode.title ?? '',
                                              description:
                                                  episode.description ?? '',
                                              image: artistImage,
                                            );
                                          },
                                        ),
                                        isPlaying
                                            ? Icon(Icons.play_arrow,
                                                color: Colors.orange)
                                            : episode.isPurchased ?? false
                                                ? IconButton(
                                                    icon: const Icon(
                                                        Icons.play_circle_fill,
                                                        color: Colors.orange,
                                                        size: 32),
                                                    onPressed: () async {
                                                      currentIndex = index;
                                                      await playSong(episode);
                                                      _panelController.open();
                                                    },
                                                  )
                                                : IconButton(
                                                    onPressed: () async {
                                                      bool? isLocal =
                                                          HivePrefs.getBool(
                                                              'isLocal');
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => PaymentPage(
                                                                isCategory:
                                                                    false,
                                                                phone: 'phone',
                                                                price: isLocal ??
                                                                        false
                                                                    ? int.parse(
                                                                        episode.priceInLocal ??
                                                                            '0')
                                                                    : int.parse(
                                                                        episode.priceInForeign ??
                                                                            '0'),
                                                                productId:
                                                                    episode.id ??
                                                                        0,
                                                                type: 'audio')),
                                                      );
                                                    },
                                                    icon: Icon(
                                                        Icons
                                                            .download_for_offline,
                                                        color:
                                                            Colors.lightGreen),
                                                  ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> toggleShuffle() async {
    setState(() {
      isShuffle = !isShuffle;
      if (isShuffle) {
        isRepeat = false; // Disable repeat when shuffle is enabled
      }
    });
    await (audioHandler as AudioPlayerHandler).setShuffleMode(
      isShuffle ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    );
  }

  Future<void> toggleRepeat() async {
    setState(() {
      isRepeat = !isRepeat;
      if (isRepeat) {
        isShuffle = false; // Disable shuffle when repeat is enabled
      }
    });
    await (audioHandler as AudioPlayerHandler).setRepeatMode(
      isRepeat ? AudioServiceRepeatMode.all : AudioServiceRepeatMode.none,
    );
  }
}

// MediaState class for combining streams
class MediaState {
  final MediaItem? mediaItem;
  final Duration position;
  final Duration? duration;

  MediaState(this.mediaItem, this.position, this.duration);
}

// SeekBar widget (assumed to be unchanged from MainScreen)
class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration>? onChangeEnd;
  final ValueChanged<Duration>? onChanged;

  const SeekBar({
    super.key,
    required this.duration,
    required this.position,
    this.onChangeEnd,
    this.onChanged,
  });

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;
  late SliderThemeData _sliderThemeData;

  @override
  void initState() {
    super.initState();
    _sliderThemeData = SliderThemeData(
      trackHeight: 4.0,
      activeTrackColor: Colors.orange,
      inactiveTrackColor: Colors.white24,
      thumbColor: Colors.orange,
      overlayColor: Colors.orange.withOpacity(0.2),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = _dragValue ?? widget.position.inSeconds.toDouble();
    return SliderTheme(
      data: _sliderThemeData,
      child: Slider(
        value: value.clamp(0.0, widget.duration.inSeconds.toDouble()),
        max: widget.duration.inSeconds.toDouble(),
        onChanged: (value) {
          setState(() {
            _dragValue = value;
          });
          // Only update UI while dragging
          widget.onChanged?.call(Duration(seconds: value.toInt()));
        },
        onChangeEnd: (value) {
          setState(() {
            _dragValue = null;
          });
          // Actually seek the audio when drag ends
          widget.onChangeEnd?.call(Duration(seconds: value.toInt()));
        },
      ),
    );
  }
}
