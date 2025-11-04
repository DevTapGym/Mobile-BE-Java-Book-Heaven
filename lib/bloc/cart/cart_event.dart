import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {}

class ToggleAllCartItemSelection extends CartEvent {
  final List<int> cartItemId;
  final bool isSelected;

  ToggleAllCartItemSelection(this.cartItemId, this.isSelected);

  @override
  List<Object?> get props => [cartItemId, isSelected];
}

class ToggleCartItemSelection extends CartEvent {
  final int cartItemId;
  final bool isSelected;

  ToggleCartItemSelection(this.cartItemId, this.isSelected);

  @override
  List<Object?> get props => [cartItemId, isSelected];
}

class UpdateCartItemQuantity extends CartEvent {
  final int cartItemId;
  final int newQuantity;

  UpdateCartItemQuantity(this.cartItemId, this.newQuantity);
}

class AddToCart extends CartEvent {
  final int bookId;
  final int quantity;

  AddToCart({required this.bookId, this.quantity = 1});

  @override
  List<Object?> get props => [bookId, quantity];
}

class RemoveCartItem extends CartEvent {
  final int cartItemId;

  RemoveCartItem(this.cartItemId);

  @override
  List<Object?> get props => [cartItemId];
}
