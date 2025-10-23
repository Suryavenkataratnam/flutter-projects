import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';


class ExpenseDatabase {
static final ExpenseDatabase instance = ExpenseDatabase._init();
static Database? _database;


ExpenseDatabase._init();


Future<Database> get database async {
if (_database != null) return _database!;
_database = await _initDB('expenses.db');
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
CREATE TABLE expenses (
id INTEGER PRIMARY KEY AUTOINCREMENT,
title TEXT NOT NULL,
amount REAL NOT NULL,
category TEXT NOT NULL,
date TEXT NOT NULL
)
''');
}


Future<int> create(Expense expense) async {
final db = await instance.database;
return await db.insert('expenses', expense.toMap());
}


Future<List<Expense>> readAllExpenses() async {
final db = await instance.database;
final result = await db.query('expenses', orderBy: 'date DESC');
return result.map((e) => Expense.fromMap(e)).toList();
}


Future<int> delete(int id) async {
final db = await instance.database;
return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
}


Future close() async {
final db = await instance.database;
await db.close();
}
}
