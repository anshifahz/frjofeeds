import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ImprovedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isPlaying;

  const ImprovedVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.isPlaying,
  });

  @override
  State<ImprovedVideoPlayer> createState() => _ImprovedVideoPlayerState();
}

class _ImprovedVideoPlayerState extends State<ImprovedVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _videoPlayerController.initialize();

      if (mounted) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            autoPlay: widget.isPlaying,
            looping: false,
            showControls: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: const Color(0xFFD32F2F),
              handleColor: const Color(0xFFD32F2F),
              backgroundColor: Colors.grey,
              bufferedColor: Colors.grey.shade700,
            ),
            placeholder: Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
              ),
            ),
            errorBuilder: (context, errorMessage) {
              return Container(
                color: Colors.black,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Video Playback Error',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This video format may not be supported on your device',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _isInitialized = false;
                        });
                        _initializePlayer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
          );
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void didUpdateWidget(ImprovedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (_chewieController != null) {
        if (widget.isPlaying) {
          _videoPlayerController.play();
        } else {
          _videoPlayerController.pause();
        }
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Unable to Load Video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isInitialized = false;
                });
                _initializePlayer();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _chewieController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Chewie(controller: _chewieController!),
    );
  }
}
