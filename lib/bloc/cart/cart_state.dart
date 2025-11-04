import 'package:equatable/equatable.dart';
import 'package:heaven_book_app/model/book.dart';
import 'package:heaven_book_app/model/cart.dart';

abstract class CartState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final Cart cart;
  final List<Book> relatedBooks;
  CartLoaded({required this.cart, required this.relatedBooks});

  @override
  List<Object?> get props => [cart];
}

class CartError extends CartState {
  final String message;
  CartError(this.message);

  @override
  List<Object?> get props => [message];
}
