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
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../logger.dart';
import '../../models/wallet/core_wallet_model.dart';
import '../../utils/fab_util.dart';

class CoreWalletDatabaseService {
  final log = getLogger('CoreWalletDatabaseService');

  static const _databaseName = 'wallet_core.db';
  final String tableName = 'wallet_core';
  // database table and column names
  final String columnId = 'id';

  final String columnMnemonic = "mnemonic";
  final String columnWalletBalancesBody = "walletBalancesBody";

  static const _databaseVersion = 1;
  String path = '';

  // CoreWalletDatabaseService._privateConstructor();
  // static final CoreWalletDatabaseService instance =
  //     CoreWalletDatabaseService._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDb();
    return _database;
  }

  initDb() async {
    var databasePath = await getDatabasesPath();
    path = join(databasePath, _databaseName);
    log.w('initDB $path');

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    log.i('in on create $db');
    await db.execute(''' CREATE TABLE $tableName
        (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnMnemonic TEXT,
        $columnWalletBalancesBody TEXT) ''');
  }

  // Get All Records From The Database

  Future<CoreWalletModel> getAll() async {
    await initDb();
    final Database? db = await database;
    log.w('getall $db');

    // res is giving me the same output in the log whether i map it or just take var res
    final List<Map<String, dynamic>> res = await db!.query(tableName);
    log.w('res $res');

    CoreWalletModel walletCore = CoreWalletModel(walletBalancesBody: '');
    if (res.isNotEmpty) {
      walletCore = CoreWalletModel.fromJson(res.first);
      log.w('get all walletcoremodel ${walletCore.toJson()}');
    }
    return walletCore;
  }

  // Update database
  Future<void> update(CoreWalletModel coreWalletModel) async {
    final Database? db = await database;
    await db!.update(
      tableName,
      coreWalletModel.toJson(),
      where: "id = ?",
      whereArgs: [coreWalletModel.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Insert Data In The Database
  Future insert(CoreWalletModel walletCoreModel) async {
    final Database? db = await database;
    ;
    var dataToInsert = walletCoreModel.toJson();
    await db!
        .insert(tableName, dataToInsert,
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((resId) {
      log.w('core wallet inserted Id $resId');
    }).catchError((err) async {
      log.e('Insert failed -Catch $err');
      await deleteDb();
      await initDb();
      await insert(walletCoreModel);
    });
  }

  // Get encrypted mnemonic
  Future<String> getEncryptedMnemonic() async {
    await initDb();
    final Database? db = await database;
    //  if (db == null) await initDb();
    String encryptedMnemonic = '';
    List<Map> res = await db!.query(tableName, columns: [columnMnemonic]);
    if (res.isEmpty) {
      return encryptedMnemonic = '';
    }
    if (res[0]['mnemonic'] != null) {
      log.i('Encrypted Mnemonic --- ${res.first}');
      encryptedMnemonic = res.first['mnemonic'];
    }

    return encryptedMnemonic;
  }

  // Get wallet balance body
  Future<Map<dynamic, dynamic>?> getWalletBalancesBody() async {
    await initDb();
    final Database? db = await database;

    Map? finalRes;
    List<Map>? res =
        await db!.query(tableName, columns: [columnWalletBalancesBody]);
    try {
      log.i('wallet balances body --- ${res.first}');
      finalRes = res.first;
    } catch (err) {
      res = null;
    }

    return finalRes;
  }

  // getWalletAddressByTickerName
  Future<String> getWalletAddressByTickerName(String tickerName) async {
    final Database? db = await database;

    var fabUtils = FabUtils();
    String address = '';
    String passedTicker = '';
    List<Map> res = [];

    String finalRes = '';
    try {
      res = await db!.query(tableName, columns: [columnWalletBalancesBody]);
      if (tickerName == 'EXG') {
        passedTicker = tickerName;
        tickerName = 'FAB';
      }

      address = jsonToMap(res.first['walletBalancesBody'],
          '${tickerName.toLowerCase()}Address');
      finalRes =
          passedTicker == 'EXG' ? fabUtils.fabToExgAddress(address) : address;
      log.i(
          '${passedTicker.isEmpty ? tickerName : passedTicker} address ---finalRes $finalRes');
    } catch (err) {
      log.e("getWalletAddressByTickerName ticker $tickerName -  CATCH : $err");
    }
    return finalRes;
  }

  jsonToMap(String json, String chainName) {
    return jsonDecode(json)[chainName];
  }

  // Close Database
  Future closeDb() async {
    var db = await database;
    return db!.close();
  }

  // Delete Database
  Future deleteDb() async {
    log.i('database path $path');
    try {
      await deleteDatabase(path);
      var databasePath = await getDatabasesPath();
      var p = join(databasePath, _databaseName);

      log.w('database path after delete: $p');
      _database = null;
    } catch (err) {
      log.e('deleteDb CATCH $err');
    }
  }
}
