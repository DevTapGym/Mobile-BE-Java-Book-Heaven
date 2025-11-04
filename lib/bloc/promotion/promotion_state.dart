import 'package:equatable/equatable.dart';
import 'package:heaven_book_app/model/promotion.dart';

abstract class PromotionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PromotionInitial extends PromotionState {}

class PromotionLoading extends PromotionState {}

class PromotionLoaded extends PromotionState {
  final List<Promotion> promotions;

  PromotionLoaded({required this.promotions});

  @override
  List<Object?> get props => [promotions];
}

class PromotionError extends PromotionState {
  final String message;

  PromotionError(this.message);

  @override
  List<Object?> get props => [message];
}
