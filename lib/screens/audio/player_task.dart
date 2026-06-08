import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'dart:convert';
import 'package:muradezema/utils/dio_client.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:marquee/marquee.dart';
import 'package:muradezema/commons/custom_images.dart';
import 'package:rxdart/rxdart.dart';
import 'package:muradezema/main.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import '../../utils/user_prefs.dart';
import '../../provider/favorite_provider.dart';

class MainScreen extends StatefulWidget {
  final String id;
  final String title;
  final String album;
  final String artist;
  final Uri artUri;
  final Duration duration;
  final String? description;
  final bool? isFromNotification;

  const MainScreen(
      {super.key,
      required this.id,
      required this.title,
      required this.album,
      required this.artist,
      required this.artUri,
      required this.duration,
      this.description,
      this.isFromNotification});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class SeekBar extends StatelessWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    Key? key,
    required this.duration,
    required this.position,
    this.onChangeEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slider(
      activeColor: Colors.orange,
      inactiveColor: Colors.white24,
      value: position.inSeconds
          .toDouble()
          .clamp(0.0, duration.inSeconds.toDouble()),
      max: duration.inSeconds.toDouble(),
      onChanged: (value) {},
      onChangeEnd: (value) =>
          onChangeEnd?.call(Duration(seconds: value.toInt())),
    );
  }
}

