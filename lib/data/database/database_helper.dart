import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/lead_model.dart';

class DatabaseHelper {
  static const String _tableName = 'leads';
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'leads.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            email TEXT NOT NULL,
            notes TEXT,
            status TEXT NOT NULL,
            createdAt INTEGER NOT NULL,
            lastUpdatedAt INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertLead(Lead lead) async {
    final db = await database;
    return await db.insert(_tableName, lead.toMap());
  }

  Future<List<Lead>> getLeads() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'lastUpdatedAt DESC', 
    );
    return List.generate(maps.length, (i) {
      return Lead.fromMap(maps[i]);
    });
  }

  Future<int> updateLead(Lead lead) async {
    final db = await database;
    if (lead.id == null) return 0;
    return await db.update(
      _tableName,
      lead.toMap(),
      where: 'id = ?',
      whereArgs: [lead.id],
    );
  }

  
  Future<int> deleteLead(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}