import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/try_and_catch.dart';

final supabaseClientProvider =
    Provider.autoDispose<SupabaseClient>((ref) => Supabase.instance.client);

final adminRemoteDataSourceProvider =
    Provider.autoDispose<AdminRemoteDataSource>(
        (ref) => AdminRemoteDataSourceImpl(ref.watch(supabaseClientProvider)));

abstract interface class AdminRemoteDataSource {
  Future<Map<String, dynamic>> uploadItem(Map<String, dynamic> item);
  Future<String> uploadItemImage({
    required File image,
    required String itemId,
  });
  Future<List<Map<String, dynamic>>> getAllItems();
  Future<void> deleteItem(String itemId);
  Future<Map<String, dynamic>> addCategory(String name, String imageUrl);
  Future<List<Map<String, dynamic>>> getAllCategories();
  Future<void> deleteCategory(int categoryId);
  Future<Map<String, dynamic>> updateCategory(
      {required int id, required String name});
  Future<Map<String, dynamic>> updateItem(Map<String, dynamic> item);
  Future<void> deleteItemImage(String imageUrl);
  Future<String> uploadCategoryImage({
    required File image,
    required int categoryId,
  });
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final SupabaseClient supabaseClient;
  AdminRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<Map<String, dynamic>> uploadItem(Map<String, dynamic> item) async {
    return executeTryAndCatchForDataLayer(() async {
      final itemData =
          await supabaseClient.from('items').insert(item).select().single();
      return itemData;
    });
  }

  @override
  Future<String> uploadItemImage({
    required File image,
    required String itemId,
  }) async {
    return executeTryAndCatchForDataLayer(() async {
      await supabaseClient.storage.from('item_images').remove([itemId]);

      await supabaseClient.storage.from('item_images').upload(
            itemId,
            image,
          );

      return supabaseClient.storage.from('item_images').getPublicUrl(itemId);
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getAllItems() async {
    return executeTryAndCatchForDataLayer(() async {
      final items = await supabaseClient.from('items').select('*');
      return List<Map<String, dynamic>>.from(items);
    });
  }

  @override
  Future<void> deleteItem(String itemId) async {
    return executeTryAndCatchForDataLayer(() async {
      await supabaseClient.storage.from('item_images').remove([itemId]);
      await supabaseClient.from('items').delete().match({'id': itemId});
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    return executeTryAndCatchForDataLayer(() async {
      final categories = await supabaseClient.from('categories').select('*');
      return List<Map<String, dynamic>>.from(categories);
    });
  }

  @override
  Future<void> deleteCategory(int categoryId) async {
    return executeTryAndCatchForDataLayer(() async {
      await supabaseClient
          .from('categories')
          .delete()
          .match({'id': categoryId});
    });
  }

  @override
  Future<Map<String, dynamic>> updateCategory({
    required int id,
    required String name,
  }) async {
    return executeTryAndCatchForDataLayer(() async {
      final updatedCategory = await supabaseClient
          .from('categories')
          .update({'name': name})
          .match({'id': id})
          .select()
          .single();

      return updatedCategory;
    });
  }

  @override
  Future<Map<String, dynamic>> updateItem(Map<String, dynamic> item) async {
    return executeTryAndCatchForDataLayer(() async {
      final updatedItem = await supabaseClient
          .from('items')
          .update(item)
          .match({'id': item['id']})
          .select()
          .single();
      return updatedItem;
    });
  }

  @override
  Future<void> deleteItemImage(String imageUrl) async {
    return executeTryAndCatchForDataLayer(() async {
      // Extract file name from URL
      final fileName = imageUrl.split('/').last;
      await supabaseClient.storage.from('item_images').remove([fileName]);
    });
  }

  @override
  Future<String> uploadCategoryImage({
    required File image,
    required int categoryId,
  }) async {
    return executeTryAndCatchForDataLayer(() async {
      final fileName = 'category_$categoryId';
      await supabaseClient.storage.from('category_images').upload(
            fileName,
            image,
          );

      return supabaseClient.storage
          .from('category_images')
          .getPublicUrl(fileName);
    });
  }

  @override
  Future<Map<String, dynamic>> addCategory(String name, String imageUrl) async {
    return executeTryAndCatchForDataLayer(() async {
      final categoryData = await supabaseClient
          .from('categories')
          .insert({
            'name': name,
            'image_url': imageUrl,
          })
          .select()
          .single();

      return categoryData;
    });
  }
}
