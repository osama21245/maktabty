// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';
import '../../../model/adress_model.dart';
import '../../../model/cart_items_model.dart';

enum CheckOutStateStatus {
  initial,
  loading,
  success,
  error,
  successAddItemToCart,
  successRemoveItemFromCart,
  successAddAddress,
  successCheckOut,
  successUpdateAddress,
}

extension CheckOutStateStatusX on CheckOutState {
  bool isInitial() => status == CheckOutStateStatus.initial;
  bool isLoading() => status == CheckOutStateStatus.loading;
  bool isSuccess() => status == CheckOutStateStatus.success;
  bool isError() => status == CheckOutStateStatus.error;
  bool isSuccessAddItemToCart() =>
      status == CheckOutStateStatus.successAddItemToCart;
  bool isSuccessRemoveItemFromCart() =>
      status == CheckOutStateStatus.successRemoveItemFromCart;
  bool isSuccessAddAddress() => status == CheckOutStateStatus.successAddAddress;
  bool isSuccessUpdateAddress() =>
      status == CheckOutStateStatus.successUpdateAddress;
  bool isSuccessCheckOut() => status == CheckOutStateStatus.successCheckOut;
}

class CheckOutState {
  final CheckOutStateStatus status;
  final double totalPrice;
  final List<CartItemsModel> cartItems;
  final List<AddressModel> address;
  final String errorMessage;
  final AddressModel? selectedAddress;

  CheckOutState({
    required this.status,
    required this.totalPrice,
    required this.cartItems,
    required this.address,
    required this.errorMessage,
    this.selectedAddress,
  });

  factory CheckOutState.initial() {
    return CheckOutState(
      status: CheckOutStateStatus.initial,
      totalPrice: 0.0,
      cartItems: [],
      address: [],
      errorMessage: '',
    );
  }

  CheckOutState copyWith({
    CheckOutStateStatus? status,
    List<CartItemsModel>? cartItems,
    List<AddressModel>? address,
    String? errorMessage,
    double? totalPrice,
    AddressModel? selectedAddress,
  }) {
    return CheckOutState(
      status: status ?? this.status,
      cartItems: cartItems ?? this.cartItems,
      address: address ?? this.address,
      errorMessage: errorMessage ?? this.errorMessage,
      totalPrice: totalPrice ?? this.totalPrice,
      selectedAddress: selectedAddress ?? this.selectedAddress,
    );
  }

  @override
  String toString() {
    return 'CheckOutState(status: $status, cartItems: $cartItems, address: $address, errorMessage: $errorMessage, totalPrice: $totalPrice)';
  }

  @override
  bool operator ==(covariant CheckOutState other) {
    if (identical(this, other)) return true;

    return other.status == status &&
        listEquals(other.cartItems, cartItems) &&
        listEquals(other.address, address) &&
        other.errorMessage == errorMessage &&
        other.totalPrice == totalPrice;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        cartItems.hashCode ^
        address.hashCode ^
        errorMessage.hashCode ^
        totalPrice.hashCode;
  }
}
