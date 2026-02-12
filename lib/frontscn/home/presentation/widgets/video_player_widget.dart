import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool isPlaying;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.isPlaying,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showControls = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                _initialized = true;
                _hasError = false;
                if (widget.isPlaying) _controller.play();
              });
            }
          })
          .catchError((error) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = error.toString();
              });
            }
          });

    _controller.addListener(() {
      if (_controller.value.hasError && mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = _controller.value.errorDescription;
        });
      }
    });
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitsMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitsSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitsMinutes:$twoDigitsSeconds";
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
            const Icon(Icons.error_outline, color: Colors.red, size: 42),
            const SizedBox(height: 12),
            const Text(
              "Playback Error",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _errorMessage ?? "Unknown error occurred",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
              maxLines: 2,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _initialized = false;
                  _hasError = false;
                });
                _initializeController();
              },
              child: const Text("Retry", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    if (!_initialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (_showControls) ...[_buildControlsOverlay()],
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black38,
        child: Column(
          children: [const Spacer(), _buildSeekBar(), _buildBottomControls()],
        ),
      ),
    );
  }

  Widget _buildSeekBar() {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (context, VideoPlayerValue value, child) {
        final position = value.position.inMilliseconds.toDouble();
        final duration = value.duration.inMilliseconds.toDouble();

        return SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: Colors.red,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.red,
          ),
          child: Slider(
            value: position.clamp(0.0, duration),
            max: duration,
            onChanged: (val) {
              _controller.seekTo(Duration(milliseconds: val.toInt()));
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                }),
              ),
              ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, VideoPlayerValue value, child) {
                  return Text(
                    "${_formatDuration(value.position)} / ${_formatDuration(value.duration)}",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  );
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: _toggleFullscreen,
          ),
        ],
      ),
    );
  }

  void _toggleFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullscreenPlayer(controller: _controller),
      ),
    );
  }
}

class FullscreenPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  const FullscreenPlayer({super.key, required this.controller});

  @override
  State<FullscreenPlayer> createState() => _FullscreenPlayerState();
}

class _FullscreenPlayerState extends State<FullscreenPlayer> {
  @override
  void initState() {
    super.initState();
    // SystemChrome normally used here for orientation, but keeping it simple for now
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: widget.controller.value.aspectRatio,
              child: VideoPlayer(widget.controller),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
