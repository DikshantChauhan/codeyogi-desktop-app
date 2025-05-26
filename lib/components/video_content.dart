import 'package:desktop_app/components/video_player.dart';
import 'package:desktop_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:desktop_app/models/sublevel_model.dart';

class VideoContent extends StatefulWidget {
  final Video video;

  const VideoContent({super.key, required this.video});

  @override
  State<VideoContent> createState() => _VideoContentState();
}

class _VideoContentState extends State<VideoContent> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildDemoVideoPlayer() {
    return MediaKitVideoPlayer(
      videoAssetPath: demoVideoPath,
      autoplay: true,
      aspectRatio: 16 / 9,
    );
  }

  Widget _buildTelegramVideo() {
    // TODO: Implement Telegram video player
    return _buildDemoVideoPlayer();
  }

  Widget _buildVideoPlayer() {
    // TODO: Implement video player
    return _buildDemoVideoPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.video.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          if (widget.video.telegramId != null)
            _buildTelegramVideo()
          else if (widget.video.videoId != null &&
              widget.video.thumbnailId != null)
            _buildVideoPlayer(),
        ],
      ),
    );
  }
}
