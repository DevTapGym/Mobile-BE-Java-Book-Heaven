import 'package:equatable/equatable.dart';
import 'package:heaven_book_app/model/product_type.dart';

abstract class ProductTypeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductTypeInitial extends ProductTypeState {}

class ProductTypeLoading extends ProductTypeState {}

class ProductTypeLoaded extends ProductTypeState {
  final List<ProductType> productTypes;

  ProductTypeLoaded(this.productTypes);

  @override
  List<Object?> get props => [productTypes];
}

class ProductTypeError extends ProductTypeState {
  final String message;

  ProductTypeError(this.message);

  @override
  List<Object?> get props => [message];
}
