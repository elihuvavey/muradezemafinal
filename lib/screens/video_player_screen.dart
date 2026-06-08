import 'package:muradezema/utils/dio_client.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muradezema/utils/endpoint.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../commons/custom_bottom_nav.dart';
import '../commons/custom_info_dialog.dart';
import '../provider/vide_id_provider.dart';
import '../utils/nav_constants.dart';
import '../utils/user_prefs.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  int _currentIndex = 3;
  String videoUrl = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final id = args?['id'] as int?;
      if (id != null) {
        Provider.of<VideoIdProvider>(context, listen: false).fetchEpisode(id);
        _checkPurchase(id);
      }
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo(String url) async {
    setState(() => _isLoading = true);
    _controller = VideoPlayerController.network(url)
      ..setLooping(false)
      ..initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _controller!,
          aspectRatio: _controller!.value.aspectRatio,
          autoInitialize: true,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: Colors.orangeAccent,
            handleColor: Colors.white,
            backgroundColor: Colors.grey.shade800,
            bufferedColor: Colors.lightBlueAccent,
          ),
          placeholder: Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        );
        setState(() => _isLoading = false);
      });
  }

  Future<void> _checkPurchase(int id) async {
    try {
      final url = "${ApiConstants.baseUrl}/video/episodes/$id/play";
      debugPrint('Check purchase URL: $url');
      final response = await createDio().get(
        url,
        options: Options(
          headers: {
            'Accept': 'application/json',
            
          },
          validateStatus: (status) => status! < 500,
        ),
      );
      debugPrint('Check purchase response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        await _initializeVideo(response.data['video']);
      } else {
        _showErrorDialog(
          title: 'Access Denied',
          message: response.data['message'] ?? 'Cannot play this video.',
          retry: () => _checkPurchase(id),
        );
      }
    } catch (e) {
      _showErrorDialog(
        title: 'Error',
        message: 'An error occurred: $e',
      );
    }
  }

  void _showErrorDialog({
    required String title,
    required String message,
    VoidCallback? retry,
  }) {
    showDialog(
      context: context,
      builder: (_) => CustomInfoDialog(
        title: title,
        message: message,
        buttonText: retry != null ? 'Retry' : 'Close',
        onButtonPressed: () {
          Navigator.pop(context);
          if (retry != null) retry();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final name = args?['name'] ?? '';
    final title = args?['title'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: Text(
          name,
          style: TextStyle(color: Colors.white70, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent))
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Chewie(controller: _chewieController!),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Text(
                    title,
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              Navigator.pushNamed(context, NavigationConstants.bookHome);
              break;
            case 1:
              Navigator.pushNamed(context, NavigationConstants.audioHome);
              break;
            case 2:
              Navigator.pushNamed(context, NavigationConstants.videoHome);
              break;
          }
        },
      ),
    );
  }
}
