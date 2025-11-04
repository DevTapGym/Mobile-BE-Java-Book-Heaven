import 'package:equatable/equatable.dart';

abstract class PromotionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPromotions extends PromotionEvent {}
