/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: barry-ruprai@exchangily.com
*----------------------------------------------------------------------
*/

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../logger.dart';
import '../../models/shared/pair_decimal_config_model.dart';

class DecimalConfigDatabaseService {
  final log = getLogger('DecimalConfigDatabaseService');

  static const _databaseName = 'decimal_config_database.db';
  final String tableName = 'decimal_config';

  final String columnName = 'name';
  final String columnPriceDecimal = 'priceDecimal';
  final String columnQtyDecimal = 'qtyDecimal';

  static const _databaseVersion = 5;
  String path = '';

  static Database? _database;

  Future<Database> get database async => _database ??= await initDb();

  Future<Database> initDb() async {
    if (_database != null) return database;
    var databasePath = await getDatabasesPath();
    path = join(databasePath, _databaseName);
    log.w(path);

    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    log.e('in on create $db');
    await db.execute(''' CREATE TABLE $tableName
        (
        $columnName TEXT,
        $columnPriceDecimal INTEGER,    
        $columnQtyDecimal INTEGER) ''');
  }

  // Get All Records From The Database

  Future<List<PairDecimalConfig>> getAll() async {
    await initDb();
    final Database db = await database;
    log.w('getall $db');

    // res is giving me the same output in the log whether i map it or just take var res
    final List<Map<String, dynamic>> res = await db.query(tableName);
    log.w('res $res');
    List<PairDecimalConfig> list = res.isNotEmpty
        ? res.map((f) => PairDecimalConfig.fromJson(f)).toList()
        : [];
    return list;
  }

// Insert Data In The Database
  Future insert(PairDecimalConfig decimalConfig) async {
    await initDb();
    final Database db = await database;
    int id = await db.insert(tableName, decimalConfig.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  // Get Single Setting By Name
  Future<PairDecimalConfig> getByName(String name) async {
    await initDb();
    final Database db = await database;
    List<Map<String, dynamic>> res =
        await db.query(tableName, where: 'name= ?', whereArgs: [name]);
    log.w('Name - $name --- $res');

    // List<PairDecimalConfig> list = res.isNotEmpty
    //     ? res.map((f) => PairDecimalConfig.fromJson(f)).toList()
    //     : [];
    // return list;
    return PairDecimalConfig.fromJson((res.first));
  }

  // Close Database
  Future closeDb() async {
    var db = await database;
    return db.close();
  }

  // Delete Database
  Future deleteDb() async {
    log.w(path);
    await deleteDatabase(path);
    _database = null;
  }
}
