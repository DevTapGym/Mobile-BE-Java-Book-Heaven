import 'package:heaven_book_app/model/book_feature.dart';
import 'package:heaven_book_app/model/book_image.dart';
import 'package:heaven_book_app/model/category.dart';

class Book {
  final int id;
  final String title;
  final String? description;
  final String thumbnail;
  final String author;
  final double price;
  final int quantity;
  final int sold;
  final double saleOff;
  final bool isActive;
  final Category categories;
  final List<BookImage> images;
  final List<BookFeature> features;

  Book({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.author,
    required this.price,
    required this.quantity,
    required this.sold,
    required this.saleOff,
    required this.isActive,
    this.description,
    required this.categories,
    this.images = const [],
    this.features = const [],
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'],
      thumbnail: json['thumbnail'] ?? '',
      author: json['author'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: json['quantity'] ?? 0,
      sold: json['sold'] ?? 0,
      saleOff:
          double.tryParse(
            json['sale_off']?.toString() ?? json['saleOff']?.toString() ?? '0',
          ) ??
          0.0,
      isActive: json['isDeleted'] == 0,

      // Xử lý category - BE trả về 'category' (object)
      categories:
          json['category'] != null
              ? Category.fromJson(Map<String, dynamic>.from(json['category']))
              : Category(id: 0, name: 'Unknown'),

      // Xử lý images - BE trả về 'productImages' (array)
      images:
          json['productImages'] != null
              ? (json['productImages'] as List)
                  .map((e) => BookImage.fromJson(Map<String, dynamic>.from(e)))
                  .toList()
              : [],

      features:
          (json['bookfeatures'] as List?)
              ?.map((e) => BookFeature.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }
}
