import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:frijofeeds/frontscn/home/presentation/providers/home_provider.dart';
import 'package:frijofeeds/frontscn/feed/presentation/providers/feed_provider.dart';

class AddFeedScreen extends StatefulWidget {
  const AddFeedScreen({super.key});

  @override
  State<AddFeedScreen> createState() => _AddFeedScreenState();
}

class _AddFeedScreenState extends State<AddFeedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  File? _videoFile;
  File? _imageFile;
  final List<String> _selectedCategories = [];
  bool _isValidating = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() => _isValidating = true);

      VideoPlayerController? controller;
      try {
        controller = VideoPlayerController.file(File(video.path));
        await controller.initialize();

        final duration = controller.value.duration;
        final isMp4 = video.path.toLowerCase().endsWith('.mp4');

        if (duration.inMinutes >= 5) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Video must be less than 5 minutes'),
              ),
            );
          }
        } else if (!isMp4) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Only MP4 videos are allowed')),
            );
          }
        } else {
          setState(() => _videoFile = File(video.path));
        }
      } catch (e) {
        debugPrint('Video validation warning: $e');
        if (video.path.toLowerCase().endsWith('.mp4')) {
          setState(() => _videoFile = File(video.path));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hardware check skipped. Video selected.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error validating video: ${e.toString()}'),
              ),
            );
          }
        }
      } finally {
        await controller?.dispose();
        if (mounted) setState(() => _isValidating = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageFile = File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Feeds',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
       
      ),
      body: Consumer<FeedProvider>(
        builder: (context, feedProvider, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDashedPicker(
                        label: 'CLICK TO SELECT VIDEO',
                        file: _videoFile,
                        onTap: _pickVideo,
                        icon: Icons.video_collection_outlined,
                        height: 200,
                        isBusy: _isValidating,
                      ),
                      const SizedBox(height: 20),
                      _buildDashedPicker(
                        label: 'ADD A THUMBNAIL',
                        file: _imageFile,
                        onTap: _pickImage,
                        icon: Icons.image_outlined,
                        height: 100,
                        isHorizontal: true,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Add Description',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descController,
                        maxLines: 4,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your description here...',
                          hintStyle: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1E1E1E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Categories (Max 3 Select)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Select All',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildCategorySelector(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              if (feedProvider.isLoading) _buildUploadOverlay(feedProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUploadOverlay(FeedProvider provider) {
    return Container(
      color: Colors.black87,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.red),
          const SizedBox(height: 24),
          const Text(
            'UPLOADING...',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: LinearProgressIndicator(
              value: provider.uploadProgress,
              backgroundColor: Colors.grey[900],
              color: Colors.red,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(provider.uploadProgress * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedPicker({
    required String label,
    required File? file,
    required VoidCallback onTap,
    required IconData icon,
    required double height,
    bool isBusy = false,
    bool isHorizontal = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: DashedBorderPainter(),
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: file != null
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          file.path.split('/').last,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              : isHorizontal
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 30, color: Colors.grey[600]),
                    const SizedBox(width: 16),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isBusy)
                      const CircularProgressIndicator(
                        color: Colors.red,
                        strokeWidth: 2,
                      )
                    else
                      Icon(icon, size: 40, color: Colors.grey[600]),
                    const SizedBox(height: 16),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = context.watch<HomeProvider>().categories;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((cat) {
        final isSelected = _selectedCategories.contains(cat.id);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedCategories.remove(cat.id);
              } else {
                if (_selectedCategories.length < 3) {
                  _selectedCategories.add(cat.id);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Maximum 3 categories allowed'),
                    ),
                  );
                }
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF320E0E) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFFD32F2F) : Colors.grey[800]!,
                width: 1,
              ),
            ),
            child: Text(
              cat.title.toLowerCase(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_videoFile == null ||
        _imageFile == null ||
        _selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select video, thumbnail and at least one category',
          ),
        ),
      );
      return;
    }

    final feedProvider = context.read<FeedProvider>();
    final success = await feedProvider.uploadFeed(
      videoPath: _videoFile!.path,
      imagePath: _imageFile!.path,
      description: _descController.text,
      categoryIds: _selectedCategories,
    );

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            feedProvider.lastErrorMessage ?? 'Upload failed. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 8;
    const dashSpace = 4;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final length = dashWidth.toDouble();
        canvas.drawPath(metric.extractPath(distance, distance + length), paint);
        distance += length + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
