class BookFeature {
  final int id;
  final String featureName;

  BookFeature({required this.id, required this.featureName});

  factory BookFeature.fromJson(Map<String, dynamic> json) {
    return BookFeature(id: json['id'], featureName: json['feature_name'] ?? '');
  }
}
