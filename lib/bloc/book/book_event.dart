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

class LoadCategoryBooks extends BookEvent {
  final int categoryId;
  LoadCategoryBooks(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class LoadBookDetail extends BookEvent {
  final int id;
  LoadBookDetail(this.id);
  @override
  List<Object?> get props => [id];
}
