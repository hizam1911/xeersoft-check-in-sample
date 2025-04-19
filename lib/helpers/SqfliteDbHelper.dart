import 'package:xeersoft_check_ins/models/CheckInModel.dart';
import 'package:xeersoft_check_ins/models/UserModel.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../enums/UserRole.dart';
import '../services/SharedPreferencesServices.dart';

class SqfliteDbHelper {
  static final SqfliteDbHelper _instance = SqfliteDbHelper._internal();
  static Database? _database;

  factory SqfliteDbHelper() => _instance;
  SqfliteDbHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      print("db already initialized");
      return _database!;
    }
    _database = await _initDatabase();
    print("db initialized");
    await _initAdminAccount();
    print("admin acc initialized");
    return _database!;
  }

  Future<void> _initAdminAccount() async  {
    final user = UserModel(
      username: "admin",
      fullname: "admin",
      password: "admin",
      role: UserRole.admin,
    );
    int userId = await createUser(user.toMap());
    if (userId > 0) {
      print("userId is $userId");
      print("Admin created!");
    } else {
      if (userId == -1) {
        print("Admin exist!");
      } else {
        print("Error occured!");
      }
    }
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'app_database.db');

    return await openDatabase(
      path,
      version: 1, // Increment for schema changes (can be 2, 3 etc)
      onCreate: _onCreate,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'), // for FK support
      // onUpgrade: (db, oldVersion, newVersion) async { // Version management example (for future schema changes)
      //   if (oldVersion < 2) {
      //     await db.execute('ALTER TABLE items ADD COLUMN priority INTEGER DEFAULT 0');
      //   }
      // },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // User table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS ${UserModel.table} (
      ${UserModel.columnUserId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${UserModel.columnUsername} TEXT NOT NULL,
      ${UserModel.columnFullName} TEXT NOT NULL,
      ${UserModel.columnPassword} TEXT NOT NULL,
      ${UserModel.columnRole} TEXT NOT NULL,
      ${UserModel.columnCreatedAt} TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      ${UserModel.columnModifiedAt} TIMESTAMP
    )
  ''');

    // Check-In table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS ${CheckInModel.table} (
      ${CheckInModel.columnCheckInId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${CheckInModel.columnUserId} INTEGER NOT NULL,
      ${CheckInModel.columnCheckInDateTime} TIMESTAMP NOT NULL,
      ${CheckInModel.columnCheckInStatus} INTEGER NOT NULL,
      ${CheckInModel.columnCreatedAt} TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      ${CheckInModel.columnModifiedAt} TIMESTAMP,
      FOREIGN KEY (${CheckInModel.columnUserId}) REFERENCES ${UserModel.table}(${UserModel.columnUserId})
    )
  ''');

    // Add username index for faster login/lookup
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_user_username 
      ON ${UserModel.table}(${UserModel.columnUsername})
    ''');

    // Add role index for filter by role
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_user_role 
      ON ${UserModel.table}(${UserModel.columnRole})
    ''');

    // Composite index for date + status queries
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_checkin_date_status 
      ON ${CheckInModel.table}(
        DATE(${CheckInModel.columnCheckInDateTime}),
        ${CheckInModel.columnCheckInStatus}
      )
    ''');

    // User ID index for faster user-specific queries
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_checkin_userid 
      ON ${CheckInModel.table}(${CheckInModel.columnUserId})
    ''');

    // Date-only index for pure date queries
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_checkin_date 
      ON ${CheckInModel.table}(DATE(${CheckInModel.columnCheckInDateTime}))
    ''');
  }

  //----------------------------------------------------------------------------
  // User Table CRUD Operations ($UserModel.table)
  //----------------------------------------------------------------------------

  Future<int> createUser(Map<String, dynamic> user) async {
    final db = await database;

    // Check if username already exists
    List<Map<String, dynamic>> existingUsers = await db.query(
      UserModel.table,
      where: '${UserModel.columnUsername} = ?',
      whereArgs: [user[UserModel.columnUsername]],
      limit: 1,
    );

    if (existingUsers.isNotEmpty) {
      // Username already exists, return -1 or a custom error code
      return -1;
    }

    // Add createdAt field if not already present
    if (!user.containsKey(UserModel.columnCreatedAt) || user[UserModel.columnCreatedAt] == null) {
      DateTime dateTime = DateTime.now();
      String formattedDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime);
      user[UserModel.columnCreatedAt] = formattedDate;
    }

    // Insert new user if username does not exist
    return await db.insert(UserModel.table, user);
  }

  Future<Map<String, dynamic>?> readUser(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      UserModel.table,
      where: '${UserModel.columnUserId} = ?',
      whereArgs: [userId],
      limit: 1, // Ensures only one result is returned
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<UserModel?> getUserByUsernameAndPassword(String username, String pass) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      UserModel.table,
      where: '${UserModel.columnUsername} = ? AND ${UserModel.columnPassword} = ?',
      whereArgs: [username, pass],
      limit: 1, // Ensures only one result is returned
    );

    return results.isNotEmpty ? UserModel.fromMap(results.first) : null;
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      UserModel.table,
      where: '${UserModel.columnUsername} = ?',
      whereArgs: [username],
      limit: 1, // Ensures only one result is returned
    );

    return results.isNotEmpty ? UserModel.fromMap(results.first) : null;
  }

  Future<List<Map<String, dynamic>>> readAllUsers() async {
    final db = await database;
    return await db.query(UserModel.table);
  }

  Future<int> updateUser(int userId, Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      UserModel.table,
      user,
      where: '${UserModel.columnUserId} = ?',
      whereArgs: [userId],
    );
  }

  Future<int> deleteUser(int userId) async {
    final db = await database;
    return await db.delete(
      UserModel.table,
      where: '${UserModel.columnUserId} = ?',
      whereArgs: [userId],
    );
  }

  //----------------------------------------------------------------------------
  // CheckIn Table CRUD Operations ($CheckInModel.table)
  //----------------------------------------------------------------------------

  Future<int> createCheckIn(Map<String, dynamic> checkIn, int userId) async {
    final db = await database;

    // Get today's date in 'yyyy-MM-dd' format
    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Check if a record already exists for this user today with status true
    final existingRecords = await db.query(
      CheckInModel.table,
      where: "DATE(${CheckInModel.columnCheckInDateTime}) = ? AND ${CheckInModel.columnCheckInStatus} = ? AND ${CheckInModel.columnUserId} = ?",
      whereArgs: [todayDate, 1, userId],
    );

    if (existingRecords.isNotEmpty) {
      // record already exists, return -1 or a custom error code
      return -1;
    }

    // Add checkInDateTime field if not already present
    if (!checkIn.containsKey(CheckInModel.columnCheckInDateTime) || checkIn[CheckInModel.columnCheckInDateTime] == null) {
      DateTime dateTime = DateTime.now();
      String formattedDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime);
      checkIn[CheckInModel.columnCheckInDateTime] = formattedDate;
    }

    // Add createdAt field if not already present
    if (!checkIn.containsKey(CheckInModel.columnCreatedAt) || checkIn[CheckInModel.columnCreatedAt] == null) {
      DateTime dateTime = DateTime.now();
      String formattedDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime);
      checkIn[CheckInModel.columnCreatedAt] = formattedDate;
    }

    return await db.insert(CheckInModel.table, checkIn);
  }

  Future<Map<String, dynamic>?> readCheckIn(int checkInId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      CheckInModel.table,
      where: '${CheckInModel.columnCheckInId} = ?',
      whereArgs: [checkInId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> readAllCheckIns() async {
    final db = await database;
    return await db.query(CheckInModel.table);
  }

  Future<List<CheckInModel>> getCheckInsByUserId(int userId) async {
    final db = await database;
    final now = DateTime.now();

    // Get first and last day of current month
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    // Format dates to match database format ("YYYY-MM-DD HH:MM:SS")
    final formattedFirstDay = DateFormat('yyyy-MM-dd HH:mm:ss').format(firstDayOfMonth);
    final formattedLastDay = DateFormat('yyyy-MM-dd HH:mm:ss').format(lastDayOfMonth);

    final List<Map<String, dynamic>> maps = await db.query(
      CheckInModel.table,
      where: '''
      ${CheckInModel.columnUserId} = ? 
      AND ${CheckInModel.columnCheckInDateTime} >= ? 
      AND ${CheckInModel.columnCheckInDateTime} <= ?
    ''',
      whereArgs: [userId, formattedFirstDay, formattedLastDay],
      orderBy: '${CheckInModel.columnCheckInDateTime} DESC',
    );

    return List.generate(maps.length, (i) => CheckInModel.fromMap(maps[i]));
  }


  Future<int> updateCheckIn(int checkInId, Map<String, dynamic> checkIn) async {
    final db = await database;
    return await db.update(
      CheckInModel.table,
      checkIn,
      where: '${CheckInModel.columnCheckInId} = ?',
      whereArgs: [checkInId],
    );
  }

  Future<int> deleteCheckIn(int checkInId) async {
    final db = await database;
    return await db.delete(
      CheckInModel.table,
      where: '${CheckInModel.columnCheckInId} = ?',
      whereArgs: [checkInId],
    );
  }

  //----------------------------------------------------------------------------
  // Export/Import Database (Existing Methods)
  //----------------------------------------------------------------------------

  Future exportDatabase() async {
    final dbPath = await getDatabasesPath();
    final src = File(join(dbPath, 'app_database.db'));
    final dir = await getExternalStorageDirectory();
    final dest = File(join(dir!.path, 'app_database_export.db'));
    return await src.copy(dest.path);
  }

  Future importDatabase(File source) async {
    final dbPath = await getDatabasesPath();
    final dest = File(join(dbPath, 'app_database.db'));

    // Close existing database connection
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    await source.copy(dest.path);
    _database = await _initDatabase();
  }

  // services
  Future<bool> login(SharedPreferencesService sp, String username, String pass) async {
    try {
      UserModel? user = await getUserByUsernameAndPassword(username, pass);

      if (user != null) {
        print('User ID: ${user.userId}');
        print('Username: ${user.username}');
        print('Role: ${user.role}');

        if (user.userId == null) return false;
        SharedPreferencesService(sp.sharedPreferences).setUsername(user.username);
        SharedPreferencesService(sp.sharedPreferences).setRole(user.role.name);
        SharedPreferencesService(sp.sharedPreferences).setIsLoggedIn(true);
        return true;
      } else {
        print('User not found!');
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  int getTotalDaysInCurrentMonth() {
    final now = DateTime.now();
    final firstDayOfNextMonth = DateTime(now.year, now.month + 1, 1);
    final lastDayOfMonth = firstDayOfNextMonth.subtract(Duration(days: 1));
    return lastDayOfMonth.day;
  }

  Future<int> getTrueCheckInsCountForCurrentMonth(int userId) async {
    final db = await database;
    final now = DateTime.now();

    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final formattedStart = DateFormat('yyyy-MM-dd').format(monthStart);
    final formattedEnd = DateFormat('yyyy-MM-dd').format(monthEnd);

    final result = await db.rawQuery('''
      SELECT COUNT(DISTINCT DATE(${CheckInModel.columnCheckInDateTime})) as count
      FROM ${CheckInModel.table}
      WHERE ${CheckInModel.columnCheckInStatus} = 1
        AND ${CheckInModel.columnUserId} = ?
        AND DATE(${CheckInModel.columnCheckInDateTime}) >= DATE(?)
        AND DATE(${CheckInModel.columnCheckInDateTime}) <= DATE(?)
      ''', [
      userId,
      formattedStart,
      formattedEnd,
    ]);

    return result.first['count'] as int;
  }

  Future<int> getMissedCheckInsCount(int userId) async {
    final db = await database;
    final now = DateTime.now();

    // First day of current month at 00:00:00
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    // Yesterday or last day of previous month (if today is 1st)
    final yesterday = now.day == 1
        ? DateTime(now.year, now.month - 1, 1).subtract(Duration(days: 1))
        : now.subtract(Duration(days: 1));

    // Calculate total days in range (adjusted for month start)
    final totalDays = now.day == 1
        ? 0 // No days to check if it's 1st day of month
        : yesterday.difference(firstDayOfMonth).inDays + 1;

    // Early return if no days to check
    if (totalDays == 0) return 0;

    final result = await db.rawQuery('''
      SELECT DATE(${CheckInModel.columnCheckInDateTime}) as checkInDate
      FROM ${CheckInModel.table}
      WHERE ${CheckInModel.columnCheckInStatus} = 1
        AND ${CheckInModel.columnUserId} = ?
        AND ${CheckInModel.columnCheckInDateTime} >= ?
        AND ${CheckInModel.columnCheckInDateTime} <= ?
      GROUP BY checkInDate
      ''', [
      userId,
      firstDayOfMonth.toIso8601String(),
      yesterday.toIso8601String(),
    ]);

    return totalDays - result.length;
  }

  Future<int> getRemainingCheckInsCount(int userId) async {
    final now = DateTime.now();

    // Calculate start date (today or tomorrow)
    final checkInData = await getTodayCheckInWithTime(userId);
    bool hasCheckInToday = false;
    if (checkInData != null) {
      hasCheckInToday = checkInData[CheckInModel.columnCheckInStatus] == 1;
    }
    final startDate = hasCheckInToday
        ? DateTime(now.year, now.month, now.day + 1)  // Tomorrow
        : DateTime(now.year, now.month, now.day);     // Today

    // End of month calculation
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // Calculate remaining days (inclusive)
    final remainingDays = lastDayOfMonth.difference(startDate).inDays + 1;

    // Ensure non-negative result
    return remainingDays > 0 ? remainingDays : 0;
  }

  Future<Map<String, dynamic>?> getTodayCheckInWithTime(int userId) async {
    final db = await database;
    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final result = await db.rawQuery('''
    SELECT ${CheckInModel.columnCheckInDateTime}, ${CheckInModel.columnCheckInStatus}
    FROM ${CheckInModel.table}
    WHERE ${CheckInModel.columnUserId} = ?
      AND ${CheckInModel.columnCheckInStatus} = 1
      AND DATE(${CheckInModel.columnCheckInDateTime}) = ?
    LIMIT 1
  ''', [userId, todayDate]);

    return result.isNotEmpty ? result.first : null;
  }

  // read main db
  Future<List<String>> getTableNames() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");
      return tables.map((table) => table['name'] as String).toList();
    } catch (e) {
      throw Exception("Error fetching table names: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getTableData(String tableName) async {
    try {
      final db = await database;
      return await db.query(tableName);
    } catch (e) {
      throw Exception("Error fetching data from $tableName: $e");
    }
  }

  Future<List<String>> getTableColumns(String tableName) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> columns =
      await db.rawQuery("PRAGMA table_info('$tableName')");
      return columns.map((column) => column['name'] as String).toList();
    } catch (e) {
      throw Exception("Error fetching columns for $tableName: $e");
    }
  }
}
