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
import '../../models/wallet/token_model.dart';

class TokenListDatabaseService {
  final log = getLogger('TokenListDatabaseService');

  static const _databaseName = 'token_list_database.db';
  final String tableName = 'token_list';
  // database table and column names
  final String columnId = 'id';
  final String columnDecimal = 'decimal';
  final String columnCoinName = 'coinName';
  final String columnChainName = 'chainName';
  final String columnTickerName = 'tickerName';
  final String columnTokenType = 'type';
  final String columnContract = 'contract';
  final String columnMinWithdraw = 'minWithdraw';
  final String columnFeeWithdraw = 'feeWithdraw';

  static const _databaseVersion = 5;
  static Database? _database;
  String path = '';

  Future<Database> get database async => _database ??= await initDb();
  Future<Database> initDb() async {
    //  deleteDb();
    if (_database != null) return database;
    var databasePath = await getDatabasesPath();
    path = join(databasePath, _databaseName);
    log.w('init db $path');

    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    log.e('in on create $db');
    await db.execute(''' CREATE TABLE $tableName
        (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnDecimal INTEGER,
        $columnCoinName TEXT,
        $columnChainName TEXT,
        $columnTickerName TEXT,
        $columnTokenType INTEGER,
        $columnContract TEXT,
        $columnMinWithdraw TEXT,
        $columnFeeWithdraw TEXT) ''');
  }

  // Get All Records From The Database

  Future<List<TokenModel>> getAll() async {
    await initDb();
    final Database db = await database;
    log.w('getall $db');

    // res is giving me the same output in the log whether i map it or just take var res
    final List<Map<String, dynamic>> res = await db.query(tableName);
    log.w('res $res');
    List<TokenModel> list =
        res.isNotEmpty ? res.map((f) => TokenModel.fromJson(f)).toList() : [];
    return list;
  }

// Insert Data In The Database
  Future insert(TokenModel passedToken) async {
    await initDb();
    int id;

    final Database db = await database;
    id = await db
        .insert(tableName, passedToken.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .whenComplete(
            () => log.w('${passedToken.tickerName} new entry in the token db'));
    // }
    return id;
  }

  // Get Single transaction By Name
  Future<TokenModel?> getByTickerName(String tickerName) async {
    await initDb();
    final Database db = await database;
    List<Map<String, dynamic>> res = await db
        .query(tableName, where: 'tickerName= ?', whereArgs: [tickerName]);
    log.i('Name - $tickerName - res-- $res');

    if (res.isNotEmpty) return TokenModel.fromJson(res.first);
    return null;
    // return TransactionHistory.fromJson((res.first));
  }

  // Get Single token By Name
  Future<TokenModel?> getByCointype(int? coinType) async {
    await initDb();
    final Database db = await database;
    List<Map<String, dynamic>> res =
        await db.query(tableName, where: 'type= ?', whereArgs: [coinType]);
    log.i('coinType - $coinType - res-- $res');

    if (res.isNotEmpty) return TokenModel.fromJson(res.first);
    return null;
  }

  // Get contract address By coinType
  Future<String?> getContractAddressByCoinType(int coinType) async {
    await initDb();
    final Database db = await database;
    List<Map<String, dynamic>> res =
        await db.query(tableName, where: 'type= ?', whereArgs: [coinType]);
    log.w('coinType - $coinType - res-- $res');

    if (res.isNotEmpty) return TokenModel.fromJson(res.first).contract;
    return null;
  }

  // Get coin type by tickername
  getCoinTypeByTickerName(String tickerName) async {
    await initDb();
    final Database db = await database;
    List<Map<String, dynamic>> res = await db.query(tableName,
        distinct: true,
        where: 'tickerName= ?',
        whereArgs: [tickerName],
        limit: 1);
    log.w('Name - $tickerName - res-- $res');
    int? tt = TokenModel.fromJson(res.first).coinType;
    log.i('token type $tt');

    if (res.isNotEmpty) return TokenModel.fromJson(res.first).coinType;

    return null;
    // return TransactionHistory.fromJson((res.first));
  }

  // Get tickername By coin type
  Future getTickerNameByCoinType(int coinType) async {
    await initDb();
    final Database db = await database;
    List<Map<String, dynamic>> res = await db.query(tableName,
        distinct: true, where: 'type= ?', whereArgs: [coinType], limit: 1);
    log.w('coin type - $coinType - res-- $res');
    String? ticker = TokenModel.fromJson(res.first).tickerName;
    log.i('ticker $ticker');

    if (res.isNotEmpty) return TokenModel.fromJson(res.first).tickerName;

    return null;
    // return TransactionHistory.fromJson((res.first));
  }

  // Get Single transaction By Id
  Future getById(int id) async {
    final Database db = await database;
    List<Map<String, dynamic>> res =
        await db.query(tableName, where: 'id= ?', whereArgs: [id]);
    log.w('ID - $id --- $res');
    if (res.isNotEmpty) {
      return TokenModel.fromJson((res.first));
    }
    return null;
  }

  // Update database
  Future<void> update(TokenModel token) async {
    final Database db = await database;
    await db.update(
      tableName,
      token.toJson(),
      where: "id = ?",
      whereArgs: [token.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // delete single token
  Future<void> deleteByTickerName(String tickerName) async {
    final db = await database;
    await db
        .delete(tableName, where: "tickerName = ?", whereArgs: [tickerName]);
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
    log.e('$_databaseName deleted');
    _database = null;
  }
}
