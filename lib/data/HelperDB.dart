import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';


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
      uuid TEXT NOT NULL UNIQUE,
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
    await _insertProductsData(db);
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
    await db.insert('users', {'name': 'admin', 'email': 'admin1@app.com', 'password': 'admin123', 'role_id': 1});
    await db.insert('users', {'name': 'admin', 'email': 'admin2@app.com', 'password': 'admin123', 'role_id': 1});
    await db.insert('users', {'name': 'user', 'email': 'user@app.com', 'password': 'user123', 'role_id': 2});
  }

  Future<void> _insertProductsData(Database db) async {
    final uuid = const Uuid();

    await db.insert('products', {
      'uuid': uuid.v4(),
      'title': 'Резиновые шлёпанцы',
      'description': 'Лёгкие и удобные шлёпанцы для дома, пляжа и повседневной носки. '
          'Изготовлены из мягкого материала, который не натирает ногу и хорошо держит форму. '
          'Подходят для длительной ходьбы и быстро высыхают после воды.',
      'link_image': 'assets/images/cart1.png',
      'status_id': 1,
    });

    await db.insert('products', {
      'uuid': uuid.v4(),
      'title': 'Спортивная футболка',
      'description': 'Дышащая футболка из лёгкой ткани, предназначенная для спорта и активного отдыха. '
          'Материал хорошо отводит влагу и позволяет коже дышать даже при интенсивных тренировках. '
          'Идеально подходит для занятий в зале и на улице.',
      'link_image': 'assets/images/cart2.png',
      'status_id': 1,
    });

    await db.insert('products', {
      'uuid': uuid.v4(),
      'title': 'Городской рюкзак',
      'description': 'Компактный рюкзак для повседневного использования. '
          'Имеет несколько отделений для ноутбука, документов и личных вещей. '
          'Прочные молнии и удобные регулируемые лямки делают его отличным выбором для работы или учёбы.',
      'link_image': 'assets/images/cart3.png',
      'status_id': 1,
    });

    await db.insert('products', {
      'uuid': uuid.v4(),
      'title': 'Беспроводные наушники',
      'description': 'Современные Bluetooth-наушники с чистым звучанием и удобной посадкой. '
          'Поддерживают быстрое подключение к смартфону и работают до 6 часов без подзарядки. '
          'Подходят для прослушивания музыки, подкастов и общения.',
      'link_image': 'assets/images/cart4.png',
      'status_id': 1,
    });

    await db.insert('products', {
      'uuid': uuid.v4(),
      'title': 'Умные часы',
      'description': 'Функциональные смарт-часы с мониторингом активности и уведомлениями со смартфона. '
          'Отслеживают шаги, пульс и уровень физической активности. '
          'Стильный дизайн позволяет носить их как на тренировке, так и в повседневной жизни.',
      'link_image': 'assets/images/cart5.png',
      'status_id': 1,
    });

    await db.insert('products', {
      'uuid': uuid.v4(),
      'title': 'Портативная колонка',
      'description': 'Компактная беспроводная колонка с мощным звучанием. '
          'Легко подключается к телефону через Bluetooth и обеспечивает стабильное соединение. '
          'Подходит для прогулок, поездок и отдыха на природе.',
      'link_image': 'assets/images/cart6.png',
      'status_id': 1,
    });

    await db.insert('products', {
      'uuid': uuid.v4(),
      'title': 'Кружка с термоизоляцией',
      'description': 'Термокружка из нержавеющей стали, сохраняющая температуру напитков '
          'в течение нескольких часов. Удобная крышка предотвращает проливание, '
          'а компактный размер позволяет брать её с собой в дорогу.',
      'link_image': 'assets/images/cart7.png',
      'status_id': 2,
    });

    await db.insert('products', {
      'uuid': uuid.v4(),
      'title': 'Настольная лампа',
      'description': 'Современная настольная лампа с регулируемой яркостью. '
          'Подходит для работы, учёбы или чтения вечером. '
          'Минималистичный дизайн хорошо вписывается в интерьер рабочего стола.',
      'link_image': 'assets/images/cart8.png',
      'status_id': 1,
    });
  }

  //Functions

  Future<int> getRoleIdByCode(String code) async {
    final db = await database;
    final rows = await db.query(
      'roles',
      columns: ['id'],
      where: 'code = ?',
      whereArgs: [code],
      limit: 1,
    );
    return rows.first['id'] as int;
  }

  Future<int> getStatusIdByCode(String code) async {
    final db = await database;
    final rows = await db.query(
      'product_statuses',
      columns: ['id'],
      where: 'code = ?',
      whereArgs: [code],
      limit: 1,
    );
    return rows.first['id'] as int;
  }

  Future<int> getActionTypeIdByCode(String code) async {
    final db = await database;
    final rows = await db.query(
      'action_types',
      columns: ['id'],
      where: 'code = ?',
      whereArgs: [code],
      limit: 1,
    );
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
    required String uuid,
    required String title,
    required String description,
    required String linkImage,
    required int statusId,
  }) async {
    final db = await database;
    return db.insert('products', {
      'uuid': uuid,
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

  Future<Map<String, dynamic>?> getProductByUuid(String uuid) async {
    final db = await database;
    final rows = await db.query(
      'products',
      where: 'uuid = ?',
      whereArgs: [uuid],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
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

  Future<int?> getLastUserIdByProductId(int productId) async {
    final db = await database;
    final rows = await db.query(
      'actions',
      columns: ['user_id'],
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return rows.first['user_id'] as int;
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



}