class _MainScreenState extends State<MainScreen> {
  bool _loaded = false;
  bool isFavorite = false;
  bool _isRepeat = false;
  bool _isShuffle = false;
  int _currentIndex = 0;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _loadTrack();
  }

  Future<void> _loadTrack() async {
    if (widget.isFromNotification ?? false == true) {
      setState(() => _loaded = true);
      return;
    }

    await (audioHandler as AudioPlayerHandler).loadMediaItem(
      id: widget.id,
      title: widget.title,
      album: widget.album,
      artist: widget.artist,
      artUri: widget.artUri,
      duration: widget.duration,
      description: widget.description,
    );
    setState(() => _loaded = true);

    HivePrefs.saveString("title", widget.title);
    HivePrefs.saveString("description", widget.description ?? '');
  }

  Future<void> _playSong(dynamic song) async {
    // Implement song playing logic here
    await audioHandler.playMediaItem(song);
  }

  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest3<MediaItem?, Duration, Duration?, MediaState>(
        audioHandler.mediaItem,
        (audioHandler as AudioPlayerHandler).positionStream,
        (audioHandler as AudioPlayerHandler).durationStream,
        (mediaItem, position, duration) =>
            MediaState(mediaItem, position, duration),
      );

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
                  imageUrl: mediaItem.artUri.toString(),
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
                    _buildHeader(),
                    _buildAlbumArt(),
                    _buildTrackInfo(mediaItem),
                    _buildSeekBar(),
                    _buildControls(),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Text('Now Playing',
              style: TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.bold)),
          Row(
            children: [
              StreamBuilder<MediaItem?>(
                stream: audioHandler.mediaItem,
                builder: (context, snapshot) {
                  final mediaItem = snapshot.data;
                  if (mediaItem == null) return SizedBox.shrink();

                  final isFavorite = Provider.of<FavoriteProvider>(context)
                      .isFavorite('audio', mediaItem.id);

                  return IconButton(
                    onPressed: () {
                      Provider.of<FavoriteProvider>(context, listen: false)
                          .toggleFavorite(
                        isPurchased: true,
                        'audio',
                        mediaItem.id,
                        title: mediaItem.title,
                        description: mediaItem.album ?? '',
                        image: mediaItem.artUri?.toString() ?? '',
                      );
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.orange : Colors.white,
                      size: 28,
                    ),
                  );
                },
              ),
              StreamBuilder<MediaItem?>(
                stream: audioHandler.mediaItem,
                builder: (context, snapshot) {
                  final mediaItem = snapshot.data;
                  if (mediaItem == null) return SizedBox.shrink();

                  return IconButton(
                    onPressed: () async {
                      await Share.share(
                        '🎵 ${mediaItem.title}\n${mediaItem.artist ?? ''}\n\nListen to this track on Muradezema! Download link https://play.google.com/store/apps/details?id=com.app.muradezema',
                      );
                    },
                    icon: Icon(Icons.share, color: Colors.white),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Expanded(
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
                imageUrl: '',
                fallbackImageUrl:
                    'https://yt3.googleusercontent.com/c1__fQjiBX3tYvE5cfrp2SeK3EnybEvA-qjesXv3Rv-RrwMp7jm4yKxEamHNIELN3WDjlLut=s900-c-k-c0x00ffffff-no-rj',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackInfo(MediaItem mediaItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildScrollingText(
            text: mediaItem.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          _buildScrollingText(
            text: mediaItem.artist ?? 'N/A',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollingText({
    required String text,
    required TextStyle style,
  }) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        if (painter.didExceedMaxLines) {
          return SizedBox(
            height: style.fontSize! * 1.2,
            child: Marquee(
              text: text,
              style: style,
              velocity: 30.0,
              blankSpace: 60.0,
            ),
          );
        }

        return Text(
          text,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  Widget _buildSeekBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<MediaState>(
        stream: _mediaStateStream,
        builder: (context, snapshot) {
          final mediaState = snapshot.data;
          final position = mediaState?.position ?? Duration.zero;
          final duration = mediaState?.duration ?? Duration.zero;

          return Row(
            children: [
              Text(
                _formatDuration(position),
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Expanded(
                child: SeekBar(
                  duration: duration,
                  position: position,
                  onChangeEnd: audioHandler.seek,
                ),
              ),
              Text(
                _formatDuration(duration),
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 32),
      child: StreamBuilder<PlaybackState>(
        stream: audioHandler.playbackState,
        builder: (context, snapshot) {
          final playing = snapshot.data?.playing ?? false;
          final purchasedIds =
              HivePrefs.getStringList('purchased_audio_ids') ?? [];

          if (purchasedIds.isEmpty) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _controlButton(Icons.shuffle, () {}, active: false, size: 22),
                _controlButton(Icons.skip_previous_rounded, () {},
                    size: 22, active: false),
                _controlButton(
                  playing ? Icons.pause_circle : Icons.play_circle,
                  () => playing ? audioHandler.pause() : audioHandler.play(),
                  active: true,
                  size: 44,
                ),
                _controlButton(Icons.skip_next_rounded, () {},
                    size: 22, active: false),
                _controlButton(Icons.repeat, () {}, active: false, size: 22),
              ],
            );
          }

          // Check if there's a previous song available
          bool hasPreviousSong = false;
          if (!_isShuffle && purchasedIds.isNotEmpty) {
            final queue = (audioHandler as AudioPlayerHandler).queue.value;
            final currentIndex = snapshot.data?.queueIndex ?? 0;
            final currentSongId =
                queue.isNotEmpty && currentIndex < queue.length
                    ? queue[currentIndex].id
                    : '';
            final currentPurchasedIndex = purchasedIds.indexOf(currentSongId);
            hasPreviousSong = currentPurchasedIndex > 0 || _isRepeat;
          } else if (_isShuffle && purchasedIds.isNotEmpty) {
            hasPreviousSong = true;
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _controlButton(Icons.shuffle, () {
                toggleShuffle();
              }, active: _isShuffle, size: 22),
              _controlButton(
                Icons.skip_previous_rounded,
                () async {
                  if (!hasPreviousSong) return;
                  await (audioHandler as AudioPlayerHandler).skipToPrevious();
                },
                size: 22,
                active: hasPreviousSong,
                disabledColor: Colors.grey,
              ),
              _controlButton(
                playing ? Icons.pause_circle : Icons.play_circle,
                () => playing ? audioHandler.pause() : audioHandler.play(),
                active: true,
                size: 44,
              ),
              _controlButton(
                Icons.skip_next_rounded,
                () async {
                  await (audioHandler as AudioPlayerHandler).skipToNext();
                },
                size: 22,
              ),
              _controlButton(Icons.repeat, () {
                toggleRepeat();
              }, active: _isRepeat, size: 22),
            ],
          );
        },
      ),
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onTap,
      {bool active = false, double size = 34, Color? disabledColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: active ? Colors.orangeAccent : (disabledColor ?? Colors.white),
        size: size,
      ),
    );
  }

  Future<void> toggleShuffle() async {
    if (!_isShuffle) {
      // If shuffle is being enabled, disable repeat first
      if (_isRepeat) {
        await (audioHandler as AudioPlayerHandler).setRepeatMode(
          AudioServiceRepeatMode.none,
        );
        _isRepeat = false;
      }

      await (audioHandler as AudioPlayerHandler).setShuffleMode(
        AudioServiceShuffleMode.all,
      );
      _isShuffle = true;
    } else {
      await (audioHandler as AudioPlayerHandler).setShuffleMode(
        AudioServiceShuffleMode.none,
      );
      _isShuffle = false;
    }
  }

  Future<void> toggleRepeat() async {
    if (!_isRepeat) {
      // If repeat is being enabled, disable shuffle first
      if (_isShuffle) {
        await (audioHandler as AudioPlayerHandler).setShuffleMode(
          AudioServiceShuffleMode.none,
        );
        _isShuffle = false;
      }

      await (audioHandler as AudioPlayerHandler).setRepeatMode(
        AudioServiceRepeatMode.all,
      );
      _isRepeat = true;
    } else {
      await (audioHandler as AudioPlayerHandler).setRepeatMode(
        AudioServiceRepeatMode.none,
      );
      _isRepeat = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.orangeAccent,
            size: 50.h,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: _buildExpandedPlayer(),
    );
  }
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;
  final Duration? duration;

  MediaState(this.mediaItem, this.position, this.duration);
}

class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  bool _isShuffle = false;
  bool _isRepeat = false;
  int _currentIndex = 0;
  List<MediaItem> _queue = [];
  final Random _random = Random();

  AudioPlayerHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handleSongCompletion();
      }
    });
  }

  void _handleSongCompletion() async {
    if (_isRepeat) {
      await _player.seek(Duration.zero);
      await _player.play();
    } else if (_isShuffle) {
      await skipToNext();
    } else if (_currentIndex < _queue.length - 1) {
      await skipToNext();
    }
  }

  Future<void> setShuffleMode(AudioServiceShuffleMode mode) async {
    if (_isShuffle == (mode == AudioServiceShuffleMode.all)) return;

    _isShuffle = mode == AudioServiceShuffleMode.all;
    if (_isShuffle) {
      _isRepeat = false;
    }

    // Use BehaviorSubject's value property to safely update state
    final currentState = playbackState.value;
    final newState = currentState.copyWith(
      shuffleMode: mode,
      repeatMode:
          _isRepeat ? AudioServiceRepeatMode.all : AudioServiceRepeatMode.none,
    );

    // Update the state synchronously
    playbackState.value = newState;
  }

  Future<void> setRepeatMode(AudioServiceRepeatMode mode) async {
    if (_isRepeat == (mode == AudioServiceRepeatMode.all)) return;

    _isRepeat = mode == AudioServiceRepeatMode.all;
    if (_isRepeat) {
      _isShuffle = false;
    }

    // Use BehaviorSubject's value property to safely update state
    final currentState = playbackState.value;
    final newState = currentState.copyWith(
      repeatMode: mode,
      shuffleMode: _isShuffle
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
    );

    // Update the state synchronously
    playbackState.value = newState;
  }

  @override
  Future<void> skipToNext() async {
    final purchasedIds = HivePrefs.getStringList('purchased_audio_ids') ?? [];
    if (purchasedIds.isEmpty) return;

    print('Purchased IDs: $purchasedIds');
    print('Current index: $_currentIndex');

    if (_isShuffle) {
      // Get a random ID that's different from the current one
      String nextId;
      String? currentId = _queue.isNotEmpty ? _queue[_currentIndex].id : null;
      do {
        nextId = purchasedIds[_random.nextInt(purchasedIds.length)];
      } while (nextId == currentId && purchasedIds.length > 1);

      print('Next shuffled song ID: $nextId');
      await _playNextItemById(nextId);
    } else {
      // Calculate next index
      int nextIndex = _currentIndex + 1;
      if (nextIndex >= purchasedIds.length) {
        if (_isRepeat) {
          nextIndex = 0;
        } else {
          return; // End of playlist
        }
      }

      final nextId = purchasedIds[nextIndex];
      print('Next song ID: $nextId (index: $nextIndex)');
      await _playNextItemById(nextId);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    final purchasedIds = HivePrefs.getStringList('purchased_audio_ids') ?? [];
    if (purchasedIds.isEmpty) return;

    print('Purchased IDs: $purchasedIds');
    print('Current index: $_currentIndex');

    if (_isShuffle) {
      // Get a random ID that's different from the current one
      String prevId;
      String? currentId = _queue.isNotEmpty ? _queue[_currentIndex].id : null;
      do {
        prevId = purchasedIds[_random.nextInt(purchasedIds.length)];
      } while (prevId == currentId && purchasedIds.length > 1);

      print('Previous shuffled song ID: $prevId');
      await _playNextItemById(prevId);
    } else {
      // Calculate previous index
      int prevIndex = _currentIndex - 1;
      if (prevIndex < 0) {
        if (_isRepeat) {
          prevIndex = purchasedIds.length - 1;
        } else {
          return; // Start of playlist
        }
      }

      final prevId = purchasedIds[prevIndex];
      print('Previous song ID: $prevId (index: $prevIndex)');
      await _playNextItemById(prevId);
    }
  }

  Future<void> _playNextItemById(String id) async {
    try {
      print('Playing next item with ID: $id');

      // Get the stored audio information
      final purchasedAudioInfo = HivePrefs.getString('purchased_audio_info');
      final purchasedIds = HivePrefs.getStringList('purchased_audio_ids') ?? [];

      if (purchasedAudioInfo != null && purchasedIds.isNotEmpty) {
        final List<dynamic> audioList = jsonDecode(purchasedAudioInfo);
        final audioInfo = audioList.firstWhere(
          (audio) => audio['id'] == id,
          orElse: () => null,
        );

        if (audioInfo != null) {
          // Update current index in the purchased list
          _currentIndex = purchasedIds.indexOf(id);
          print('Current index in purchased list: $_currentIndex');

          // Create a new MediaItem with the stored information
          final media = MediaItem(
            id: id,
            title: audioInfo['title'] ?? 'Loading...',
            album: audioInfo['description'] ?? 'Loading...',
            artist: audioInfo['description'] ?? 'Loading...',
            artUri: Uri.parse(
                audioInfo['image'] ?? 'https://example.com/default.jpg'),
            duration: Duration.zero,
          );

          // Update queue with current item before fetching audio URL
          _queue.clear();
          _queue.add(media);
          queue.add(_queue);

          // Fetch the audio URL from the API
          final Dio dio = createDio();
          try {
            print('Fetching audio URL for ID: $id');
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
              if (audioUrl != null && audioUrl.isNotEmpty) {
                print('Received audio URL: $audioUrl');

                final audioSource = AudioSource.uri(
                  Uri.parse(audioUrl),
                  tag: media,
                );

                // Set the audio source and update media item
                await _player.setAudioSource(
                  audioSource,
                  initialPosition: Duration.zero,
                  preload: true,
                );

                // Update media item and playback state after setting audio source
                mediaItem.add(media);
                playbackState.add(playbackState.value.copyWith(
                  queueIndex: _currentIndex,
                ));

                await _player.play();
              } else {
                print('Error: Audio URL is empty');
                throw Exception('Audio URL is empty');
              }
            } else {
              print(
                  'Error: API request failed with status ${response.statusCode}');
              throw Exception('API request failed');
            }
          } catch (e) {
            print('Error fetching audio URL: $e');
            rethrow;
          }
        } else {
          print('Error: Audio info not found for ID: $id');
          throw Exception('Audio info not found');
        }
      } else {
        print('Error: No purchased audio info found or empty purchased list');
        throw Exception(
            'No purchased audio info found or empty purchased list');
      }
    } catch (e) {
      print('Error playing track: $e');
    }
  }

  Future<void> loadMediaItem({
    required String id,
    required String title,
    required String album,
    required String artist,
    required Uri artUri,
    required Duration duration,
    String? description,
  }) async {
    print('Loading media item: $title');
    print('Audio URL: $id');

    final media = MediaItem(
      id: id,
      title: title,
      album: album,
      artist: artist,
      artUri: artUri,
      duration: duration,
      extras: {
        'description': description,
      },
    );
    mediaItem.add(media);

    try {
      // Validate the audio URL
      if (!id.startsWith('http')) {
        throw Exception('Invalid audio URL format: $id');
      }

      print('Creating audio source...');
      // Create the audio source with proper configuration
      final audioSource = AudioSource.uri(
        Uri.parse(id),
        tag: media,
      );

      print('Setting audio source...');
      // Set the audio source with proper error handling
      await _player.setAudioSource(
        audioSource,
        initialPosition: Duration.zero,
        preload: true,
      );

      print('Audio source set successfully');

      // Clear the queue and add the new media item
      _queue.clear();
      _queue.add(media);
      queue.add(_queue);

      // Update the current index
      _currentIndex = 0;

      // Listen for playback errors
      _player.playbackEventStream.listen(
        (event) {
          print('Playback event: ${event.processingState}');
          if (event.processingState == ProcessingState.completed) {
            _handleSongCompletion();
          }
        },
        onError: (Object e, StackTrace stackTrace) {
          print('Playback error: $e');
          print('Stack trace: $stackTrace');
        },
      );

      // Listen for player state changes
      _player.playerStateStream.listen(
        (state) {
          print('Player state changed: ${state.processingState}');
          print('Playing: ${state.playing}');
        },
        onError: (Object e, StackTrace stackTrace) {
          print('Player state error: $e');
          print('Stack trace: $stackTrace');
        },
      );
    } catch (e, stackTrace) {
      print('Error loading audio source: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateQueue(List<MediaItem> newQueue) async {
    _queue = newQueue;
    queue.add(_queue);
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
      shuffleMode: _isShuffle
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
      repeatMode:
          _isRepeat ? AudioServiceRepeatMode.all : AudioServiceRepeatMode.none,
    );
  }

  @override
  Future<void> play() async {
    try {
      print('Attempting to play...');
      await _player.play();
      print('Play command executed');
    } catch (e, stackTrace) {
      print('Error playing: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    try {
      print('Attempting to pause...');
      await _player.pause();
      print('Pause command executed');
    } catch (e, stackTrace) {
      print('Error pausing: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      print('Seeking to position: $position');
      await _player.seek(position);
      print('Seek completed successfully');
    } catch (e, stackTrace) {
      print('Error seeking: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      print('Stopping audio...');
      await _player.stop();
      print('Stop command executed');
    } catch (e, stackTrace) {
      print('Error stopping: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
