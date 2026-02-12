class Category {
  final String id;
  final String title;
  final String? image;

  Category({required this.id, required this.title, this.image});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      title: json['title'] as String,
      image: json['image'] as String?,
    );
  }
}
