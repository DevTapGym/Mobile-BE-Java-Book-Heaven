import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/product_type/product_type_event.dart';
import 'package:heaven_book_app/bloc/product_type/product_type_state.dart';
import 'package:heaven_book_app/services/product_type_service.dart';


class ProductTypeBloc extends Bloc<ProductTypeEvent, ProductTypeState> {
  final ProductTypeService _service;

  ProductTypeBloc(this._service) : super(ProductTypeInitial()) {
    on<LoadProductType>(_onLoadProductTypes);
  }

  Future<void> _onLoadProductTypes(
    LoadProductType event,
    Emitter<ProductTypeState> emit,
  ) async {
    emit(ProductTypeLoading());
    try {
      final productTypes = await _service.getAllProductType();
      emit(ProductTypeLoaded(productTypes));
    } catch (e) {
      emit(ProductTypeError(e.toString()));
    }
  }
}
