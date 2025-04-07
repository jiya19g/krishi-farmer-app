import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('news_cache.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE news (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        imageUrl TEXT,
        publishedAt TEXT,
        sourceName TEXT,
        cachedAt TEXT
      )
    ''');
  }

  Future<int> insertNews(List<Map<String, dynamic>> newsItems) async {
    final db = await instance.database;
    await db.delete('news'); // Clear old news before inserting new ones
    
    final batch = db.batch();
    for (var item in newsItems) {
      batch.insert('news', item);
    }
    await batch.commit();
    return newsItems.length;
  }

  Future<List<Map<String, dynamic>>> getCachedNews() async {
    final db = await instance.database;
    return await db.query('news');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}