import 'package:equatable/equatable.dart';

abstract class BookEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBooks extends BookEvent {}

class LoadAllBooks extends BookEvent {}

class LoadSearchBooks extends BookEvent {
  final String query;
  LoadSearchBooks(this.query);
  @override
  List<Object?> get props => [query];
}

class LoadProductTypeBooks extends BookEvent {
  final String productTypeName;
  LoadProductTypeBooks(this.productTypeName);
  @override
  List<Object?> get props => [productTypeName];
}

class LoadCategoryBooks extends BookEvent {
  final String categoryName;
  LoadCategoryBooks(this.categoryName);
  @override
  List<Object?> get props => [categoryName];
}

class LoadBookDetail extends BookEvent {
  final int id;
  LoadBookDetail(this.id);
  @override
  List<Object?> get props => [id];
}
