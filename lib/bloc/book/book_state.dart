import 'package:equatable/equatable.dart';
import 'package:heaven_book_app/model/book.dart';

abstract class BookState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BookLoadAll extends BookState {
  final List<Book> allBooks;
  BookLoadAll(this.allBooks);
  @override
  List<Object?> get props => [allBooks];
}

class BookDetailLoaded extends BookState {
  final Book book;
  final List<Book> relatedBooks;
  BookDetailLoaded({required this.book, required this.relatedBooks});
  @override
  List<Object?> get props => [book];
}

class BookSearchLoaded extends BookState {
  final List<Book> searchResults;
  BookSearchLoaded(this.searchResults);
  @override
  List<Object?> get props => [searchResults];
}

class BookCategoryLoaded extends BookState {
  final List<Book> categoryBooks;
  BookCategoryLoaded(this.categoryBooks);
  @override
  List<Object?> get props => [categoryBooks];
}

class BookLoaded extends BookState {
  final List<Book> popularBooks;
  final List<Book> saleOffBooks;
  final List<Book> bestSellingBooks;
  final List<Book> bannerBooks;
  final List<Book> randomBooks;

  BookLoaded({
    required this.popularBooks,
    required this.saleOffBooks,
    required this.bestSellingBooks,
    required this.bannerBooks,
    required this.randomBooks,
  });

  @override
  List<Object?> get props => [popularBooks, saleOffBooks];
}

class BookError extends BookState {
  final String message;
  BookError(this.message);
  @override
  List<Object?> get props => [message];
}
