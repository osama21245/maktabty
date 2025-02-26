import 'package:flutter/material.dart';
import '../../../data/model/item_model.dart';

class ItemListViewModel {
  final TextEditingController searchController;
  String searchQuery = '';

  ItemListViewModel() : searchController = TextEditingController();

  double calculateTotalRetailPrice(List<ItemModel> items) {
    return items.fold(
        0, (sum, item) => sum + (item.retailPrice * item.quantity));
  }

  double calculateTotalWholesalePrice(List<ItemModel> items) {
    return items.fold(
        0, (sum, item) => sum + (item.wholesalePrice * item.quantity));
  }

  double calculateTotalProfit(List<ItemModel> items) {
    return calculateTotalRetailPrice(items) -
        calculateTotalWholesalePrice(items);
  }

  double calculateItemTotalRetail(ItemModel item) {
    return item.retailPrice * item.quantity;
  }

  double calculateItemTotalWholesale(ItemModel item) {
    return item.wholesalePrice * item.quantity;
  }

  double calculateItemProfit(ItemModel item) {
    return calculateItemTotalRetail(item) - calculateItemTotalWholesale(item);
  }

  List<ItemModel> filterItems(List<ItemModel> items, int categoryId) {
    return items
        .where((item) =>
            item.categoryId == categoryId &&
            item.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void updateSearchQuery(String value) {
    searchQuery = value;
  }

  void dispose() {
    searchController.dispose();
  }
}
