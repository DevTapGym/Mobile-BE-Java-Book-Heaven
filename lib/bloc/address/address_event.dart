import 'package:equatable/equatable.dart';

abstract class AddressEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAddresses extends AddressEvent {}

class AddAddress extends AddressEvent {
  final String recipientName;
  final String address;
  final String phoneNumber;
  final int tagId;
  final bool isDefault;

  AddAddress({
    required this.recipientName,
    required this.address,
    required this.phoneNumber,
    required this.tagId,
    required this.isDefault,
  });

  @override
  List<Object?> get props => [
    recipientName,
    address,
    phoneNumber,
    tagId,
    isDefault,
  ];
}

class UpdateAddress extends AddressEvent {
  final int addressId;
  final String recipientName;
  final String address;
  final String phoneNumber;
  final int tagId;
  final bool isDefault;

  UpdateAddress({
    required this.addressId,
    required this.recipientName,
    required this.address,
    required this.phoneNumber,
    required this.tagId,
    required this.isDefault,
  });

  @override
  List<Object?> get props => [
    addressId,
    recipientName,
    address,
    phoneNumber,
    tagId,
    isDefault,
  ];
}

class DeleteAddress extends AddressEvent {
  final int addressId;

  DeleteAddress({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}
