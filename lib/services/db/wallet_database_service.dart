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
import '../../models/wallet/wallet.dart';

class WalletDatabaseService {
  final log = getLogger('WalletDatabaseService');

  static const _databaseName = 'wallet_database_paycool.db';
  final String tableName = 'wallet';
  // database table and column names
  final String columnId = 'id';
  final String columnName = 'name';
  final String columnTickerName = 'tickerName';
  final String columnTokenType = 'tokenType';
  final String columnAddress = 'address';
  final String columnLockedBalance = 'lockedBalance';
  final String columnAvailableBalance = 'availableBalance';
  final String columnUsdValue = 'usdValue';
  final String columnInExchange = 'inExchange';

  static const _databaseVersion = 2;
  String path = '';

  static Database? _database;

  Future<Database> get database async => _database ??= await initDb();
  Future<Database> initDb() async {
    var databasePath = await getDatabasesPath();
    path = join(databasePath, _databaseName);
    log.w(path);
    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    log.i('in on create $db');
    await db.execute(''' CREATE TABLE $tableName
        (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT,
        $columnTickerName TEXT,
        $columnTokenType TEXT,
        $columnAddress TEXT,
        $columnLockedBalance REAL,
        $columnAvailableBalance REAL,
        $columnUsdValue REAL,
        $columnInExchange REAL) ''');
  }

  // Get All Records From The Database

  Future<List<WalletInfo>> getAll() async {
    //await deleteDb();
    await initDb();
    final Database db = await database;
    log.w('getall $db');

    // res is giving me the same output in the log whether i map it or just take var res
    final List<Map<String, dynamic>> res = await db.query(tableName);
    log.w('res $res');

    List<WalletInfo> list =
        res.isNotEmpty ? res.map((f) => WalletInfo.fromJson(f)).toList() : [];
    return list;
  }

// Insert Data In The Database
  Future insert(WalletInfo walletInfo) async {
    final Database db = await database;

    int id = await db.insert(tableName, walletInfo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return id;
  }

  // Get Single Wallet By Name
  Future<WalletInfo?> getByName(String name) async {
    final Database db = await database;
    List<Map<String, dynamic>> res =
        await db.query(tableName, where: 'name= ?', whereArgs: [name]);
    log.w('ID - $name --- $res');
    if (res.isNotEmpty) {
      return WalletInfo.fromJson((res.first));
    }
    return null;
  }

  // Get Single Wallet By tickerName
  Future<WalletInfo?> getWalletBytickerName(String tickerName) async {
    final Database db = await database;
    List<Map<String, dynamic>> res = await db
        .query(tableName, where: 'tickerName= ?', whereArgs: [tickerName]);
    log.w('tickerName - $tickerName --res - $res');
    if (res.isNotEmpty) {
      return WalletInfo.fromJson((res.first));
    }
    return null;
  }

  // Get Single Wallet By Id
  Future getById(int id) async {
    final Database db = await database;
    List<Map<String, dynamic>> res =
        await db.query(tableName, where: 'id= ?', whereArgs: [id]);
    // log.w('ID - $id --- $res');
    if (res.isNotEmpty) {
      return WalletInfo.fromJson((res.first));
    }
    return null;
  }

  // Delete Single Object From Database By Id
  Future<void> deleteWallet(int id) async {
    final db = await database;
    await db.delete(tableName, where: "id = ?", whereArgs: [id]);
  }

  // Delete Single Object From Database By tickerName
  Future<void> deleteWalletByTickerName(String tickerName) async {
    final db = await database;
    await db
        .delete(tableName, where: "tickerName = ?", whereArgs: [tickerName]);
  }

  // Update database
  Future<void> update(WalletInfo walletInfo) async {
    final Database db = await database;
    await db.update(
      tableName,
      walletInfo.toJson(),
      where: "id = ?",
      whereArgs: [walletInfo.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Close Database
  Future closeDb() async {
    var db = await database;
    return db.close();
  }

  // Delete Database
  Future deleteDb() async {
    log.i('database path $path');
    await deleteDatabase(path);
    var databasePath = await getDatabasesPath();
    var p = join(databasePath, _databaseName);

    log.w('database path after delete $p');
    _database = null;
  }
}
