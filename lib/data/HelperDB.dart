import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class HelperDB {
  HelperDB._();
  static final HelperDB instance = HelperDB._();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }


  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'storage.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createDB(db);
      },
    );
  }

  Future<void> _createDB(Database db) async{

    await db.execute('''
    CREATE TABLE roles(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code TEXT NOT NULL UNIQUE
    )
    ''');

    await db.execute('''
    CREATE TABLE action_types(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code TEXT NOT NULL UNIQUE
    )
    ''');

    await db.execute('''
    CREATE TABLE product_statuses(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code TEXT NOT NULL UNIQUE
    )
    ''');

    await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      role_id INTEGER NOT NULL,
      FOREIGN KEY(role_id) REFERENCES roles(id)
    )
    ''');

    await db.execute('''
    CREATE TABLE products(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      link_image TEXT NOT NULL,
      status_id INTEGER NOT NULL,
      FOREIGN KEY(status_id) REFERENCES product_statuses(id)
    )
    ''');

    await db.execute('''
    CREATE TABLE actions(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id INTEGER NOT NULL,
      user_id INTEGER NOT NULL,
      action_type_id INTEGER NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY(product_id) REFERENCES products(id),
      FOREIGN KEY(user_id) REFERENCES users(id),
      FOREIGN KEY(action_type_id) REFERENCES action_types(id)
    )
    ''');

    await _insertReferencesData(db);
    await _insertUserData(db);
  }

  Future<void> _insertReferencesData(Database db) async {
    await db.insert('roles', {'id': 1, 'code': 'admin'});
    await db.insert('roles', {'id': 2, 'code': 'user'});

    await db.insert('action_types', {'id': 1, 'code': 'take'});
    await db.insert('action_types', {'id': 2, 'code': 'return'});

    await db.insert('product_statuses', {'id': 1, 'code': 'in_stock'});
    await db.insert('product_statuses', {'id': 2, 'code': 'out_of_stock'});
  }

  Future<void> _insertUserData(Database db) async {
    await db.insert('users', {'name': 'admin', 'email': 'admin@app.com', 'password': 'admin123', 'role_id': 1});
    await db.insert('users', {'name': 'user', 'email': 'user@app.com', 'password': 'user123', 'role_id': 2});
  }



  //Functions

  Future<int?> getRoleIdByCode(String code) async {
    final db = await database;
    final rows = await db.query(
      'roles',
      columns: ['id'],
      where: 'code = ?',
      whereArgs: [code],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['id'] as int;
  }

  Future<int?> getStatusIdByCode(String code) async {
    final db = await database;
    final rows = await db.query(
      'product_statuses',
      columns: ['id'],
      where: 'code = ?',
      whereArgs: [code],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['id'] as int;
  }

  Future<int?> getActionTypeIdByCode(String code) async {
    final db = await database;
    final rows = await db.query(
      'action_types',
      columns: ['id'],
      where: 'code = ?',
      whereArgs: [code],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['id'] as int;
  }


  Future<int> insertUser({
    required String name,
    required String email,
    required String password,
    required int roleId,
  }) async {
    final db = await database;
    return db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
      'role_id': roleId,
    });
  }

  Future<bool> isEmailExists(String email) async {
    final db = await database;
    final rows = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUserByEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return db.query('users', orderBy: 'id DESC');
  }


  Future<int> insertProduct({
    required String title,
    required String description,
    required String linkImage,
    required int statusId,
  }) async {
    final db = await database;
    return db.insert('products', {
      'title': title,
      'description': description,
      'link_image': linkImage,
      'status_id': statusId,
    });
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await database;
    return db.query('products', orderBy: 'id DESC');
  }

  Future<Map<String, dynamic>?> getProductById(int id) async {
    final db = await database;
    final rows = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<int> updateProductStatus({
    required int productId,
    required int statusId,
  }) async {
    final db = await database;
    return db.update(
      'products',
      {'status_id': statusId},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }


  Future<int> insertAction({
    required int productId,
    required int userId,
    required int actionTypeId,
    required String createdAt,
  }) async {
    final db = await database;
    return db.insert('actions', {
      'product_id': productId,
      'user_id': userId,
      'action_type_id': actionTypeId,
      'created_at': createdAt,
    });
  }

  Future<List<Map<String, dynamic>>> getActionsByProduct(int productId) async {
    final db = await database;
    return db.query(
      'actions',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'id DESC',
    );
  }

}