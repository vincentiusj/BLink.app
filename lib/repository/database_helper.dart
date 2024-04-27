import 'dart:io';

import 'package:blink_application/models/bus_model.dart';
import 'package:blink_application/models/route_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/GlobalConstants.dart';
import '../models/stop_model.dart';
import 'package:path_provider/path_provider.dart';



class DatabaseHelper {
  static Database? _database;
  static const String userTable = 'user';
  static const String routeTable = 'route';
  static const String stopTable = 'stop';
  static const String busTable = 'bus';

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'blink_app.db');

    return openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE $userTable (
            id INTEGER PRIMARY KEY,
            fullName TEXT,
            email TEXT,
            phoneNumber TEXT,
            role TEXT
          )
          ''',
        );
        await db.execute(
          '''
          CREATE TABLE $routeTable (
            id TEXT PRIMARY KEY,
            routeName TEXT
          )
          ''',
        );
        await db.execute(
          '''
          CREATE TABLE $stopTable (
            id TEXT PRIMARY KEY,
            routeId TEXT,
            stopName TEXT,
            'order' TEXT,
            latitude TEXT,
            longitude TEXT,
            FOREIGN KEY (routeId) REFERENCES Route(routeId)
          )
          ''',
        );

        await db.execute(
          '''
          CREATE TABLE $busTable (
            id TEXT PRIMARY KEY,
            routeId TEXT,
            busType TEXT,
            busColor TEXT,
            plateNumber TEXT,
            FOREIGN KEY (routeId) REFERENCES Route(routeId)
          )
          ''',
        );
      },
    );
  }

  static Future<void> insertOrUpdateRoutes(List<RouteModel> routes) async {
    final db = await database;

    for(var route in routes){
      List<Map<String, dynamic>> existingRecords = await db.query(
        routeTable,
        where: 'id = ?',
        whereArgs: [route.routeId],
      );

      if (existingRecords.isNotEmpty) {
        // Update the existing record
        await db.update(
          routeTable,
          route.toMap(),
          where: 'id = ?',
          whereArgs: [route.routeId],
        );
      } else {
        // Insert a new record
        await db.insert(
          routeTable,
          route.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort, // or choose another conflict resolution strategy
        );
      }

    }

  }

  static Future<void> insertOrUpdateBuses(List<Bus> buses) async {
    final db = await database;

    logger.d('insertBus ${buses}');

    for(var bus in buses) {
      List<Map<String, dynamic>> existingRecords = await db.query(
        busTable,
        where: 'id = ?',
        whereArgs: [bus.busId],
      );

      if (existingRecords.isNotEmpty) {
        // Update the existing record
        await db.update(
          busTable,
          bus.toMap(),
          where: 'id = ?',
          whereArgs: [bus.busId],
        );
      } else {
        // Insert a new record
        await db.insert(
          busTable,
          bus.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort, // or choose another conflict resolution strategy
        );
      }
    }
  }

  static Future<void> insertOrUpdateStops(List<Stop> stops) async {
    final db = await database;

    for(var stop in stops){
      List<Map<String, dynamic>> existingRecords = await db.query(
        stopTable,
        where: 'id = ?',
        whereArgs: [stop.stopId],
      );

      if (existingRecords.isNotEmpty) {
        // Update the existing record
        await db.update(
          stopTable,
          stop.toMap(),
          where: 'id = ?',
          whereArgs: [stop.stopId],
        );
      } else {
        // Insert a new record
        await db.insert(
          stopTable,
          stop.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort, // or choose another conflict resolution strategy
        );
      }
    }
  }

  static Future<List<Stop>> getAllStops() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(stopTable);

    logger.d('getAllStops $maps');
    // Convert the List<Map<String, dynamic>> into a List<Stop>
    return List.generate(maps.length, (i) {
      return Stop(
        stopId: maps[i]['id'],
        routeId: maps[i]['routeId'],
        stopName: maps[i]['stopName'],
        order: maps[i]['order'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
      );
    });
  }

  static Future<List<Bus>> getAllBus() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(busTable);

    logger.d('getAllBus $maps');
    // Convert the List<Map<String, dynamic>> into a List<Bus>
    return List.generate(maps.length, (i) {
      return Bus(
          busId: maps[i]['id'],
          routeId: maps[i]['routeId'],
          busColor: maps[i]['busColor'],
          busType: maps[i]['busType'],
          plateNumber: maps[i]['plateNumber']
      );
    });
  }

  static Future<List<RouteModel>> getAllRoutes() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(routeTable);

    logger.d('getAllRoutes $maps');
    // Convert the List<Map<String, dynamic>> into a List<Stop>
    return List.generate(maps.length, (i) {
      logger.d('getAllRoutes ${maps[i]['id']} | ${maps[i]['routeName']}');

      return RouteModel(
          routeId: maps[i]['id'],
          routeName: maps[i]['routeName']
      );
    });
  }


  static Future<void> captureDatabase() async {
    // Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // String path = join(documentsDirectory.path, 'blink_app.db');
    //
    // logger.d('captureDatabase');
    File sourceFile = File('/data/data/com.example.blink_application/databases/blink_app.db');

    if (await sourceFile.exists()) {
      String destinationPath = '/Users/exaud/OneDrive/Documents/BLink/blink_app.db';
      File destinationFile = File(destinationPath);

      // Ensure the destination directory exists
      await destinationFile.parent.create(recursive: true);

      // Copy the file
      await sourceFile.copy(destinationPath);
      logger.d('captureDatabase Database copied to: $destinationPath');
    } else {
      logger.d('captureDatabase Source file not found: $sourceFile');
    }
  }
}
