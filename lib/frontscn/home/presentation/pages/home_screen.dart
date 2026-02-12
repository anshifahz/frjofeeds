import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frijofeeds/frontscn/home/presentation/providers/home_provider.dart';
import 'package:frijofeeds/frontscn/feed/presentation/pages/add_feed_screen.dart';
import 'package:frijofeeds/frontscn/feed/presentation/pages/my_feeds_screen.dart';
import 'package:frijofeeds/frontscn/home/presentation/widgets/feed_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int? playingFeedId;
  String selectedCategoryId = "0"; // Default to Explore as per mockup

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final homeProvider = context.read<HomeProvider>();
      homeProvider.fetchCategories();
      homeProvider.fetchHomeFeeds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        title: Consumer<HomeProvider>(
          builder: (context, home, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello ${home.userName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Welcome back to section',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            );
          },
        ),
        actions: [
          Consumer<HomeProvider>(
            builder: (context, home, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyFeedsScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.0),
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey,
                      backgroundImage: home.userProfileImage != null
                          ? CachedNetworkImageProvider(home.userProfileImage!)
                        
                          : null,
                      child: home.userProfileImage == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<HomeProvider>(
        builder: (context, home, _) {
          return Column(
            children: [
              buildCategoryList(home),
              Expanded(
                child: home.isLoading && home.feeds.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      )
                    : RefreshIndicator(
                        backgroundColor: const Color(0xFF1E1E1E),
                        color: Colors.red,
                        onRefresh: () => home.fetchHomeFeeds(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 100),
                          itemCount: home.feeds.length,
                          itemBuilder: (context, index) {
                            final feed = home.feeds[index];
                            return FeedItem(
                              feed: feed,
                              isCurrentlyPlaying: playingFeedId == feed.id,
                              onPlayToggle: () {
                                setState(() {
                                  if (playingFeedId == feed.id) {
                                    playingFeedId = null;
                                  } else {
                                    playingFeedId = feed.id;
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddFeedScreen()),
        ),
        backgroundColor: const Color(0xFFD32F2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget buildCategoryList(HomeProvider home) {
    final categories = home.categories;

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategoryId == cat.id;

          final String catName = cat.title;

          IconData? icon;
          if (cat.id == "0") icon = Icons.explore_outlined;
          if (cat.id == "0.0") icon = Icons.local_fire_department_outlined;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              avatar: icon != null
                  ? Icon(
                      icon,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey,
                    )
                  : null,
              label: Text(catName),
              selected: isSelected,
              onSelected: (val) => setState(() => selectedCategoryId = cat.id),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[300],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              selectedColor: const Color(0xFF5D1313),
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey[900]!,
                  width: 1,
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}
