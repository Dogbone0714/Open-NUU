class NewsItem {
  final String title;
  final String category;
  final String date;
  final String description;
  final String content;
  final List<String>? attachments;
  final String? imageUrl;
  final String? link;

  const NewsItem({
    required this.title,
    required this.category,
    required this.date,
    required this.description,
    required this.content,
    this.attachments,
    this.imageUrl,
    this.link,
  });
} 