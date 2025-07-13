import 'package:tracker/database/database_helper.dart';
import 'package:tracker/haushaltsbuch/transaction_template_model.dart';
import 'package:flutter/foundation.dart';

class TransactionTemplateService {
  final dbHelper = DatabaseHelper();

  Future<int> createTemplate(TransactionTemplate template) async {
    final db = await dbHelper.database;
    final id = await db.insert('transaction_templates', template.toMap());
    debugPrint('TransactionTemplateService: Created template with ID: $id');
    return id;
  }

  Future<List<TransactionTemplate>> getTemplates() async {
    final db = await dbHelper.database;
    final maps = await db.query('transaction_templates');
    debugPrint('TransactionTemplateService: Fetched ${maps.length} templates.');
    return List.generate(maps.length, (i) {
      return TransactionTemplate.fromMap(maps[i]);
    });
  }

  Future<int> updateTemplate(TransactionTemplate template) async {
    final db = await dbHelper.database;
    final rowsAffected = await db.update(
      'transaction_templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
    debugPrint('TransactionTemplateService: Updated template with ID: ${template.id}, rows affected: $rowsAffected');
    return rowsAffected;
  }

  Future<int> deleteTemplate(int id) async {
    final db = await dbHelper.database;
    final rowsAffected = await db.delete(
      'transaction_templates',
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint('TransactionTemplateService: Deleted template with ID: $id, rows affected: $rowsAffected');
    return rowsAffected;
  }
}
