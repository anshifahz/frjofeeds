import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frijofeeds/frontscn/feed/presentation/providers/feed_provider.dart';
import 'package:frijofeeds/frontscn/home/presentation/widgets/feed_item.dart';

class MyFeedsScreen extends StatefulWidget {
  const MyFeedsScreen({super.key});

  @override
  State<MyFeedsScreen> createState() => _MyFeedsScreenState();
}

class _MyFeedsScreenState extends State<MyFeedsScreen> {
  final ScrollController _scrollController = ScrollController();
  int? _playingFeedId;

  @override
 

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'My Feeds',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<FeedProvider>(
        builder: (context, feedProvider, _) {
          if (feedProvider.isLoading && feedProvider.myFeeds.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (feedProvider.myFeeds.isEmpty) {
            return const Center(
              child: Text('You haven\'t posted any feeds yet.'),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount:
                feedProvider.myFeeds.length + (feedProvider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == feedProvider.myFeeds.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final feed = feedProvider.myFeeds[index];
              return FeedItem(
                feed: feed,
                isCurrentlyPlaying: _playingFeedId == feed.id,
                onPlayToggle: () {
                  setState(() {
                    if (_playingFeedId == feed.id) {
                      _playingFeedId = null;
                    } else {
                      _playingFeedId = feed.id;
                    }
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
