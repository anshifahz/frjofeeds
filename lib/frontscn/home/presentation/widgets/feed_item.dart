import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frijofeeds/frontscn/home/data/homemodel/feed_model.dart';
import 'package:frijofeeds/frontscn/home/presentation/widgets/improved_video_player.dart';

class FeedItem extends StatelessWidget {
  final Feed feed;
  final bool isCurrentlyPlaying;
  final VoidCallback onPlayToggle;

  const FeedItem({
    super.key,
    required this.feed,
    required this.isCurrentlyPlaying,
    required this.onPlayToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[900]!, width: 1),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: feed.user.profilePic != null
                    ? CachedNetworkImageProvider(feed.user.profilePic!)
                    : null,
                child: feed.user.profilePic == null
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
            ),
            title: Text(
              feed.user.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              '5 days ago',
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
          ),
          GestureDetector(
            onTap: onPlayToggle,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[900]!, width: 0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!isCurrentlyPlaying)
                      CachedNetworkImage(
                        imageUrl: feed.thumbnail,
                        width: double.infinity,
                        height: 480, // Slightly taller vertical
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 480,
                          color: const Color(0xFF1E1E1E),
                        ),
                        errorWidget: (context, url, error) => const SizedBox(
                          height: 480,
                          child: Icon(Icons.error),
                        ),
                      ),
                    if (isCurrentlyPlaying)
                      SizedBox(
                        height: 480,
                        child: ImprovedVideoPlayer(
                          videoUrl: feed.video,
                          isPlaying: true,
                        ),
                      ),
                    if (!isCurrentlyPlaying)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.8),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 13,
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: feed.description),
                  const TextSpan(
                    text: ' ...See More',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
