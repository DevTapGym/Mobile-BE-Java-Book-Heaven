class BookImage {
  final int id;
  final String url;

  BookImage({required this.id, required this.url});

  factory BookImage.fromJson(Map<String, dynamic> json) {
    return BookImage(id: json['id'], url: json['url'] ?? '');
  }
}
