import 'package:equatable/equatable.dart';
import 'package:heaven_book_app/model/address.dart';
import 'package:heaven_book_app/model/tag_address.dart';

abstract class AddressState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressSuccess extends AddressState {}

class AddressLoaded extends AddressState {
  final List<Address> addresses;
  final List<TagAddress> tagAddress;

  AddressLoaded({required this.addresses, required this.tagAddress});
}

class AddressError extends AddressState {
  final String message;
  AddressError({required this.message});
  @override
  List<Object?> get props => [message];
}
