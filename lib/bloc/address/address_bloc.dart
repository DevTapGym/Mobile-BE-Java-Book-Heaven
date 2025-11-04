import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/address/address_event.dart';
import 'package:heaven_book_app/bloc/address/address_state.dart';
import 'package:heaven_book_app/services/address_service.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressService _addressService;

  AddressBloc(this._addressService) : super(AddressInitial()) {
    on<LoadAddresses>(_onLoadAddresses);
    on<AddAddress>(_onAddAddress);
    on<UpdateAddress>(_onUpdateAddress);
    on<DeleteAddress>(_onDeleteAddress);
  }

  Future<void> _onLoadAddresses(
    LoadAddresses event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final addresses = await _addressService.getMyAddresses();
      final tagAddresses = await _addressService.getAllTagAddresses();
      emit(AddressLoaded(addresses: addresses, tagAddress: tagAddresses));
    } catch (e) {
      emit(AddressError(message: 'Failed to load addresses: $e'));
    }
  }

  Future<void> _onAddAddress(
    AddAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      await _addressService.addNewAddress(
        recipientName: event.recipientName,
        address: event.address,
        phoneNumber: event.phoneNumber,
        tagId: event.tagId,
        isDefault: event.isDefault,
      );
      emit(AddressSuccess());
      await Future.delayed(Duration(milliseconds: 2000));

      add(LoadAddresses());
    } catch (e) {
      emit(AddressError(message: 'Failed to add address: $e'));
    }
  }

  Future<void> _onUpdateAddress(
    UpdateAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      await _addressService.updateAddress(
        addressId: event.addressId,
        recipientName: event.recipientName,
        address: event.address,
        phoneNumber: event.phoneNumber,
        tagId: event.tagId,
        isDefault: event.isDefault,
      );
      add(LoadAddresses());
    } catch (e) {
      emit(AddressError(message: 'Failed to update address: $e'));
    }
  }

  Future<void> _onDeleteAddress(
    DeleteAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      await _addressService.deleteAddress(event.addressId);
      add(LoadAddresses());
    } catch (e) {
      emit(AddressError(message: 'Failed to delete address: $e'));
    }
  }
}
