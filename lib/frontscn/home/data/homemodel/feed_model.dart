class Feed {
  final int id;
  final String video;
  final String thumbnail;
  final String description;
  final UserDetails user;

  Feed({
    required this.id,
    required this.video,
    required this.thumbnail,
    required this.description,
    required this.user,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      id: json['id'] as int,
      video: json['video'] as String,
      thumbnail: json['image'] as String,
      description: json['description'] as String,
      user: UserDetails.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class UserDetails {
  final int id;
  final String name;
  final String? profilePic;

  UserDetails({required this.id, required this.name, this.profilePic});

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'] as int,
      name: json['name'] as String,
      profilePic: json['image'] as String?,
    );
  }
}
