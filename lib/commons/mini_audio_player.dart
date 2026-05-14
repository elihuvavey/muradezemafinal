import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/audio_manager.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioManager>(
      builder: (context, audioManager, child) {
        if (audioManager.currentAudioTitle == null) {
          return SizedBox.shrink();
        }

        return SizedBox(
          height: 50,
          child: Container(
            color: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (audioManager.currentImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      audioManager.currentImage!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        audioManager.currentAudioTitle!,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          if (audioManager.isShuffle)
                            Icon(Icons.shuffle, color: Colors.orange, size: 12),
                          if (audioManager.isRepeat)
                            Icon(Icons.repeat, color: Colors.orange, size: 12),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        audioManager.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        audioManager.isPlaying
                            ? audioManager.pause()
                            : audioManager.resume();
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.skip_next,
                        color: Colors.white,
                      ),
                      onPressed: () => audioManager.skipToNext(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
