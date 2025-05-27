import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../task.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tarefas.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE tarefas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT,
            responsavel TEXT,
            dataLimite TEXT
          )
        ''');
      },
    );
  }

  Future<void> inserirTarefa(Task task) async {
    final db = await database;
    await db.insert(
      'tarefas',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> listarTarefas() async {
    final db = await database;
    final maps = await db.query('tarefas', orderBy: 'dataLimite ASC');

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }
}
