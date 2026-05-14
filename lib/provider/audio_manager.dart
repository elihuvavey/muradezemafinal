import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';

class AudioManager extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? _currentAudioTitle;
  String? _currentImage;
  bool _isPlaying = false;
  bool _isShuffle = false;
  bool _isRepeat = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  List<String> _queue = [];
  int _currentIndex = 0;
  final Random _random = Random();

  AudioManager() {
    _initNotifications();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      if (_isPlaying) {
        _showMediaNotification();
      } else {
        _cancelMediaNotification();
      }
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handleSongCompletion();
      }
    });
  }

  void _handleSongCompletion() async {
    if (_isRepeat) {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
    } else if (_isShuffle) {
      await skipToNext();
    } else if (_currentIndex < _queue.length - 1) {
      await skipToNext();
    }
  }

  Future<void> playAudio(String url, String title, String image) async {
    if (!_queue.contains(url)) {
      _queue.add(url);
    }
    _currentIndex = _queue.indexOf(url);
    _currentAudioTitle = title;
    _currentImage = image;
    await _audioPlayer.setUrl(url);
    await _audioPlayer.play();
    notifyListeners();
  }

  void pause() {
    _audioPlayer.pause();
    notifyListeners();
  }

  void resume() {
    _audioPlayer.play();
    notifyListeners();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    if (_isShuffle) {
      _isRepeat = false;
    }
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    if (_isRepeat) {
      _isShuffle = false;
    }
    notifyListeners();
  }

  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;

    if (_isShuffle) {
      _currentIndex = _random.nextInt(_queue.length);
    } else if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
    } else if (_isRepeat) {
      _currentIndex = 0;
    } else {
      return;
    }

    final nextUrl = _queue[_currentIndex];
    await _audioPlayer.setUrl(nextUrl);
    await _audioPlayer.play();
    notifyListeners();
  }

  Future<void> skipToPrevious() async {
    if (_queue.isEmpty) return;

    if (_isShuffle) {
      _currentIndex = _random.nextInt(_queue.length);
    } else if (_currentIndex > 0) {
      _currentIndex--;
    } else if (_isRepeat) {
      _currentIndex = _queue.length - 1;
    } else {
      return;
    }

    final previousUrl = _queue[_currentIndex];
    await _audioPlayer.setUrl(previousUrl);
    await _audioPlayer.play();
    notifyListeners();
  }

  bool get isPlaying => _isPlaying;
  bool get isShuffle => _isShuffle;
  bool get isRepeat => _isRepeat;
  Duration get duration => _duration;
  Duration get position => _position;
  String? get currentAudioTitle => _currentAudioTitle;
  String? get currentImage => _currentImage;

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.actionId == 'pause') {
        if (_isPlaying) {
          pause();
        } else {
          resume();
        }
      } else if (response.actionId == 'next') {
        skipToNext();
      } else if (response.actionId == 'previous') {
        skipToPrevious();
      } else if (response.actionId == 'close') {
        _cancelMediaNotification();
      }
    });
  }

  Future<void> _showMediaNotification() async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'media_channel_id',
      'Media Playback',
      channelDescription: 'Notification for media playback controls',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('previous', 'Previous'),
        AndroidNotificationAction('pause', _isPlaying ? 'Pause' : 'Play'),
        AndroidNotificationAction('next', 'Next'),
        AndroidNotificationAction('close', 'Close'),
      ],
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Now Playing',
      _currentAudioTitle ?? 'Unknown Track',
      platformChannelSpecifics,
      payload: 'media_payload',
    );
  }

  Future<void> _cancelMediaNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _cancelMediaNotification();
    super.dispose();
  }
}
