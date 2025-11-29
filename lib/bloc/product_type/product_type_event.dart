import 'package:equatable/equatable.dart';

abstract class ProductTypeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProductType extends ProductTypeEvent {}
