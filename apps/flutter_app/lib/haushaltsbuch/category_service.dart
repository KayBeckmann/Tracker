import 'package:tracker/database/database_helper.dart';
import 'package:tracker/haushaltsbuch/category_model.dart' as CategoryModel;
import 'package:flutter/foundation.dart';

class CategoryService {
  final dbHelper = DatabaseHelper();

  Future<int> createCategory(CategoryModel.Category category) async {
    final db = await dbHelper.database;
    final id = await db.insert('categories', category.toMap());
    debugPrint('CategoryService: Created category with ID: $id');
    return id;
  }

  Future<List<CategoryModel.Category>> getCategories() async {
    final db = await dbHelper.database;
    final maps = await db.query('categories');
    debugPrint('CategoryService: Fetched ${maps.length} categories.');
    return List.generate(maps.length, (i) {
      return CategoryModel.Category.fromMap(maps[i]);
    });
  }

  Future<CategoryModel.Category?> getCategoryById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return CategoryModel.Category.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCategory(CategoryModel.Category category) async {
    final db = await dbHelper.database;
    final rowsAffected = await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
    debugPrint('CategoryService: Updated category with ID: ${category.id}, rows affected: $rowsAffected');
    return rowsAffected;
  }

  Future<int> deleteCategory(int id) async {
    final db = await dbHelper.database;
    final rowsAffected = await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint('CategoryService: Deleted category with ID: $id, rows affected: $rowsAffected');
    return rowsAffected;
  }
}
