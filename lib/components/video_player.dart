import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart'; // Core package
import 'package:media_kit_video/media_kit_video.dart'; // For Video UI

class MediaKitVideoPlayer extends StatefulWidget {
  final String videoAssetPath;
  final bool autoplay;
  final double? aspectRatio;
  final bool? autoPlay;

  const MediaKitVideoPlayer({
    super.key,
    required this.videoAssetPath,
    this.autoplay = false,
    this.aspectRatio,
    this.autoPlay = true,
  });

  @override
  MediaKitVideoPlayerState createState() => MediaKitVideoPlayerState();
}

class MediaKitVideoPlayerState extends State<MediaKitVideoPlayer> {
  late final Player player = Player();
  late final VideoController videoController;

  @override
  void initState() {
    super.initState();
    videoController = VideoController(player);

    player.open(
      Media('asset:///${widget.videoAssetPath}'),
      play: widget.autoplay,
    );

    player.stream.error.listen((error) {
      debugPrint("MediaKit Player Error: $error");

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Video player error: $error")));
      }
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget videoDisplay = Video(controller: videoController);

    if (widget.aspectRatio != null && widget.aspectRatio! > 0) {
      videoDisplay = AspectRatio(
        aspectRatio: widget.aspectRatio!,
        child: videoDisplay,
      );
    }

    return MaterialVideoControlsTheme(
      normal: MaterialVideoControlsThemeData(),
      fullscreen: MaterialVideoControlsThemeData(),
      child: videoDisplay,
    );
  }
}
