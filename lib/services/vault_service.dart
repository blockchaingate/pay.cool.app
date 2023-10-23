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

import 'dart:io';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';

import '../logger.dart';
import '../utils/number_util.dart';

class VaultService {
  final log = getLogger('VaultService');

  // encrypt mnemonic

  String encryptData(String pass, String dataToEncrypt) {
    String userTypedKey = pass;
    int userKeyLength = userTypedKey.length;
    String fixed32CharKey = '';

    if (userKeyLength < 32) {
      fixed32CharKey = NumberUtil.fixed32Chars(userTypedKey, userKeyLength);
    } else {
      fixed32CharKey = userTypedKey.substring(0, 32);
    }
    final key = encrypt.Key.fromUtf8(fixed32CharKey);

    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(dataToEncrypt, iv: iv);
    return encrypted.base64;
  }

  // --------- decrypt mnemonic start here

  Future<String> decryptData(
    String userTypedKey,
    String encryptedBase64Data,
  ) async {
    try {
      encrypt.Encrypted encryptedText =
          encrypt.Encrypted.fromBase64(encryptedBase64Data);

      int userKeyLength = userTypedKey.length;
      String fixed32CharKey = '';

      if (userKeyLength < 32) {
        fixed32CharKey = NumberUtil.fixed32Chars(userTypedKey, userKeyLength);
      }
      final key = encrypt.Key.fromUtf8(
          fixed32CharKey.isEmpty ? userTypedKey : fixed32CharKey);

      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final decrypted = encrypter.decrypt(encryptedText, iv: iv);
      return decrypted;
    } catch (e) {
      log.e(
          "decryptMnemonic Couldn't read file -$e -- moving to decryptMnemonicV1");
      return await readEncryptedData(userTypedKey);
    }
  }

  Future secureMnemonic(String pass, String mnemonic) async {
    // _walletService.generateSeed(mnemonic);
    String userTypedKey = pass;
    final key = encrypt.Key.fromLength(32);
    final iv = encrypt.IV.fromUtf8(userTypedKey);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(mnemonic, iv: iv);
    await saveEncryptedData(encrypted.base64);
  }

/*----------------------------------------------------------------------
                Save Encrypted Data to Storage
----------------------------------------------------------------------*/

  Future saveEncryptedData(String data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/paycool_file.byte');
      await deleteEncryptedData().then((value) async {
        await file.writeAsString(data);
        log.w('Encrypted data saved in storage');
      });
    } catch (e) {
      log.e("Couldn't write encrypted datra to file!! $e");
    }
  }
/*----------------------------------------------------------------------
                Delete Encrypted Data
----------------------------------------------------------------------*/

  Future deleteEncryptedData() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/paycool_file.byte');
    await file
        .delete()
        .then((res) => log.w('Previous data in the stored file deleted $res'))
        .catchError((error) => log.e('Previous data deletion failed $error'));
  }
/*----------------------------------------------------------------------
                Read Encrypted Data from Storage
----------------------------------------------------------------------*/

  Future<String> readEncryptedData(String userPass) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/paycool_file.byte');

      String test = await file.readAsString();
      encrypt.Encrypted encryptedText = encrypt.Encrypted.fromBase64(test);
      final key = encrypt.Key.fromLength(32);
      final iv = encrypt.IV.fromUtf8(userPass);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final decrypted = encrypter.decrypt(encryptedText, iv: iv);
      return Future.value(decrypted);
    } catch (e) {
      log.e("Couldn't read file -$e");
      return Future.value('');
    }
  }
}
