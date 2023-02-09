import 'dart:convert';

import 'package:bitbox/bitbox.dart' as bitbox;
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'dart:async';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:hex/hex.dart';
import 'package:paycool/services/config_service.dart';
import 'package:paycool/services/local_dialog_service.dart';
import 'package:paycool/utils/string_util.dart';
import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
import '../constants/colors.dart';
import '../constants/constants.dart';
import '../environments/coins.dart' as coin_list;
import '../logger.dart';
import '../models/wallet/core_wallet_model.dart';
import '../models/wallet/token_model.dart';
import '../models/wallet/transaction_history.dart';
import '../models/wallet/user_settings_model.dart';
import '../models/wallet/wallet.dart';
import '../service_locator.dart';
import '../shared/ui_helpers.dart';
import '../utils/abi_util.dart';
import '../utils/btc_util.dart';
import '../utils/custom_http_util.dart';
import '../utils/exaddr.dart';
import '../utils/ltc_util.dart';
import '../utils/number_util.dart';
import '../utils/string_util.dart' as string_utils;
import '../utils/kanban.util.dart';
import '../utils/keypair_util.dart';
import '../utils/eth_util.dart';
import '../utils/fab_util.dart';
import '../utils/coin_util.dart' as coin_util;

import 'package:bitcoin_flutter/src/utils/script.dart' as script;
import '../environments/environment.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:decimal/decimal.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart' as BitcoinFlutter;
import '../utils/wallet_coin_address_utils/doge_util.dart';
import 'api_service.dart';
import 'coin_service.dart';
import 'db/core_wallet_database_service.dart';
import 'db/token_list_database_service.dart';
import 'db/transaction_history_database_service.dart';
import 'package:web3dart/crypto.dart' as CryptoWeb3;
import 'package:crypto/crypto.dart' as CryptoHash;

import 'db/user_settings_database_service.dart';
import 'db/wallet_database_service.dart';
import 'local_storage_service.dart';
import 'shared_service.dart';
import 'vault_service.dart';

import 'package:paycool/utils/tron_util/trx_generate_address_util.dart'
    as TronAddressUtil;
import 'package:paycool/utils/tron_util/trx_transaction_util.dart'
    as TronTransactionUtil;

class WalletService {
  final log = getLogger('Wallet Service');

  final client = CustomHttpUtil.createLetsEncryptUpdatedCertClient();
  TokenListDatabaseService tokenListDatabaseService =
      locator<TokenListDatabaseService>();
  final ApiService _api = locator<ApiService>();
  WalletDatabaseService walletDatabaseService =
      locator<WalletDatabaseService>();
  SharedService sharedService = locator<SharedService>();
  final storageService = locator<LocalStorageService>();
  TransactionHistoryDatabaseService transactionHistoryDatabaseService =
      locator<TransactionHistoryDatabaseService>();
  final ApiService _apiService = locator<ApiService>();
  final coinService = locator<CoinService>();

  final coreWalletDatabaseService = locator<CoreWalletDatabaseService>();
  double? currentTickerUsdValue;
  var txids = [];
  ConfigService configService = locator<ConfigService>();
  final dialogService = locator<LocalDialogService>();

  double? coinUsdBalance;
  List<String> coinTickers = [
    'BTC',
    'ETH',
    'FAB',
    'EXG',
    'USDT',
    'DUSD',
    'TRX',
    'BCH',
    'LTC',
    'DOGE',
    'INB',
    'DRGN',
    'HOT',
    'CEL',
    'MATIC',
    'IOST',
    'MANA',
    'WAX',
    'ELF',
    'GNO',
    'POWR',
    'WINGS',
    'MTL',
    'KNC',
    'GVT'
  ];

  List<String> tokenType = [
    '',
    '',
    '',
    'FAB',
    'ETH',
    'FAB',
    '',
    '',
    '',
    '',
    'ETH',
    'ETH',
    'ETH',
    'ETH',
    'ETH',
    'ETH',
    'ETH',
    'ETH',
    'ETH',
    'ETH',
    'ETH',
    'ETH',
    'ETH',
    'ETH',
    'ETH'
  ];

  List<String> coinNames = [
    'Bitcoin',
    'Ethereum',
    'Fabcoin',
    'Exchangily',
    'Tether',
    'DUSD',
    'Tron',
    'Bitcoin Cash',
    'Litecoin',
    'Dogecoin',
    'Insight chain',
    'Dragonchain',
    'Holo',
    'Celsius',
    'Matic Network',
    'IOST',
    'Decentraland',
    'Wax',
    'aelf',
    'Gnosis',
    'Power Ledger',
    'Wings',
    'Metal',
    'Kyber Network',
    'Genesis Vision'
  ];

  var fabUtils = FabUtils();

  // verify wallet address
  Future<Map<String, bool>> verifyWalletAddresses(String mnemonic) async {
    Map<String, bool> res = {
      "fabAddressCheck": false,
      "trxAddressCheck": false
    };

    // create wallet address and assign to walletcoremodel object
    CoreWalletModel walletDataFromCreateOfflineWalletV1 =
        await createOfflineWalletsV1(mnemonic, '', isVerifying: true);
    String fabAddressFromCreate = jsonDecode(
        walletDataFromCreateOfflineWalletV1.walletBalancesBody)['fabAddress'];
    String trxAddressFromCreate = jsonDecode(
        walletDataFromCreateOfflineWalletV1.walletBalancesBody)['trxAddress'];

    // get the walletbalancebody from the DB
    var walletBalancesBodyFromStorage;
    if (storageService.walletBalancesBody.isNotEmpty) {
      walletBalancesBodyFromStorage =
          jsonDecode(storageService.walletBalancesBody);
    } else {
      await walletDatabaseService.initDb();
      var fabWallet = await walletDatabaseService.getWalletBytickerName('FAB');
      var trxWallet = await walletDatabaseService.getWalletBytickerName('TRX');
      if (fabWallet != null && trxWallet != null) {
        walletBalancesBodyFromStorage = {
          "fabAddress": fabWallet.address,
          "trxAddress": trxWallet.address
        };
      }
    }

    // Compare the address if matched then don't notify otherwise raise flag

    String fabAddressFromStorage = '';
    String trxAddressFromStorage = '';

    String fabAddressFromCoreWalletDb = '';
    String trxAddressFromCoreWalletDb = '';

    if (walletBalancesBodyFromStorage != null) {
      fabAddressFromStorage = walletBalancesBodyFromStorage['fabAddress'];

      trxAddressFromStorage = walletBalancesBodyFromStorage['trxAddress'];
    } else if (await coreWalletDatabaseService.getWalletBalancesBody() !=
        null) {
      fabAddressFromCoreWalletDb =
          await coreWalletDatabaseService.getWalletAddressByTickerName('FAB');
      trxAddressFromCoreWalletDb =
          await coreWalletDatabaseService.getWalletAddressByTickerName('TRX');
    }
    log.i(
        'fabAddressFromCreate $fabAddressFromCreate -- fabAddressFromStorage $fabAddressFromStorage -- fabAddressFromCoreWalletDb $fabAddressFromCoreWalletDb');
    var fabAddressFromStorageToCompare = fabAddressFromStorage.isEmpty
        ? fabAddressFromCoreWalletDb
        : fabAddressFromStorage;
    var trxAddressFromStorageToCompare = trxAddressFromStorage.isEmpty
        ? trxAddressFromCoreWalletDb
        : trxAddressFromStorage;
    if (fabAddressFromCreate == fabAddressFromStorageToCompare) {
      res["fabAddressCheck"] = true;
      log.w('FabVerification passed $res');
      if (trxAddressFromCreate == trxAddressFromStorageToCompare) {
        res["trxAddressCheck"] = true;
        log.i('Trx Verification passed $res');
        // need to store the wallet balance body in the
        // new single db especially for older apps where
        // there is no concept of walletBalancesBody or
        // app before new wallet balance api
        var walletCoreModel = CoreWalletModel(
          id: 1,
          walletBalancesBody:
              walletDataFromCreateOfflineWalletV1.walletBalancesBody,
        );
        // store in single core database
        await coreWalletDatabaseService.update(walletCoreModel);
      } else {
        res["trxAddressCheck"] = false;
      }
    } else {
      res["fabAddressCheck"] = false;
      log.e('Verification FAILED: did not check TRX $res');
    }
    return res;
  }

  storeTokenListUpdatesInDB() async {
    debugPrint(
        'Store token TIME START ${DateTime.now().toLocal().toIso8601String()}');
    List existingTokensInTokenDatabase;
    try {
      existingTokensInTokenDatabase = await tokenListDatabaseService.getAll();
    } catch (err) {
      existingTokensInTokenDatabase = [];
      log.e('getTokenList tokenListDatabaseService.getAll CATCH err $err');
    }
    await _apiService
        .getTokenListUpdates()
        .then((newTokenListFromTokenUpdateApi) async {
      if (newTokenListFromTokenUpdateApi.isNotEmpty) {
        // existingTokensInTokenDatabase = [];
        if (existingTokensInTokenDatabase.length !=
            newTokenListFromTokenUpdateApi.length) {
          await tokenListDatabaseService.deleteDb().whenComplete(() => log.e(
              'token list database cleared before inserting updated token data from api'));

          /// Fill the token list database with new data from the api

          for (var singleNewToken in newTokenListFromTokenUpdateApi) {
            await tokenListDatabaseService.insert(singleNewToken);
          }
        } else {
          log.i('storeTokenListInDB -- local token db same length as api\'s ');
        }
      }
    });
    debugPrint(
        'Store token TIME FINISH ${DateTime.now().toLocal().toIso8601String()}');
  }
/*----------------------------------------------------------------------
                Check coin wallet balance
----------------------------------------------------------------------*/

  Future<bool> checkCoinWalletBalance(double amount, String tickerName) async {
    bool isCorrectAmount = true;

    String fabAddress =
        await sharedService.getFabAddressFromCoreWalletDatabase();
    String thirdPartyAddress =
        await coinService.getCoinWalletAddress(tickerName);
    log.w('thirdPartyAddress wallet address $thirdPartyAddress');
    await _apiService
        .getSingleWalletBalance(fabAddress, tickerName, thirdPartyAddress)
        .then((walletBalance) {
      log.w(walletBalance[0].balance);
      if (walletBalance[0].balance! < amount) {
        isCorrectAmount = false;
      } else {
        isCorrectAmount = true;
      }
    }).catchError((err) {
      log.e(err);

      throw Exception(err);
    });
    return isCorrectAmount;
  }

/*----------------------------------------------------------------------
                Update special tokens tickername in UI
----------------------------------------------------------------------*/
  updateSpecialTokensTickerNameForTxHistory(String tickerName) {
    String logoTicker = '';
    if (tickerName.toUpperCase() == 'ETH_BST' ||
        tickerName.toUpperCase() == 'BSTE') {
      tickerName = 'BST(ERC20)';
      logoTicker = 'BSTE';
    } else if (tickerName.toUpperCase() == 'ETH_DSC' ||
        tickerName.toUpperCase() == 'DSCE') {
      tickerName = 'DSC(ERC20)';
      logoTicker = 'DSCE';
    } else if (tickerName.toUpperCase() == 'ETH_EXG' ||
        tickerName.toUpperCase() == 'EXGE') {
      tickerName = 'EXG(ERC20)';
      logoTicker = 'EXGE';
    } else if (tickerName.toUpperCase() == 'ETH_FAB' ||
        tickerName.toUpperCase() == 'FABE') {
      tickerName = 'FAB(ERC20)';
      logoTicker = 'FABE';
    } else if (tickerName.toUpperCase() == 'TRON_USDT' ||
        tickerName.toUpperCase() == 'USDTX') {
      tickerName = 'USDT(TRC20)';
      logoTicker = 'USDTX';
    } else {}
    return {"tickerName": tickerName, "logoTicker": logoTicker};
  }

  // addTxids(allTxids) {
  //   txids = [...txids, ...allTxids].toSet().toList();
  // }

  storeTokenListInDB() async {
    List existingTokensInTokenDatabase;
    try {
      existingTokensInTokenDatabase = await tokenListDatabaseService.getAll();
    } catch (err) {
      existingTokensInTokenDatabase = [];
      log.e('getTokenList tokenListDatabaseService.getAll CATCH err $err');
    }
    List<TokenModel> newTokenListFromTokenUpdateApi = [];
    await _apiService.getTokenListUpdates().then((tokenList) {
      if (tokenList != null) {
        log.w(
            'getTokenListUpdates token list from api length ${tokenList.length}');
        newTokenListFromTokenUpdateApi = tokenList;
      }
    }).catchError((err) {
      log.e('getTokenListUpdates Catch $err');
    });
    //  await getTokenListUpdates().then((newTokenListFromTokenUpdateApi) async {
    if (newTokenListFromTokenUpdateApi != null &&
        newTokenListFromTokenUpdateApi.isNotEmpty) {
      existingTokensInTokenDatabase ??= [];
      if (existingTokensInTokenDatabase.length !=
          newTokenListFromTokenUpdateApi.length) {
        await tokenListDatabaseService.deleteDb().whenComplete(() => log.e(
            'token list database cleared before inserting updated token data from api'));

        /// Fill the token list database with new data from the api

        for (var singleNewToken in newTokenListFromTokenUpdateApi) {
          await tokenListDatabaseService.insert(singleNewToken);
        }
      } else {
        log.i('storeTokenListInDB -- local token db same length as api\'s ');
      }
    }
    //  });
  }

  /*----------------------------------------------------------------------
                    Check Language
----------------------------------------------------------------------*/
  Future checkLanguage(context) async {
    UserSettingsDatabaseService userSettingsDatabaseService =
        locator<UserSettingsDatabaseService>();
    //lang = storageService.language;

    await userSettingsDatabaseService.getAll().then((res) async {
      if (res == [] || res.isEmpty) {
        log.e('language empty- setting english');
        storageService.language = "en";
        // AppLocalizations.load(Locale('en', 'EN'));
        await FlutterI18n.refresh(context, const Locale('en', 'EN'));
      } else {
        String languageFromDb = res[0].language!;
        // AppLocalizations.load(
        //     Locale(languageFromDb, languageFromDb.toUpperCase()));
        await FlutterI18n.refresh(
            context, Locale(languageFromDb, languageFromDb.toUpperCase()));
        storageService.language = languageFromDb;

        log.i('language $languageFromDb found');
      }
      (context as Element).markNeedsBuild();
    }).catchError((err) => log.e('user setting db empty'));
  }

  updateUserSettingsDb(UserSettings userSettings, isUserSettingsEmpty) async {
    UserSettingsDatabaseService userSettingsDatabaseService =
        locator<UserSettingsDatabaseService>();
    isUserSettingsEmpty
        ? await userSettingsDatabaseService
            .insert(userSettings)
            .then((value) => null)
            .catchError((err) async {
            log.e(
                'In updateUserSettingsDb -- INSERT Catch- deleting the database and re-inserting the data');
            await userSettingsDatabaseService.deleteDb().then((value) => () {
                  userSettingsDatabaseService.insert(userSettings);
                });
          })
        : await userSettingsDatabaseService
            .update(userSettings)
            .then((value) => null)
            .catchError((err) async {
            log.e(
                'In updateUserSettingsDb -- UPDATE Catch- deleting the database and re-inserting the data');
            await userSettingsDatabaseService.deleteDb().then((value) => () {
                  userSettingsDatabaseService.update(userSettings);
                });
          });
    await userSettingsDatabaseService.getAll();
  }

/*----------------------------------------------------------------------
                Get Random Mnemonic
----------------------------------------------------------------------*/
  String getRandomMnemonic() {
    String randomMnemonic = '';

    randomMnemonic = bip39.generateMnemonic();
    return randomMnemonic;
  }

/*----------------------------------------------------------------------
                Generate Seed
----------------------------------------------------------------------*/

  Future<Uint8List> getSeedDialog(BuildContext context) async {
    var seed;
    await dialogService
        .showDialog(
            title: FlutterI18n.translate(context, "enterPassword"),
            description: FlutterI18n.translate(
                context, "dialogManagerTypeSamePasswordNote"),
            buttonTitle: FlutterI18n.translate(context, "confirm"))
        .then((res) async {
      if (res.confirmed) {
        String mnemonic = res.returnedText;

        seed = generateSeed(mnemonic);
      } else if (res.returnedText == 'Closed' && !res.confirmed) {
        log.e('Dialog Closed By User');
      } else {
        log.e('Wrong pass');

        sharedService.sharedSimpleNotification(
            FlutterI18n.translate(context, "pleaseProvideTheCorrectPassword"));
      }
    }).catchError((error) {
      log.e(error);
    });
    return seed;
  }

  generateSeed(String mnemonic) {
    Uint8List seed = bip39.mnemonicToSeed(mnemonic);
    log.w('Seed $seed');
    return seed;
  }

  generateBip32Root(Uint8List seed) {
    var root = bip32.BIP32.fromSeed(seed);
    return root;
  }

  sha256Twice(bytes) {
    var digest1 = CryptoHash.sha256.convert(bytes);
    var digest2 = CryptoHash.sha256.convert(digest1.bytes);
    //SHA256(addressHex);
    log.w('digest2  -- ${digest2.toString()}');
    return digest2;
  }

/*----------------------------------------------------------------------
                    Generate TRX address
----------------------------------------------------------------------*/

  generateTrxAddress(String mnemonic) {
    var seed = generateSeed(mnemonic);
    var root = generateBip32Root(seed);
    debugPrint('root ${root.toString()}');
    String ct = '195';
    bip32.BIP32 node = root.derivePath("m/44'/$ct'/0'/0/${0}");
    debugPrint('node ${node.toString()}');
    var privKey = node.privateKey;

    //  var pubKey = node.publicKey;
    //  log.w('pub key $pubKey -- length ${pubKey.length}');
    var uncompressedPubKey =
        BitcoinFlutter.ECPair.fromPrivateKey(privKey!, compressed: false)
            .publicKey;

    if (uncompressedPubKey!.length == 65) {
      uncompressedPubKey = uncompressedPubKey.sublist(1);
    }

    var hash = CryptoWeb3.keccak256(uncompressedPubKey);

// take 20 bytes at the end from hash
    var last20Bytes = hash.sublist(12);

    List<int> updatedHash = [];
    //  var addressHex = Uint8List.fromList(hash);
    int i = 1;
    for (var f in last20Bytes) {
      if (i == 1) {
        updatedHash.add(65);
        i++;
      }
      updatedHash.add(f);
      i++;
    }

    // take 0x41 or 65 + (hash[12:32] means take last 20 bytes from addressHex)
    // to do sha256 twice and get 4 bytes checksum
    var sha256Hash = sha256Twice(updatedHash);

    // first 4 bytes checksum
    var checksum = sha256Hash.bytes.sublist(0, 4);

    updatedHash.addAll(checksum);

    // use base58 on (0x41 + hash[12:32] + checksum)
    // or base 58 on updateHash which first need to convert to Iint8List to get address
    Uint8List uIntUpdatedHash = Uint8List.fromList(updatedHash);
    var address = bs58check.base58.encode(uIntUpdatedHash);
    debugPrint('address $address');
    return address;
  }

  computeAddress(String pubBytes) {
    if (pubBytes.length == 65) pubBytes = pubBytes.substring(1);
    // var signature = sign(keccak256(concat), privateKey);

    var hash = CryptoWeb3.keccakUtf8(pubBytes);

    //   var addressHex = "41" + hash.substring(24);
    //   debugPrint('address hex $addressHex');
    //var output = hex.encode(outputHashData);
    //  return hexStr2byteArray(addressHex);
  }

// Get address From Private Key
  getAddressFromPrivKey(privKey) {
    //ProtobufEnum.initByValue(byIndex)
  }

/*----------------------------------------------------------------------
               Generate BCH address
----------------------------------------------------------------------*/

  Future<String> generateBchAddress(seed) async {
    String tickerName = 'BCH';

    final masterNode = bitbox.HDNode.fromSeed(seed);
    var coinType = environment["CoinType"][tickerName].toString();
    final accountDerivationPath = "m/44'/$coinType'/0'/0";
    final accountNode = masterNode.derivePath(accountDerivationPath);
    final accountXPriv = accountNode.toXPriv();
    final childNode = accountNode.derive(0);
    final address = childNode.toCashAddress();
    // final address = cashAddress.split(":")[1];
    // try {
    //   await getBchAddressDetails(address);
    // } catch (err) {
    //   log.e('getBchAddressDetails CATCH $err');
    // }

    return address;
  }

  // get BCH address details
  Future getBchAddressDetails(String bchAddress) async {
    final addressDetails = await bitbox.Address.details(bchAddress);
    log.e('Address $bchAddress -- address details $addressDetails');
    return addressDetails;
  }

  // Generate LTC address
  generateDogeAddress(String mnemonic, {index = 0}) async {
    String tickerName = 'DOGE';

    var seed = generateSeed(mnemonic);
    var root = generateBip32Root(seed);
    // var coinType = environment["CoinType"]["$tickerName"].toString();
    //  log.w('coin type $coinType');
    var node = root.derivePath("m/44'/3'/0'/0/$index");

    String? address1 = BitcoinFlutter.P2PKH(
            data: BitcoinFlutter.PaymentData(pubkey: node.publicKey),
            network: dogeCoinMainnetNetwork)
        .data
        .address;
    debugPrint('ticker: $tickerName --  address1: $address1');

    // String address = '';

    // final keyPair = ECPair.makeRandom(network: liteCoinNetworkType);
    // debugPrint('keyPair: ${keyPair.publicKey}');

    // address = new P2PKH(
    //         data: new BitcoinFlutter.PaymentData(pubkey: keyPair.publicKey),
    //         network: liteCoinNetworkType)
    //     .data
    //     .address;
    // log.w('$address');
    return address1;
  }

/*----------------------------------------------------------------------
                    Get Coin Address
----------------------------------------------------------------------*/
  Future getCoinAddresses(String mnemonic) async {
    var seed = generateSeed(mnemonic);
    var root = bip32.BIP32.fromSeed(seed);
    for (int i = 0; i < coinTickers.length; i++) {
      var tickerName = coinTickers[i];
      var addr = await coin_util.getAddressForCoin(root, tickerName,
          tokenType: tokenType[i]);
      log.w('name $tickerName - address $addr');
      return addr;
    }
  }
/*----------------------------------------------------------------------
                Future Get Coin Balance By Address
----------------------------------------------------------------------*/

  Future coinBalanceByAddress(
      String name, String address, String tokenType) async {
    log.w(' coinBalanceByAddress $name $address $tokenType');
    var bal = await coin_util.getCoinBalanceByAddress(name, address,
        tokenType: tokenType);
    log.w('coinBalanceByAddress $name - $bal');

    // if (bal == null) {
    //   debugPrint('coinBalanceByAddress $name- bal $bal');
    //   return 0.0;
    // }
    return bal;
  }

  Future getEthGasPrice() async {
    var gasPrice = await _apiService.getEthGasPrice();
    return gasPrice;
  }

/*----------------------------------------------------------------------
                Get Coin Price By Web Sockets
----------------------------------------------------------------------*/

  // getCoinPriceByWebSocket(String pair) {
  //   currentUsdValue = 0;
  //   final channel = IOWebSocketChannel.connect(
  //       Constants.COIN_PRICE_DETAILS_WS_URL,
  //       pingInterval: Duration(minutes: 1));

  //   channel.stream.listen((prices) async {
  //     List<Price> coinListWithPriceData = Decoder.fromJsonArray(prices);
  //     for (var i = 0; i < coinListWithPriceData.length; i++) {
  //       if (coinListWithPriceData[i].symbol == 'EXGUSDT') {
  //         var d = coinListWithPriceData[i].price;
  //         currentUsdValue = stringUtils.bigNum2Double(d);
  //       }
  //     }
  //   });
  //   Future.delayed(Duration(seconds: 2), () {
  //     channel.sink.close();
  //     log.i('Channel closed');
  //   });
  // }

/*----------------------------------------------------------------------
                Get Current Market Price For The Coin By Name
----------------------------------------------------------------------*/

  Future<double?> getCoinMarketPriceByTickerName(String tickerName) async {
    currentTickerUsdValue = 0;
    if (tickerName == 'DUSD') {
      return currentTickerUsdValue = 1.0;
    }
    await _apiService.getCoinCurrencyUsdPrice().then((res) {
      if (res != null) {
        currentTickerUsdValue = res['data'][tickerName]['USD'].toDouble();
        log.i('getting price for $tickerName - $currentTickerUsdValue');
      }
    });
    return currentTickerUsdValue;
    // } else {
    //   var usdVal = await _api.getCoinsUsdValue();
    //   double tempPriceHolder = usdVal[name]['usd'];
    //   if (tempPriceHolder != null) {
    //     currentUsdValue = tempPriceHolder;
    //   }
    // }
    //  return currentUsdValue;
  }
  /*----------------------------------------------------------------------
                Offline Wallet Creation
----------------------------------------------------------------------*/

// create Offline Wallets V1
  Future<CoreWalletModel> createOfflineWalletsV1(
      String mnemonic, String userPassword,
      {isVerifying = false}) async {
    CoreWalletModel walletCoreModel = CoreWalletModel(walletBalancesBody: '');
    var vaultService = locator<VaultService>();
    Map<String, dynamic> wbb = {
      'btcAddress': '',
      'ethAddress': '',
      'fabAddress': '',
      'ltcAddress': '',
      'dogeAddress': '',
      'bchAddress': '',
      'trxAddress': '',
      "showEXGAssets": "true"
    };

    List<String> coinTickers = [
      'BTC',
      'ETH',
      'FAB',
      'LTC',
      'DOGE',
      'BCH',
      'TRX'
    ];
    log.w('generating seed');
    debugPrint(extractTimeFromDate(DateTime.now().toString()));
    var seed = generateSeed(mnemonic);
    log.w('generate seed Done');
    debugPrint(extractTimeFromDate(DateTime.now().toString()));
    log.i('generating root');
    var root = generateBip32Root(seed);
    debugPrint(extractTimeFromDate(DateTime.now().toString()));
    log.i('generated root');
    // BCH address
    log.e('generating bch address');
    String bchAddress = await generateBchAddress(seed);
    debugPrint(extractTimeFromDate(DateTime.now().toString()));
    log.e('generated bch adddress');

    log.w('generating trx address');
    String trxAddress = generateTrxAddress(mnemonic);
    debugPrint(extractTimeFromDate(DateTime.now().toString()));
    log.w('generated trx address');

    try {
      for (int i = 0; i < coinTickers.length; i++) {
        String tickerName = coinTickers[i];
        String token = '';
        String address = '';
        if (tickerName == 'BCH') {
          address = bchAddress;
        } else if (tickerName == 'TRX') {
          address = trxAddress;
        } else {
          address = await coin_util.getAddressForCoin(root, tickerName,
              tokenType: token);
        }
        if (tickerName == 'BTC') {
          wbb['btcAddress'] = address;
        } else if (tickerName == 'ETH') {
          wbb['ethAddress'] = address;
        } else if (tickerName == 'FAB') {
          wbb['fabAddress'] = address;
        } else if (tickerName == 'LTC') {
          wbb['ltcAddress'] = address;
        } else if (tickerName == 'DOGE') {
          wbb['dogeAddress'] = address;
        } else if (tickerName == 'BCH') {
          wbb['bchAddress'] = address;
        } else if (tickerName == 'TRX') {
          wbb['trxAddress'] = address;
        }

        // convert map to json string
        var walletBalanceBodyJsonString = jsonEncode(wbb);
        walletCoreModel = CoreWalletModel(
          id: 1,
          walletBalancesBody: walletBalanceBodyJsonString,
        );
      } // for loop ends
      // await coreWalletDatabaseService.getEncryptedMnemonic().then((res) async {
      //   if (res.isNotEmpty) {
      //     await coreWalletDatabaseService.deleteDb();
      //   }
      // });

      log.i("Wallet core model json ${walletCoreModel.toJson()}");

      if (!isVerifying) {
        // encrypt the mnemonic
        if (userPassword.isNotEmpty && mnemonic.isNotEmpty) {
          var encryptedMnemonic =
              vaultService.encryptMnemonic(userPassword, mnemonic);

          log.i('encryptedMnemonic $encryptedMnemonic');

          // store those json string address and encrypted mnemonic in the wallet core database
          walletCoreModel.mnemonic = encryptedMnemonic;
          log.w(
              'createOfflineWalletsV1 walletCoreModel -- before inserting in the core wallet DB ${walletCoreModel.toJson()}');

          // store in single core database
          await coreWalletDatabaseService.insert(walletCoreModel);
        }
      }
      return walletCoreModel;
    } catch (e) {
      log.e('Catch createOfflineWalletsV1 $e');
      throw Exception('Catch createOfflineWalletsV1 $e');
    }
  }

/*----------------------------------------------------------------------
                Offline Wallet Creation
----------------------------------------------------------------------*/

  Future createOfflineWallets(String mnemonic) async {
    await walletDatabaseService.deleteDb();
    await walletDatabaseService.initDb();
    List<WalletInfo> _walletInfo = [];
    if (_walletInfo != null) {
      _walletInfo.clear();
    } else {
      _walletInfo = [];
    }
    var seed = generateSeed(mnemonic);
    var root = generateBip32Root(seed);

    // BCH address
    String bchAddress = await generateBchAddress(mnemonic);
    String trxAddress = generateTrxAddress(mnemonic);

    try {
      for (int i = 0; i < coinTickers.length; i++) {
        String tickerName = coinTickers[i];
        String name = coinNames[i];
        String token = tokenType[i];
        String addr = '';
        if (tickerName == 'BCH') {
          addr = bchAddress;
        } else if (tickerName == 'TRX') {
          addr = trxAddress;
        } else {
          addr = await coin_util.getAddressForCoin(root, tickerName,
              tokenType: token);
        }
        WalletInfo wi = WalletInfo(
            id: null,
            tickerName: tickerName,
            tokenType: token,
            address: addr,
            availableBalance: 0.0,
            lockedBalance: 0.0,
            usdValue: 0.0,
            name: name);
        _walletInfo.add(wi);
        log.i("Offline wallet ${_walletInfo[i].toJson()}");
        await walletDatabaseService.insert(_walletInfo[i]);
      }

      //  await walletDatabaseService.getAll();
      return _walletInfo;
    } catch (e) {
      log.e('Catch createOfflineWallets $e');
      throw Exception('Catch createOfflineWallets $e');
    }
  }

/*----------------------------------------------------------------------
                Transaction status
----------------------------------------------------------------------*/

  checkTxStatus(TransactionHistory transaction) {
    transaction.tag == 'deposit'
        ? checkDepositTransactionStatus(transaction)
        : checkWithdrawTxStatus(transaction);
  }

  // WITHDRAW TX status
  checkWithdrawTxStatus(TransactionHistory transaction) async {
    int baseTime = 30;
    List result = [];
    String? kanbanTxId = transaction.kanbanTxId;
    TransactionHistory transactionByTxid = TransactionHistory();
    Timer.periodic(Duration(seconds: baseTime), (Timer t) async {
      log.w('Base time $baseTime -- local t.id $kanbanTxId');
      await _apiService.withdrawTxStatus().then((res) async {
        if (res != null) {
          // result = res;
          //  log.e(' -- res $res');
          // transactionByTxId = await transactionHistoryDatabaseService
          //     .getByTxId(transaction.txId);
          res.forEach((singleTx) async {
            var kanbanTxid = singleTx['kanbanTxid'];
            log.w(
                'res not null -- condition -- k.id $kanbanTxid -- t.id $kanbanTxId');

            // If kanban txid is equals to local txid
            if (singleTx['kanbanTxid'] == kanbanTxId) {
              // log.w('single withdraw entry $singleTx');
              baseTime = 60;
              // log.i(
              //     'Withdraw Txid match found so time extended by 50 sec as blockchain will take time to generate txid');
              // if blockchain txid is not empty means withdraw tx has completed
              if (singleTx['blockchainTxid'] != "") {
                String blockchainTxid = singleTx['blockchainTxid'].toString();
                log.i('Blockchain Txid $blockchainTxid -- timer cancel');
                t.cancel();

                var storedTx = await transactionHistoryDatabaseService
                    .getByKanbanTxId(transaction.kanbanTxId!);
                showSimpleNotification(
                    Row(
                      children: [
                        Text('${singleTx['coinName']} '),
                        Text(transaction.tag!),
                        UIHelper.horizontalSpaceSmall,
                        const Icon(Icons.check)
                        //  Text(FlutterI18n.translate(context, "completed")),
                      ],
                    ),
                    position: NotificationPosition.bottom,
                    background: primaryColor);
                String date = DateTime.now().toString();
                transactionByTxid = TransactionHistory(
                    id: storedTx!.id,
                    tickerName: storedTx.tickerName,
                    address: '',
                    amount: 0.0,
                    date: date.toString(),
                    kanbanTxId: storedTx.kanbanTxId,
                    tickerChainTxStatus: 'Complete',
                    quantity: storedTx.quantity,
                    tag: storedTx.tag);
                transactionHistoryDatabaseService.update(transactionByTxid);
              }
            }
          });
          log.i('After res for each');
        }
      });
    });
  }

  // DEPOSIT TX status
  Future<String> checkDepositTransactionStatus(
      TransactionHistory transaction) async {
    String result = '';
    Timer.periodic(const Duration(minutes: 1), (Timer t) async {
      TransactionHistory transactionHistory = TransactionHistory();
      TransactionHistory? transactionByTxId = TransactionHistory();
      var res = await _apiService.getTransactionStatus(transaction.kanbanTxId!);

      log.w('checkDepositTransactionStatus $res');
// 0 is confirmed
// 1 is pending
// 2 is failed (tx 1 failed),
// 3 is need to redeposit (tx 2 failed)
// -1 is error
      if (res['code'] == -1 ||
          res['code'] == 0 ||
          res['code'] == 2 ||
          res['code'] == -2 ||
          res['code'] == 3 ||
          res['code'] == -3) {
        t.cancel();
        result = res['message'];
        log.i('Timer cancel');

        String date = DateTime.now().toString();

        if (transaction != null) {
          transactionByTxId = await transactionHistoryDatabaseService
              .getByKanbanTxId(transaction.kanbanTxId!);
          showSimpleNotification(
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('${transactionByTxId!.tickerName} '),
                  Text(transactionByTxId.tag!),
                  Text(string_utils.firstCharToUppercase(result.toString())),
                ],
              ),
              position: NotificationPosition.bottom,
              background: primaryColor);
        }

        if (res['code'] == 0) {
          log.e('Transaction history passed arguement ${transaction.toJson()}');
          transactionHistory = TransactionHistory(
              id: transactionByTxId.id,
              tickerName: transactionByTxId.tickerName,
              address: '',
              amount: 0.0,
              date: date.toString(),
              kanbanTxId: transactionByTxId.kanbanTxId,
              tickerChainTxStatus: 'Complete',
              quantity: transactionByTxId.quantity,
              tag: transactionByTxId.tag);

          // after this method i will test single status update field in the transaciton history
          // await transactionHistoryDatabaseService
          //     .updateStatus(transactionHistoryByTxId);
          // await transactionHistoryDatabaseService.getByTxId(transaction.txId);
        } else if (res['code'] == -1) {
          transactionHistory = TransactionHistory(
              id: transactionByTxId.id,
              tickerName: transactionByTxId.tickerName,
              address: '',
              amount: 0.0,
              date: date.toString(),
              kanbanTxId: transactionByTxId.kanbanTxId,
              tickerChainTxStatus: 'Error',
              quantity: transactionByTxId.quantity,
              tag: transactionByTxId.tag);

          //  await transactionHistoryDatabaseService.update(transactionHistory);
        } else if (res['code'] == 2 || res['code'] == 2) {
          transactionHistory = TransactionHistory(
              id: transactionByTxId.id,
              tickerName: transactionByTxId.tickerName,
              address: '',
              amount: 0.0,
              date: date.toString(),
              kanbanTxId: transactionByTxId.kanbanTxId,
              tickerChainTxStatus: 'Failed',
              quantity: transactionByTxId.quantity,
              tag: transactionByTxId.tag);

          //  await transactionHistoryDatabaseService.update(transactionHistory);
        } else if (res['code'] == -3 || res['code'] == 3) {
          transactionHistory = TransactionHistory(
              id: transactionByTxId.id,
              tickerName: transactionByTxId.tickerName,
              address: '',
              amount: 0.0,
              date: date.toString(),
              kanbanTxId: transactionByTxId.kanbanTxId,
              tickerChainTxStatus: 'Require redeposit',
              quantity: transactionByTxId.quantity,
              tag: transactionByTxId.tag);

          // await transactionHistoryDatabaseService.update(transactionHistory);
        }
      }
      await transactionHistoryDatabaseService.update(transactionHistory);
      await transactionHistoryDatabaseService
          .getByKanbanTxId(transaction.kanbanTxId!);
    });
    return result;
    //  return _completer.future;
  }

/*----------------------------------------------------------------------
                  Get Wallet Coins (Not in use)
----------------------------------------------------------------------*/

  Future<List<WalletInfo>> getWalletCoins(String mnemonic) async {
    List<WalletInfo> _walletInfo = [];
    List<double> coinUsdMarketPrice = [];
    String exgAddress = '';
    if (_walletInfo != null) {
      _walletInfo.clear();
    } else {
      _walletInfo = [];
    }
    coinUsdMarketPrice.clear();
    var seed = generateSeed(mnemonic);
    var root = bip32.BIP32.fromSeed(seed);
    try {
      for (int i = 0; i < coinTickers.length; i++) {
        String tickerName = coinTickers[i];
        String name = coinNames[i];
        String token = tokenType[i];
        var coinMarketPrice = await getCoinMarketPriceByTickerName(name);
        coinUsdMarketPrice.add(coinMarketPrice!);
        String addr = await coin_util.getAddressForCoin(root, tickerName,
            tokenType: token);
        var bal = await coin_util.getCoinBalanceByAddress(tickerName, addr,
            tokenType: token);
        log.w('bal in wallet service $bal');
        double walletBal = bal['balance'];
        // double walletLockedBal = bal['lockbalance'];

        if (tickerName == 'EXG') {
          exgAddress = addr;
          log.e(exgAddress);
        }
        WalletInfo wi = WalletInfo(
            tickerName: tickerName,
            tokenType: token,
            address: addr,
            availableBalance: walletBal,
            lockedBalance: 0.0,
            usdValue: coinUsdBalance,
            name: name);
        _walletInfo.add(wi);
      }
      var res = await getAllExchangeBalances(exgAddress);
      if (res != null) {
        var length = res.length;
        // For loop over asset balance result
        for (var i = 0; i < length; i++) {
          // Get their tickerName to compare with walletInfo tickerName
          String coin = res[i]['coin'];
          // Second For Loop To check WalletInfo TickerName According to its length and
          // compare it with the same coin tickername from asset balance result until the match or loop ends
          for (var j = 0; j < _walletInfo.length; j++) {
            String tickerName = _walletInfo[j].tickerName!;
            if (coin == tickerName) {
              _walletInfo[j].inExchange = res[i]['amount'];
              // _walletInfo[j].lockedBalance = res[i]['lockedAmount'];
              // double marketPrice =
              //     await getCoinMarketPriceByTickerName(tickerName);
              // log.e(
              //     'wallet service -- tickername $tickerName - market price $marketPrice - balance: ${_walletInfo[j].availableBalance} - Locked balance: ${_walletInfo[j].lockedBalance}');
              // calculateCoinUsdBalance(marketPrice,
              //     _walletInfo[j].availableBalance, _walletInfo[j].lockedBalance);
              break;
            }
          }
        }
      }

      for (int i = 0; i < _walletInfo.length; i++) {
        await walletDatabaseService.insert(_walletInfo[i]);
      }
      return _walletInfo;
    } catch (e) {
      log.e(e);
      _walletInfo = [];
      log.e('Catch GetAll Wallets Failed $e');
      return _walletInfo;
    }
  }

  // Insert transaction history in database

  void insertTransactionInDatabase(
      TransactionHistory transactionHistory) async {
    log.w('Transaction History ${transactionHistory.toJson()}');
    await transactionHistoryDatabaseService
        .insert(transactionHistory)
        .then((data) async {
      log.w('Saved in transaction history database $data');
      await transactionHistoryDatabaseService.getAll();
    }).catchError((onError) async {
      log.e('Could not save in database $onError');
      await transactionHistoryDatabaseService.deleteDb().then((value) async {
        log.e('transactionHistoryDatabase deleted');
        await transactionHistoryDatabaseService
            .insert(transactionHistory)
            .then((data) async {
          log.w('Saved in transaction history database $data');
        });
      });
    });
  }

/*----------------------------------------------------------------------
                    Gas Balance
----------------------------------------------------------------------*/

  Future<double> gasBalance(String exgAddress) async {
    double gasAmount = 0.0;
    await _api.getGasBalance(exgAddress).then((res) {
      if (res != null &&
          res['balance'] != null &&
          res['balance']['FAB'] != null) {
        var newBal = BigInt.parse(res['balance']['FAB']);
        // 2243802047700000000
        gasAmount = NumberUtil.rawStringToDecimal(newBal.toString()).toDouble();
      }
    }).timeout(const Duration(seconds: 25), onTimeout: () {
      log.e('Timeout');
      gasAmount = 0.0;
    }).catchError((onError) {
      log.w('On error $onError');
      gasAmount = 0.0;
    });
    return gasAmount;
  }
/*----------------------------------------------------------------------
                      Assets Balance
----------------------------------------------------------------------*/

  Future getAllExchangeBalances(String exgAddress) async {
    if (exgAddress.isEmpty) {
      exgAddress = await sharedService.getExgAddressFromCoreWalletDatabase();
    }
    try {
      List<Map<String, dynamic>> bal = [];
      var res = await _api.getAssetsBalance(exgAddress);
      log.w('assetsBalance exchange $res');
      for (var i = 0; i < res!.length; i++) {
        var tempBal = res[i];
        var coinType = res[i].coinType;
        var unlockedAmount = res[i].unlockedAmount;
        var lockedAmount = res[i].lockedAmount;
        var finalBal = {
          'coin': coin_list.newCoinTypeMap[coinType],
          'amount': unlockedAmount,
          'lockedAmount': lockedAmount
        };
        bal.add(finalBal);
      }
      log.w('assetsBalance exchange after conversion $bal');
      return bal;
    } catch (onError) {
      log.e('On error assetsBalance $onError');
      throw Exception('Catch error $onError');
    }
  }

  /* ---------------------------------------------------
                Flushbar Notification bar
    -------------------------------------------------- */

  void showInfoFlushbar(String title, String message, IconData iconData,
      Color leftBarColor, BuildContext context) {
    showSimpleNotification(Text(title), subtitle: Text(message));
  }
/*----------------------------------------------------------------------
                Calculate Only Usd Balance For Individual Coin
----------------------------------------------------------------------*/

  double? calculateCoinUsdBalance(
      double marketPrice, double actualWalletBalance, double lockedBalance) {
    if (marketPrice != null) {
      log.w(
          'market price $marketPrice -- available bal $actualWalletBalance-- locked bal $lockedBalance');
      coinUsdBalance = marketPrice * (actualWalletBalance + lockedBalance);
      return coinUsdBalance;
    } else {
      coinUsdBalance = 0.0;
      log.i('calculateCoinUsdBalance - Wallet balance 0');
    }
    return coinUsdBalance;
  }

// Add Gas
  Future<int> addGas() async {
    return 0;
  }

/*----------------------------------------------------------------------
                Get Original Message
----------------------------------------------------------------------*/

  getOriginalMessage(
      int coinType, String txHash, BigInt amount, String address) {
    var buf = '';
    buf += string_utils.fixLength(coinType.toRadixString(16), 8);
    buf += string_utils.fixLength(txHash, 64);
    var hexString = amount.toRadixString(16);
    buf += string_utils.fixLength(hexString, 64);
    buf += string_utils.fixLength(address, 64);

    return buf;
  }

/*----------------------------------------------------------------------
                withdrawDo
----------------------------------------------------------------------*/
  Future<Map<String, dynamic>> withdrawDo(
      seed,
      String coinName,
      String coinAddress,
      String tokenType,
      double amount,
      kanbanPrice,
      kanbanGasLimit,
      isSpeicalTronTokenWithdraw) async {
    var keyPairKanban = getExgKeyPair(seed);
    var addressInKanban = keyPairKanban["address"];
    var amountInLink = BigInt.parse(NumberUtil.toBigInt(amount));
    //amount * BigInt.from(1e18);
    log.i(
        'AMount in link $amountInLink -- coin name $coinName -- token type $tokenType');

    var addressInWallet = coinAddress;
    if ((coinName == 'BTC' ||
            coinName == 'FAB' ||
            coinName == 'LTC' ||
            coinName == 'DOGE' ||
            coinName == 'BCH') &&
        tokenType == '') {
      /*
      debugPrint('addressInWallet before');
      debugPrint(addressInWallet);
      var bytes = bs58check.decode(addressInWallet);
      debugPrint('bytes');
      debugPrint(bytes);
      addressInWallet = HEX.encode(bytes);
      debugPrint('addressInWallet after');
      debugPrint(addressInWallet);

       */
      addressInWallet = fabUtils.btcToBase58Address(addressInWallet);
      //no 0x appended
    } else if (tokenType == 'FAB') {
      addressInWallet = fabUtils.exgToFabAddress(addressInWallet);
      addressInWallet = fabUtils.btcToBase58Address(addressInWallet);
    }
    int? coinType;
    await coinService
        .getCoinTypeByTickerName(coinName)
        .then((value) => coinType = value);
    log.i('cointype $coinType');

    int sepcialcoinType;
    var abiHex;
    if (coinName == 'DSCE' || coinName == 'DSC') {
      sepcialcoinType = await coinService.getCoinTypeByTickerName('DSC');
      abiHex = getWithdrawFuncABI(
          sepcialcoinType, amountInLink, addressInWallet,
          isSpecialDeposit: true, chain: tokenType);
      log.e('cointype $coinType -- abihex $abiHex');
    } else if (coinName == 'BSTE' || coinName == 'BST') {
      sepcialcoinType = await coinService.getCoinTypeByTickerName('BST');
      abiHex = getWithdrawFuncABI(
          sepcialcoinType, amountInLink, addressInWallet,
          isSpecialDeposit: true, chain: tokenType);
      log.e('cointype $coinType -- abihex $abiHex');
    } else if (coinName == 'EXGE' || coinName == 'EXG') {
      sepcialcoinType = await coinService.getCoinTypeByTickerName('EXG');
      abiHex = getWithdrawFuncABI(
          sepcialcoinType, amountInLink, addressInWallet,
          isSpecialDeposit: true, chain: tokenType);
      log.e('cointype $coinType -- abihex $abiHex');
    } else if (coinName == 'FABE' ||
        (coinName == 'FAB' && tokenType == 'ETH')) {
      sepcialcoinType = await coinService.getCoinTypeByTickerName('FAB');
      abiHex = getWithdrawFuncABI(
          sepcialcoinType, amountInLink, addressInWallet,
          isSpecialDeposit: true, chain: tokenType);

      log.e('cointype $coinType -- abihex $abiHex');
    } else if (isSpeicalTronTokenWithdraw) {
      addressInWallet = fabUtils.btcToBase58Address(addressInWallet);
      abiHex = getWithdrawFuncABI(coinType, amountInLink, addressInWallet,
          isSpecialDeposit: true, chain: tokenType);
      log.e('cointype $coinType -- abihex $abiHex');
    } else {
      abiHex = getWithdrawFuncABI(coinType, amountInLink, addressInWallet);
    }
    var coinPoolAddress = await getCoinPoolAddress();

    var nonce = await getNonce(addressInKanban);

    var txKanbanHex = await signAbiHexWithPrivateKey(
        abiHex,
        HEX.encode(keyPairKanban["privateKey"]),
        coinPoolAddress,
        nonce,
        kanbanPrice,
        kanbanGasLimit);
    var url = configService.getKanbanBaseUrl();
    var res = await sendKanbanRawTransaction(url, txKanbanHex);
    if (res['transactionHash'] == null) {
      return res;
    }
    if (res['transactionHash'] != '') {
      res['success'] = true;
      res['data'] = res;
    } else {
      res['success'] = false;
      res['data'] = res;
    }
    return res;
  }

/*----------------------------------------------------------------------
                withdraw Tron
----------------------------------------------------------------------*/
  Future<Map<String, dynamic>> withdrawTron(
      seed,
      String coinName,
      String coinAddress,
      String tokenType,
      double amount,
      kanbanPrice,
      kanbanGasLimit) async {
    var keyPairKanban = getExgKeyPair(seed);
    var addressInKanban = keyPairKanban["address"];
    var amountInLink = BigInt.parse(NumberUtil.toBigInt(amount));
    //amount * BigInt.from(1e18);
    log.i(
        'AMount in link $amountInLink -- coin name $coinName -- token type $tokenType');
    var addressInWallet = coinAddress;
    addressInWallet = fabUtils.btcToBase58Address(addressInWallet);

    int? coinType;
    await coinService
        .getCoinTypeByTickerName(coinName)
        .then((value) => coinType = value);
    log.i('cointype $coinType');

    int sepcialcoinType;
    var abiHex;
    if (coinName == 'USDTX') {
      sepcialcoinType = await coinService.getCoinTypeByTickerName('USDT');
      abiHex = getWithdrawFuncABI(
          sepcialcoinType, amountInLink, addressInWallet,
          isSpecialDeposit: true, chain: tokenType);
      log.e('cointype $coinType -- abihex $abiHex');
    } else {
      abiHex = getWithdrawFuncABI(coinType, amountInLink, addressInWallet);
    }
    var coinPoolAddress = await getCoinPoolAddress();

    var nonce = await getNonce(addressInKanban);

    var txKanbanHex = await signAbiHexWithPrivateKey(
        abiHex,
        HEX.encode(keyPairKanban["privateKey"]),
        coinPoolAddress,
        nonce,
        kanbanPrice,
        kanbanGasLimit);

    var url = configService.getKanbanBaseUrl();
    var res = await sendKanbanRawTransaction(url, txKanbanHex);

    if (res['transactionHash'] != '') {
      res['success'] = true;
      res['data'] = res;
    } else {
      res['success'] = false;
      res['data'] = 'error';
    }
    return res;
  }

/*----------------------------------------------------------------------
                    Tron Deposit
----------------------------------------------------------------------*/
  Future depositTron(
      {String? mnemonic,
      WalletInfo? walletInfo,
      double? amount,
      bool? isTrxUsdt,
      bool? isBroadcast,
      @required options}) async {
    log.i(
        'menmonic $mnemonic -- amount $amount -- istrxusdt $isTrxUsdt -- isBroadcast $isBroadcast');
    int kanbanGasPrice = options['kanbanGasPrice'];
    int kanbanGasLimit = options['kanbanGasLimit'];

    debugPrint('kanbanGasPrice $kanbanGasPrice');
    debugPrint('kanbanGasLimit $kanbanGasLimit');
    var officalAddress = coinService.getCoinOfficalAddress(
        walletInfo!.tickerName!,
        tokenType: walletInfo.tokenType!);
    debugPrint('official address in wallet service deposit do $officalAddress');
    if (officalAddress == null) {
      //errRes['data'] = 'no official address';
      return;
    }
    var privateKey = TronAddressUtil.generateTrxPrivKey(mnemonic!);

    /// get signed raw transaction hash(txid) and hashed raw tx before sign(txhash)
    /// use that to submit deposit
    ///
    var rawTxRes = await TronTransactionUtil.generateTrxTransactionContract(
        privateKey: privateKey,
        fromAddr: walletInfo.address!,
        toAddr: officalAddress,
        amount: amount!,
        isTrxUsdt: isTrxUsdt!,
        tickerName: walletInfo.tickerName!,
        isBroadcast: isBroadcast!,
        contractAddressTronUsdt: options['contractAddress']);

    log.w('depositTron signed raw tx $rawTxRes');
    String txHash;
    var txHex = rawTxRes["rawTxBufferHexAfterSign"];
    CryptoHash.Digest hashedTxHash = rawTxRes["hashedRawTxBufferBeforeSign"];
    // txHex is the result of raw tx after sign but we don't broadcast
    txHash = CryptoWeb3.bytesToHex(hashedTxHash.bytes);

// code  from depositDo

    var coinType =
        await coinService.getCoinTypeByTickerName(walletInfo.tickerName!);
    log.i('coin type $coinType');

    var amountInLink = BigInt.parse(NumberUtil.toBigInt(amount));

    var seed = generateSeed(mnemonic);
    var keyPairKanban = getExgKeyPair(seed);
    var addressInKanban = keyPairKanban["address"];

    var originalMessage = getOriginalMessage(
        coinType,
        string_utils.trimHexPrefix(txHash),
        amountInLink,
        string_utils.trimHexPrefix(addressInKanban));
    log.w('Original message $originalMessage');

    var signedMess = await coin_util.signedMessage(
        originalMessage, seed, walletInfo.tickerName, walletInfo.tokenType);
    log.e('Signed message $signedMess');
    var coinPoolAddress = await getCoinPoolAddress();

    /// assinging coin type accoringly
    /// If special deposits then take the coin type of the respective chain coin
    int sepcialcoinType;
    var abiHex;
    // if ticker is USDT tron then use USDT coin type
    if (walletInfo.tickerName == 'USDTX') {
      sepcialcoinType = await coinService.getCoinTypeByTickerName('USDT');
      abiHex = getDepositFuncABI(
          sepcialcoinType, txHash, amountInLink, addressInKanban, signedMess,
          chain: walletInfo.tokenType!, isSpecialDeposit: true);

      log.e('cointype $coinType -- abihex $abiHex');
    } else {
      debugPrint('in else');
      abiHex = getDepositFuncABI(
          coinType, txHash, amountInLink, addressInKanban, signedMess,
          chain: walletInfo.tokenType!);
      log.i('cointype $coinType -- abihex $abiHex');
    }
    var nonce = await getNonce(addressInKanban);
    debugPrint('nonce ${nonce.toString()}');
    var txKanbanHex = await signAbiHexWithPrivateKey(
        abiHex,
        HEX.encode(keyPairKanban["privateKey"]),
        coinPoolAddress,
        nonce,
        kanbanGasPrice,
        kanbanGasLimit);
    debugPrint('txKanbanHex $txKanbanHex');
    var res = await submitDeposit(txHex, txKanbanHex);
    return res;

    // TRON deposit ends here
  }

/*----------------------------------------------------------------------
                Future Deposit Do
----------------------------------------------------------------------*/

  Future<Map<String, dynamic>> depositDo(
      seed, String coinName, String tokenType, double amount, option) async {
    Map<String, dynamic> errRes = <String, dynamic>{};
    errRes['success'] = false;

    var officalAddress =
        coinService.getCoinOfficalAddress(coinName, tokenType: tokenType);
    if (officalAddress == null) {
      errRes['data'] = 'no official address';
      return errRes;
    }

    var kanbanGasPrice = option['kanbanGasPrice'];
    var kanbanGasLimit = option['kanbanGasLimit'];
    log.e('before send transaction');
    var resST = await sendTransaction(
        coinName, seed, [0], [], officalAddress, amount, option, false);
    log.i('after send transaction');
    if (resST != null) log.w('res $resST');
    if (resST['errMsg'] != '') {
      errRes['data'] = resST['errMsg'];
      return errRes;
    }

    if (resST['txHex'] == '' || resST['txHash'] == '') {
      errRes['data'] = 'no txHex or txHash';
      return errRes;
    }

    var txHex = resST['txHex'];
    var txHash = resST['txHash'];

    var txids = resST['txids'];
    var amountInTx = resST['amountInTx'];
    var amountInLink = BigInt.parse(NumberUtil.toBigInt(amount));

    var amountInTxString = amountInTx.toString();
    var amountInLinkString = amountInLink.toString();

    debugPrint('amountInTxString===$amountInTxString');
    debugPrint('amountInLinkString===$amountInLinkString');
    if (!amountInLinkString.contains(amountInTxString)) {
      errRes['data'] = 'incorrect amount for two transactions';
      return errRes;
    }
    var subString = amountInLinkString.substring(amountInTxString.length);
    if (subString != '') {
      var zero = int.parse(subString);
      if (zero != 0) {
        errRes['data'] = 'unequal amount for two transactions';
        return errRes;
      }
    }

    var coinType = await coinService.getCoinTypeByTickerName(coinName);
    log.i('coin type $coinType');
    if (coinType == 0) {
      errRes['data'] = 'invalid coinType for $coinName';
      return errRes;
    }

    var keyPairKanban = getExgKeyPair(seed);
    var addressInKanban = keyPairKanban["address"];
    debugPrint('txHash=' + txHash);
    var originalMessage = getOriginalMessage(
        coinType,
        string_utils.trimHexPrefix(txHash),
        amountInLink,
        string_utils.trimHexPrefix(addressInKanban));

    var signedMess = await coin_util.signedMessage(
        originalMessage, seed, coinName, tokenType);
    log.e('Signed message $signedMess');
    debugPrint('coin type $coinType');
    log.w('Original message $originalMessage');
    var coinPoolAddress = await getCoinPoolAddress();

    /// assinging coin type accoringly
    /// If special deposits then take the coin type of the respective chain coin
    int? specialCoinType;
    var abiHex;
    bool isSpecial = false;
    for (var specialTokenTicker in Constants.specialTokens) {
      if (coinName == specialTokenTicker) isSpecial = true;
    }
    if (isSpecial) {
      specialCoinType = await coinService
          .getCoinTypeByTickerName(coinName.substring(0, coinName.length - 1));
    }

    var coinTypeUsed = isSpecial ? specialCoinType : coinType;
    abiHex = getDepositFuncABI(
        coinTypeUsed!, txHash, amountInLink, addressInKanban, signedMess,
        chain: tokenType, isSpecialDeposit: isSpecial);
    log.i('coinTypeUsed $coinTypeUsed -- abihex $abiHex');

    var nonce = await getNonce(addressInKanban);

    var txKanbanHex = await signAbiHexWithPrivateKey(
        abiHex,
        HEX.encode(keyPairKanban["privateKey"]),
        coinPoolAddress,
        nonce,
        kanbanGasPrice,
        kanbanGasLimit);

    var res = await submitDeposit(txHex, txKanbanHex);

    res['txids'] = txids;
    return res;
  }

  /* --------------------------------------------
              Methods Called in Send State 
  ----------------------------------------------*/

// Get Fab Transaction Status
  Future getFabTxStatus(String txId) async {
    await fabUtils.getFabTransactionStatus(txId);
  }

// Get Fab Transaction Balance
  Future getFabBalance(String address) async {
    await fabUtils.getFabBalanceByAddress(address);
  }

  // Get ETH Transaction Status
  Future getEthTxStatus(String txId) async {
    await fabUtils.getFabTransactionStatus(txId);
  }

// Get ETH Transaction Balance
  Future getEthBalance(String address) async {
    await fabUtils.getFabBalanceByAddress(address);
  }
/*----------------------------------------------------------------------
                Future Add Gas Do
----------------------------------------------------------------------*/

  Future<Map<String, dynamic>> addGasDo(seed, double amount, {options}) async {
    var satoshisPerBytes = 14;
    var scarContractAddress = await getScarAddress();
    scarContractAddress = string_utils.trimHexPrefix(scarContractAddress);

    var fxnDepositCallHex = '4a58db19';
    var contractInfo = await getFabSmartContract(scarContractAddress,
        fxnDepositCallHex, options['gasLimit'], options['gasPrice']);

    var res1 = await getFabTransactionHex(seed, [0], contractInfo['contract'],
        amount, contractInfo['totalFee'], satoshisPerBytes, [], false);
    var txHex = res1['txHex'];
    var errMsg = res1['errMsg'];

    var txHash = '';
    if (txHex != null && txHex != '') {
      var res = await _api.postFabTx(txHex);
      txHash = res['txHash'];
      errMsg = res['errMsg'];
    }

    return {'txHex': txHex, 'txHash': txHash, 'errMsg': errMsg};
  }

  convertLiuToFabcoin(amount) {
    return (amount * 1e-8);
  }

/*----------------------------------------------------------------------
                isFabTransactionLocked
----------------------------------------------------------------------*/
  isFabTransactionLocked(String txid, int idx) async {
    if (idx != 0) {
      return false;
    }
    var response = await _api.getFabTransactionJson(txid);

    if ((response['vin'] != null) && (response['vin'].length > 0)) {
      var vin = response['vin'][0];
      if (vin['coinbase'] != null) {
        if (response['onfirmations'] <= 800) {
          return true;
        }
      }
    }
    return false;
  }

/*----------------------------------------------------------------------
                getFabTransactionHex
----------------------------------------------------------------------*/
  getFabTransactionHex(
      seed,
      addressIndexList,
      toAddress,
      double amount,
      double extraTransactionFee,
      int satoshisPerBytes,
      addressList,
      getTransFeeOnly) async {
    final txb = BitcoinFlutter.TransactionBuilder(
        network: environment["chains"]["BTC"]["network"]);
    final root = bip32.BIP32.fromSeed(seed);
    var totalInput = 0;
    var amountInTx = BigInt.from(0);
    var allTxids = [];
    var changeAddress = '';
    var finished = false;
    var receivePrivateKeyArr = [];

    var totalAmount = amount + extraTransactionFee;
    //var amountNum = totalAmount * 1e8;
    var amountNum = BigInt.parse(NumberUtil.toBigInt(totalAmount, 8)).toInt();
    amountNum += (2 * 34 + 10) * satoshisPerBytes;

    var transFeeDouble = 0.0;
    var bytesPerInput = environment["chains"]["FAB"]["bytesPerInput"];
    var feePerInput = bytesPerInput * satoshisPerBytes as int;

    for (int i = 0; i < addressIndexList.length; i++) {
      var index = addressIndexList[i];
      var fabCoinChild = root
          .derivePath("m/44'/${environment["CoinType"]["FAB"]}'/0'/0/$index");
      var fromAddress = getBtcAddressForNode(fabCoinChild);
      if (addressList != null && addressList.length > 0) {
        fromAddress = addressList[i];
      }
      if (i == 0) {
        changeAddress = fromAddress!;
      }
      final privateKey = fabCoinChild.privateKey;
      var utxos = await _api.getFabUtxos(fromAddress!);
      if ((utxos != null) && (utxos.length > 0)) {
        for (var j = 0; j < utxos.length; j++) {
          var utxo = utxos[j];
          var idx = utxo['idx'];
          var txid = utxo['txid'];
          var value = utxo['value'] as int;
          /*
          var isLocked = await isFabTransactionLocked(txid, idx);
          if (isLocked) {
            continue;
          }
           */

          var txidItem = {'txid': txid, 'idx': idx};

          var existed = false;
          for (var iii = 0; iii < txids.length; iii++) {
            var ttt = txids[iii];
            if ((ttt['txid'] == txidItem['txid']) &&
                (ttt['idx'] == txidItem['idx'])) {
              existed = true;
              break;
            }
          }

          if (existed) {
            continue;
          }

          allTxids.add(txidItem);

          txb.addInput(txid, idx);
          receivePrivateKeyArr.add(privateKey);
          totalInput += value;

          amountNum -= value;
          amountNum += feePerInput;
          if (amountNum <= 0) {
            finished = true;
            break;
          }
        }
      }

      if (!finished) {
        return {
          'txHex': '',
          'errMsg': 'not enough fab coin to make the transaction.',
          'transFee': NumberUtil()
              .truncateDoubleWithoutRouding(transFeeDouble, precision: 8),
          'amountInTx': amountInTx
        };
      }

      var transFee = (receivePrivateKeyArr.length) * feePerInput +
          (2 * 34 + 10) * satoshisPerBytes;

      var output1 = (totalInput -
              BigInt.parse(NumberUtil.toBigInt(amount + extraTransactionFee, 8))
                  .toInt() -
              transFee)
          .round();
      transFeeDouble = (Decimal.parse(extraTransactionFee.toString()) +
              (Decimal.parse(transFee.toString()) / Decimal.parse('1e8'))
                  .toDecimal())
          .toDouble();
      if (getTransFeeOnly) {
        return {
          'txHex': '',
          'errMsg': '',
          'transFee': NumberUtil()
              .truncateDoubleWithoutRouding(transFeeDouble, precision: 8),
        };
      }
      var output2 = BigInt.parse(NumberUtil.toBigInt(amount, 8)).toInt();
      amountInTx = BigInt.from(output2);
      if (output1 < 0 || output2 < 0) {
        return {
          'txHex': '',
          'errMsg': 'output1 or output2 should be greater than 0.',
          'transFee': NumberUtil()
              .truncateDoubleWithoutRouding(transFeeDouble, precision: 8),
          'amountInTx': amountInTx
        };
      }

      txb.addOutput(changeAddress, output1);

      txb.addOutput(toAddress, output2);

      for (var i = 0; i < receivePrivateKeyArr.length; i++) {
        var privateKey = receivePrivateKeyArr[i];
        var alice = BitcoinFlutter.ECPair.fromPrivateKey(privateKey,
            compressed: true, network: environment["chains"]["BTC"]["network"]);

        txb.sign(vin: i, keyPair: alice);
      }

      var txHex = txb.build().toHex();

      return {
        'txHex': txHex,
        'errMsg': '',
        'transFee': NumberUtil()
            .truncateDoubleWithoutRouding(transFeeDouble, precision: 8),
        'amountInTx': amountInTx,
        'txids': allTxids
      };
    }
  }

/*----------------------------------------------------------------------
                getErrDeposit
----------------------------------------------------------------------*/
  Future getErrDeposit(String address) {
    return getKanbanErrDeposit(address);
  }

  toKbPaymentAddress(String fabAddress) {
    return toKbpayAddress(fabAddress);
  }

  Future txHexforSendCoin(seed, coinType, kbPaymentAddress, amount,
      kanbanGasPrice, kanbanGasLimit) async {
    var abiHex = getSendCoinFuncABI(coinType, kbPaymentAddress, amount);

    var keyPairKanban = getExgKeyPair(seed);
    var address = keyPairKanban['address'];
    var nonce = await getNonce(address);

    var coinpoolAddress = await getCoinPoolAddress();

    var txKanbanHex = await signAbiHexWithPrivateKey(
        abiHex,
        HEX.encode(keyPairKanban["privateKey"]),
        coinpoolAddress,
        nonce,
        kanbanGasPrice,
        kanbanGasLimit);
    debugPrint('end txHexforSendCoin');
    return txKanbanHex;
  }

  isValidKbAddress(String kbPaymentAddress) {
    var fabAddress = '';
    try {
      fabAddress = toLegacyAddress(kbPaymentAddress);
    } catch (e) {}

    return (fabAddress != '');
  }

/*----------------------------------------------------------------------
                    Generate raw tx
----------------------------------------------------------------------*/

  Future generateRawTx(seed, String abiHex, String toAddress) async {
    var kanbanGasPrice = environment["chains"]["KANBAN"]["gasPrice"];
    var kanbanGasLimit = environment["chains"]["KANBAN"]["gasLimit"];

    var keyPairKanban = getExgKeyPair(seed);
    var address = keyPairKanban['address'];
    var nonce = await getNonce(address);

    var rawKanbanHex = await signAbiHexWithPrivateKey(
        abiHex,
        HEX.encode(keyPairKanban["privateKey"]),
        toAddress,
        nonce,
        kanbanGasPrice,
        kanbanGasLimit);
    log.w('generateRawTx $rawKanbanHex');
    return rawKanbanHex;
  }
/*----------------------------------------------------------------------
                Send Coin
----------------------------------------------------------------------*/

  Future sendCoin(
      seed, int coinType, String kbPaymentAddress, double amount) async {
// example: sendCoin(seed, 1, 'oV1KxZswBx2AUypQJRDEb2CsW2Dq2Wp4L5', 0.123);

    var gasPrice = environment["chains"]["KANBAN"]["gasPrice"];
    var gasLimit = environment["chains"]["KANBAN"]["gasLimit"];
    //var amountInLink = BigInt.from(amount * 1e18);
    var amountInLink = BigInt.parse(NumberUtil.toBigInt(amount, 18));
    var txHex = await txHexforSendCoin(
        seed, coinType, kbPaymentAddress, amountInLink, gasPrice, gasLimit);
    log.e('txhex $txHex');
    var url = configService.getKanbanBaseUrl();
    var resKanban = await sendKanbanRawTransaction(url, txHex);
    debugPrint('resKanban=');
    debugPrint(resKanban.toString());
    return resKanban;
  }

/*----------------------------------------------------------------------
                Send Transaction
----------------------------------------------------------------------*/
  Future sendTransaction(
      String coin,
      seed,
      List addressIndexList,
      List addressList,
      String toAddress,
      double amount,
      options,
      bool doSubmit) async {
    final root = bip32.BIP32.fromSeed(seed);
    var totalInput = 0;
    var finished = false;
    var gasPrice = 0;
    var gasLimit = 0;
    var satoshisPerBytes = 0;
    var bytesPerInput = 0;
    var allTxids = [];
    var getTransFeeOnly = false;
    var txHex = '';
    var txHash = '';
    var errMsg = '';
    var utxos = [];
    var amountInTx = BigInt.from(0);
    var transFeeDouble = 0.0;
    var amountSent = 0;
    var receivePrivateKeyArr = [];

    var tokenType = options['tokenType'] ?? '';
    var decimal = options['decimal'];
    var contractAddress = options['contractAddress'] ?? '';
    var changeAddress = '';

    if (options != null) {
      if (options["gasPrice"] != null) {
        gasPrice = options["gasPrice"];
      }
      if (options["gasLimit"] != null) {
        gasLimit = options["gasLimit"];
      }
      if (options["satoshisPerBytes"] != null) {
        satoshisPerBytes = options["satoshisPerBytes"];
      }
      if (options["bytesPerInput"] != null) {
        bytesPerInput = options["bytesPerInput"];
      }
      if (options["getTransFeeOnly"] != null) {
        getTransFeeOnly = options["getTransFeeOnly"];
      }
    }
    //debugPrint('tokenType=' + tokenType);

    log.w(
        'gasPrice= $gasPrice -- gasLimit =  $gasLimit -- satoshisPerBytes= $satoshisPerBytes');

    // BTC
    if (coin == 'BTC') {
      if (bytesPerInput == 0) {
        bytesPerInput = environment["chains"]["BTC"]["bytesPerInput"];
      }
      if (satoshisPerBytes == 0) {
        satoshisPerBytes = environment["chains"]["BTC"]["satoshisPerBytes"];
      }
      var amountNum = BigInt.parse(NumberUtil.toBigInt(amount, 8)).toInt();
      amountNum += (2 * 34 + 10) * satoshisPerBytes;
      final txb = BitcoinFlutter.TransactionBuilder(
          network: environment["chains"]["BTC"]["network"]);
      // txb.setVersion(1);

      for (var i = 0; i < addressIndexList.length; i++) {
        var index = addressIndexList[i];
        var bitCoinChild = root
            .derivePath("m/44'/${environment["CoinType"]["BTC"]}'/0'/0/$index");
        var fromAddress = getBtcAddressForNode(bitCoinChild);
        if (addressList.isNotEmpty) {
          fromAddress = addressList[i];
        }
        if (i == 0) {
          changeAddress = fromAddress!;
        }
        final privateKey = bitCoinChild.privateKey;
        var utxos = await _api.getBtcUtxos(fromAddress!);
        //debugPrint('utxos=');
        //debugPrint(utxos);
        if ((utxos == null) || (utxos.length == 0)) {
          continue;
        }
        for (var j = 0; j < utxos.length; j++) {
          var tx = utxos[j];
          if (tx['idx'] < 0) {
            continue;
          }
          txb.addInput(tx['txid'], tx['idx']);
          amountNum -= tx['value'] as int;
          amountNum += bytesPerInput * satoshisPerBytes;
          totalInput += tx['value'] as int;
          receivePrivateKeyArr.add(privateKey);
          if (amountNum <= 0) {
            finished = true;
            break;
          }
        }
      }

      if (!finished) {
        txHex = '';
        txHash = '';
        errMsg = 'not enough fund.';
        return {
          'txHex': txHex,
          'txHash': txHash,
          'errMsg': errMsg,
          'amountInTx': amountInTx
        };
      }

      var transFee =
          (receivePrivateKeyArr.length) * bytesPerInput * satoshisPerBytes +
              (2 * 34 + 10) * satoshisPerBytes;

      var output1 = (totalInput -
              BigInt.parse(NumberUtil.toBigInt(amount, 8)).toInt() -
              transFee)
          .round();

      if (output1 < 2730) {
        transFee += output1;
      }

      transFeeDouble = transFee / 1e8;
      if (getTransFeeOnly) {
        return {
          'txHex': '',
          'txHash': '',
          'errMsg': '',
          'amountSent': '',
          'transFee': transFeeDouble
        };
      }

      var output2 = BigInt.parse(NumberUtil.toBigInt(amount, 8)).toInt();

      if (output1 >= 2730) {
        txb.addOutput(changeAddress, output1);
      }

      amountInTx = BigInt.from(output2);
      txb.addOutput(toAddress, output2);
      for (var i = 0; i < receivePrivateKeyArr.length; i++) {
        var privateKey = receivePrivateKeyArr[i];
        var alice = BitcoinFlutter.ECPair.fromPrivateKey(privateKey,
            compressed: true, network: environment["chains"]["BTC"]["network"]);
        txb.sign(vin: i, keyPair: alice);
      }

      var tx = txb.build();
      txHex = tx.toHex();
      if (doSubmit) {
        var res = await _api.postBtcTx(txHex);
        txHash = res['txHash'];
        errMsg = res['errMsg'];
        return {'txHash': txHash, 'errMsg': errMsg, 'amountInTx': amountInTx};
      } else {
        txHash = '0x${tx.getId()}';
      }
    }

    // BCH Transaction
    else if (coin == 'BCH') {
      if (bytesPerInput == 0) {
        bytesPerInput = environment["chains"]["BCH"]["bytesPerInput"];
      }
      if (satoshisPerBytes == 0) {
        satoshisPerBytes = environment["chains"]["BCH"]["satoshisPerBytes"];
      }
      var amountNum = BigInt.parse(NumberUtil.toBigInt(amount, 8)).toInt();
      amountNum += (2 * 34 + 10) * satoshisPerBytes;

      final txb = bitbox.Bitbox.transactionBuilder(
          testnet: environment["chains"]["BCH"]["testnet"]);
      final masterNode =
          bitbox.HDNode.fromSeed(seed, environment["chains"]["BCH"]["testnet"]);
      final childNode = "m/44'/${environment["CoinType"]["BCH"]}'/0'/0/0";
      final accountNode = masterNode.derivePath(childNode);
      final address = accountNode.toCashAddress();

      final utxos = await _api.getBchUtxos(address);

      if ((utxos == null) || (utxos.length == 0)) {
        return {
          'txHex': '',
          'txHash': '',
          'errMsg': 'not enough fund',
          'amountInTx': amountInTx
        };
      }

      final signatures = <Map>[];

      for (var j = 0; j < utxos.length; j++) {
        var tx = utxos[j];
        if (tx['idx'] < 0) {
          continue;
        }
        txb.addInput(tx['txid'], tx['idx']);

        // add a signature to the list to be used later
        signatures.add({
          "vin": signatures.length,
          "key_pair": accountNode.keyPair,
          "original_amount": tx['value']
        });

        amountNum -= tx['value'] as int;
        amountNum += bytesPerInput * satoshisPerBytes;
        totalInput += tx['value'] as int;
        if (amountNum <= 0) {
          finished = true;
          break;
        }
      }

      if (!finished) {
        return {'txHex': '', 'txHash': '', 'errMsg': 'not enough fund'};
      }

      var transFee = (signatures.length) * bytesPerInput * satoshisPerBytes +
          (2 * 34 + 10) * satoshisPerBytes;
      transFeeDouble = transFee / 1e8;

      if (getTransFeeOnly) {
        return {
          'txHex': '',
          'txHash': '',
          'errMsg': '',
          'amountSent': '',
          'transFee': transFeeDouble,
          'amountInTx': amountInTx
        };
      }

      var output1 = (totalInput -
              BigInt.parse(NumberUtil.toBigInt(amount, 8)).toInt() -
              transFee)
          .round();
      var output2 = BigInt.parse(NumberUtil.toBigInt(amount, 8)).toInt();

      amountInTx = BigInt.from(output2);
      txb.addOutput(address, output1);
      txb.addOutput(toAddress, output2);

      for (var signature in signatures) {
        txb.sign(signature["vin"], signature["key_pair"],
            signature["original_amount"]);
      }

      final tx = txb.build();
      txHex = tx.toHex();
      if (doSubmit) {
        var res = await _api.postBchTx(txHex);
        txHash = res['txHash'];
        errMsg = res['errMsg'];
        return {'txHash': txHash, 'errMsg': errMsg, 'amountInTx': amountInTx};
      } else {
        txHash = '0x${tx.getId()}';
      }
    }

    // LTC Transaction
    else if (coin == 'LTC') {
      if (bytesPerInput == 0) {
        bytesPerInput = environment["chains"]["LTC"]["bytesPerInput"];
      }
      if (satoshisPerBytes == 0) {
        satoshisPerBytes = environment["chains"]["LTC"]["satoshisPerBytes"];
      }
      var amountNum = BigInt.parse(NumberUtil.toBigInt(amount, 8)).toInt();
      amountNum += (2 * 34 + 10) * satoshisPerBytes;
      final txb = BitcoinFlutter.TransactionBuilder(
          network: environment["chains"]["LTC"]["network"]);

      for (var i = 0; i < addressIndexList.length; i++) {
        var index = addressIndexList[i];
        var node = root
            .derivePath("m/44'/${environment["CoinType"]["LTC"]}'/0'/0/$index");
        var fromAddress = getLtcAddressForNode(node);
        if (addressList.isNotEmpty) {
          fromAddress = addressList[i];
        }
        if (i == 0) {
          changeAddress = fromAddress!;
        }
        final privateKey = node.privateKey;
        var utxos = await _api.getLtcUtxos(fromAddress!);

        if ((utxos == null) || (utxos.length == 0)) {
          continue;
        }
        for (var j = 0; j < utxos.length; j++) {
          var tx = utxos[j];
          if (tx['idx'] < 0) {
            continue;
          }
          txb.addInput(tx['txid'], tx['idx']);
          amountNum -= tx['value'] as int;
          amountNum += bytesPerInput * satoshisPerBytes;
          totalInput += tx['value'] as int;
          receivePrivateKeyArr.add(privateKey);
          if (amountNum <= 0) {
            finished = true;
            break;
          }
        }
      }

      if (!finished) {
        txHex = '';
        txHash = '';
        errMsg = 'not enough fund.';
        return {
          'txHex': txHex,
          'txHash': txHash,
          'errMsg': errMsg,
          'amountInTx': amountInTx
        };
      }

      var transFee =
          (receivePrivateKeyArr.length) * bytesPerInput * satoshisPerBytes +
              (2 * 34 + 10) * satoshisPerBytes;
      transFeeDouble = transFee / 1e8;

      if (getTransFeeOnly) {
        return {
          'txHex': '',
          'txHash': '',
          'errMsg': '',
          'amountSent': '',
          'transFee': transFeeDouble
        };
      }

      var output1 = (totalInput -
              BigInt.parse(NumberUtil.toBigInt(amount, 8)).toInt() -
              transFee)
          .round();
      var output2 = BigInt.parse(NumberUtil.toBigInt(amount, 8)).toInt();
      amountInTx = BigInt.from(output2);
      txb.addOutput(changeAddress, output1);
      txb.addOutput(toAddress, output2);
      for (var i = 0; i < receivePrivateKeyArr.length; i++) {
        var privateKey = receivePrivateKeyArr[i];
        var alice = BitcoinFlutter.ECPair.fromPrivateKey(privateKey,
            compressed: true, network: environment["chains"]["LTC"]["network"]);
        txb.sign(vin: i, keyPair: alice);
      }

      var tx = txb.build();
      txHex = tx.toHex();
      if (doSubmit) {
        var res = await _api.postLtcTx(txHex);
        txHash = res['txHash'];
        errMsg = res['errMsg'];
        return {'txHash': txHash, 'errMsg': errMsg, 'amountInTx': amountInTx};
      } else {
        txHash = '0x${tx.getId()}';
      }
    }

    // DOGE Transaction
    else if (coin == 'DOGE') {
      if (bytesPerInput == 0) {
        bytesPerInput = environment["chains"]["DOGE"]["bytesPerInput"];
      }
      if (satoshisPerBytes == 0) {
        satoshisPerBytes = environment["chains"]["DOGE"]["satoshisPerBytes"];
      }
      var amountNum = BigInt.parse(NumberUtil.toBigInt(amount, 8)).toInt();
      amountNum += (2 * 34 + 10) * satoshisPerBytes;
      final txb = BitcoinFlutter.TransactionBuilder(
          network: environment["chains"]["DOGE"]["network"]);

      for (var i = 0; i < addressIndexList.length; i++) {
        var index = addressIndexList[i];
        var node = root.derivePath(
            "m/44'/${environment["CoinType"]["DOGE"]}'/0'/0/$index");
        var fromAddress = getDogeAddressForNode(node);
        debugPrint('fromAddress==$fromAddress');
        if (addressList.isNotEmpty) {
          fromAddress = addressList[i];
        }
        if (i == 0) {
          changeAddress = fromAddress!;
        }

        final privateKey = node.privateKey;
        var utxos = await _api.getDogeUtxos(fromAddress!);
        //debugPrint('utxos=');
        //debugPrint(utxos);
        if ((utxos == null) || (utxos.length == 0)) {
          continue;
        }
        for (var j = 0; j < utxos.length; j++) {
          var tx = utxos[j];
          if (tx['idx'] < 0) {
            continue;
          }
          txb.addInput(tx['txid'], tx['idx']);
          amountNum -= tx['value'] as int;
          amountNum += bytesPerInput * satoshisPerBytes;
          totalInput += tx['value'] as int;
          receivePrivateKeyArr.add(privateKey);
          if (amountNum <= 0) {
            finished = true;
            break;
          }
        }
      }

      if (!finished) {
        txHex = '';
        txHash = '';
        errMsg = 'not enough fund.';
        return {
          'txHex': txHex,
          'txHash': txHash,
          'errMsg': errMsg,
          'amountInTx': amountInTx
        };
      }

      var transFee =
          (receivePrivateKeyArr.length) * bytesPerInput * satoshisPerBytes +
              (2 * 34 + 10) * satoshisPerBytes;
      transFeeDouble = transFee / 1e8;

      if (getTransFeeOnly) {
        return {
          'txHex': '',
          'txHash': '',
          'errMsg': '',
          'amountSent': '',
          'transFee': transFeeDouble,
          'amountInTx': amountInTx
        };
      }

      var output1 = (totalInput -
              BigInt.parse(NumberUtil.toBigInt(amount, 8)).toInt() -
              transFee)
          .round();
      var output2 = BigInt.parse(NumberUtil.toBigInt(amount, 8)).toInt();
      amountInTx = BigInt.from(output2);
      txb.addOutput(changeAddress, output1);

      txb.addOutput(toAddress, output2);

      for (var i = 0; i < receivePrivateKeyArr.length; i++) {
        var privateKey = receivePrivateKeyArr[i];
        var alice = BitcoinFlutter.ECPair.fromPrivateKey(privateKey,
            compressed: true,
            network: environment["chains"]["DOGE"]["network"]);
        txb.sign(vin: i, keyPair: alice);
      }
      var tx = txb.build();
      txHex = tx.toHex();
      if (doSubmit) {
        var res = await _api.postDogeTx(txHex);
        txHash = res['txHash'];
        errMsg = res['errMsg'];
        return {'txHash': txHash, 'errMsg': errMsg, 'amountInTx': amountInTx};
      } else {
        txHash = '0x${tx.getId()}';
      }
    }

    // ETH Transaction

    else if (coin == 'ETH') {
      // Credentials fromHex = EthPrivateKey.fromHex("c87509a[...]dc0d3");

      if (gasPrice == 0) {
        gasPrice = environment["chains"]["ETH"]["gasPrice"];
      }
      if (gasLimit == 0) {
        gasLimit = environment["chains"]["ETH"]["gasLimit"];
      }
      transFeeDouble = (BigInt.parse(gasPrice.toString()) *
              BigInt.parse(gasLimit.toString()) /
              BigInt.parse('1000000000'))
          .toDouble();

      if (getTransFeeOnly) {
        return {
          'txHex': '',
          'txHash': '',
          'errMsg': '',
          'amountSent': '',
          'transFee': transFeeDouble
        };
      }

      final chainId = environment["chains"]["ETH"]["chainId"];
      final ethCoinChild =
          root.derivePath("m/44'/${environment["CoinType"]["ETH"]}'/0'/0/0");
      final privateKey = HEX.encode(ethCoinChild.privateKey!.toList());
      var amountSentInt = BigInt.parse(NumberUtil.toBigInt(amount, 18));

      Credentials credentials = EthPrivateKey.fromHex(privateKey);

      final address = await credentials.extractAddress();
      final addressHex = address.hex;
      final nonce = await _api.getEthNonce(addressHex);

      var apiUrl =
          environment["chains"]["ETH"]["infura"]; //Replace with your API

      var ethClient = Web3Client(apiUrl, client);

      amountInTx = amountSentInt;
      final signed = await ethClient.signTransaction(
          credentials,
          Transaction(
            nonce: nonce,
            to: EthereumAddress.fromHex(toAddress),
            gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, gasPrice),
            maxGas: gasLimit,
            value: EtherAmount.fromUnitAndValue(EtherUnit.wei, amountSentInt),
          ),
          chainId: chainId,
          fetchChainIdFromNetworkId: false);

      txHex = '0x${HEX.encode(signed)}';

      debugPrint('txHex in ETH=$txHex');
      if (doSubmit) {
        var res = await _api.postEthTx(txHex);
        txHash = res['txHash'];
        errMsg = res['errMsg'];
      } else {
        txHash = getTransactionHash(signed);
      }
    } else if (coin == 'FAB') {
      if (bytesPerInput == 0) {
        bytesPerInput = environment["chains"]["FAB"]["bytesPerInput"];
      }
      if (satoshisPerBytes == 0) {
        satoshisPerBytes = environment["chains"]["FAB"]["satoshisPerBytes"];
      }

      var res1 = await getFabTransactionHex(seed, addressIndexList, toAddress,
          amount, 0, satoshisPerBytes, addressList, getTransFeeOnly);
      if (getTransFeeOnly) {
        return {
          'txHex': '',
          'txHash': '',
          'errMsg': '',
          'amountSent': '',
          'transFee': res1["transFee"],
          'amountInTx': res1["amountInTx"]
        };
      }
      txHex = res1['txHex'];
      errMsg = res1['errMsg'];
      allTxids = res1['txids'];
      amountInTx = res1["amountInTx"];

      if ((errMsg == '') && (txHex != '')) {
        if (doSubmit) {
          var res = await _api.postFabTx(txHex);

          txHash = res['txHash'];
          errMsg = res['errMsg'];
        } else {
          var tx = BitcoinFlutter.Transaction.fromHex(txHex);
          txHash = '0x${tx.getId()}';
        }
      }
    }

    // Token FAB

    else if (tokenType == 'FAB') {
      if (bytesPerInput == 0) {
        bytesPerInput = environment["chains"]["FAB"]["bytesPerInput"];
      }
      if (satoshisPerBytes == 0) {
        satoshisPerBytes = environment["chains"]["FAB"]["satoshisPerBytes"];
      }
      if (gasPrice == 0) {
        gasPrice = environment["chains"]["FAB"]["gasPrice"];
      }
      if (gasLimit == 0) {
        gasLimit = environment["chains"]["FAB"]["gasLimit"];
      }
      var transferAbi = 'a9059cbb';
      var amountSentInt = BigInt.parse(NumberUtil.toBigInt(amount, decimal));

      if (coin == 'DUSD') {
        amountSentInt = BigInt.parse(NumberUtil.toBigInt(amount, 6));
      }

      amountInTx = amountSentInt;
      var amountSentHex = amountSentInt.toRadixString(16);

      var fxnCallHex = transferAbi +
          string_utils.fixLength(string_utils.trimHexPrefix(toAddress), 64) +
          string_utils.fixLength(string_utils.trimHexPrefix(amountSentHex), 64);

      contractAddress = string_utils.trimHexPrefix(contractAddress);

      var contractInfo = await getFabSmartContract(
          contractAddress, fxnCallHex, gasLimit, gasPrice);
      if (addressList != null && addressList.isNotEmpty) {
        addressList[0] = await coreWalletDatabaseService
                    .getWalletAddressByTickerName('FAB') !=
                addressList[0]
            ? fabUtils.exgToFabAddress(addressList[0])
            : addressList[0];
      }
      var res1 = await getFabTransactionHex(
          seed,
          addressIndexList,
          contractInfo['contract'],
          0,
          contractInfo['totalFee'],
          satoshisPerBytes,
          addressList,
          getTransFeeOnly);

      debugPrint('res1 in here=');
      debugPrint(res1.toString());

      if (getTransFeeOnly) {
        return {
          'txHex': '',
          'txHash': '',
          'errMsg': '',
          'amountSent': '',
          'transFee': res1["transFee"],
          'amountInTx': amountInTx
        };
      }

      txHex = res1['txHex'];
      errMsg = res1['errMsg'];
      allTxids = res1['txids'];
      if (txHex != null && txHex != '') {
        if (doSubmit) {
          var res = await _api.postFabTx(txHex);
          txHash = res['txHash'];
          errMsg = res['errMsg'];
        } else {
          var tx = BitcoinFlutter.Transaction.fromHex(txHex);
          txHash = '0x${tx.getId()}';
        }
      }
    }
    // Token type ETH
    else if (tokenType == 'ETH') {
      if (gasPrice == 0) {
        gasPrice = environment["chains"]["ETH"]["gasPrice"];
      }
      if (gasLimit == 0) {
        gasLimit = environment["chains"]["ETH"]["gasLimitToken"];
      }
      transFeeDouble = (BigInt.parse(gasPrice.toString()) *
              BigInt.parse(gasLimit.toString()) /
              BigInt.parse('1000000000'))
          .toDouble();
      log.i('transFeeDouble===$transFeeDouble');
      if (getTransFeeOnly) {
        return {
          'txHex': '',
          'txHash': '',
          'errMsg': '',
          'amountSent': '',
          'transFee': transFeeDouble
        };
      }

      final chainId = environment["chains"]["ETH"]["chainId"];
      final ethCoinChild =
          root.derivePath("m/44'/${environment["CoinType"]["ETH"]}'/0'/0/0");
      final privateKey = HEX.encode(ethCoinChild.privateKey!.toList());
      Credentials credentials = EthPrivateKey.fromHex(privateKey);

      final address = credentials.address;
      final addressHex = address.hex;
      final nonce = await _api.getEthNonce(addressHex);

      //gasLimit = 100000;
      BigInt convertedDecimalAmount;
      if (coin == 'BNB' ||
          coin == 'INB' ||
          coin == 'REP' ||
          coin == 'HOT' ||
          coin == 'MATIC' ||
          coin == 'IOST' ||
          coin == 'MANA' ||
          coin == 'ELF' ||
          coin == 'GNO' ||
          coin == 'WINGS' ||
          coin == 'KNC' ||
          coin == 'GVT' ||
          coin == 'DRGN') {
        convertedDecimalAmount = BigInt.parse(NumberUtil.toBigInt(amount));
        //   (BigInt.from(10).pow(18) * BigInt.from(amount));

        //var amountSentInt = BigInt.parse(toBigInt(amount, 18));
        log.e('amount send $convertedDecimalAmount');
      } else if (coin == 'FUN' || coin == 'WAX' || coin == 'MTL') {
        convertedDecimalAmount = BigInt.parse(NumberUtil.toBigInt(amount, 8));
        log.e('amount send $convertedDecimalAmount');
      } else if (coin == 'POWR' || coin == 'USDT') {
        convertedDecimalAmount = BigInt.parse(NumberUtil.toBigInt(amount, 6));
      } else if (coin == 'CEL') {
        convertedDecimalAmount = BigInt.parse(NumberUtil.toBigInt(amount, 4));
      } else {
        convertedDecimalAmount =
            BigInt.parse(NumberUtil.toBigInt(amount, decimal));
      }

      amountInTx = convertedDecimalAmount;
      var transferAbi = 'a9059cbb';
      var fxnCallHex = transferAbi +
          string_utils.fixLength(string_utils.trimHexPrefix(toAddress), 64) +
          string_utils.fixLength(
              string_utils
                  .trimHexPrefix(convertedDecimalAmount.toRadixString(16)),
              64);
      var apiUrl =
          environment["chains"]["ETH"]["infura"]; //Replace with your API

      var ethClient = Web3Client(apiUrl, client);
      debugPrint(
          '5 $nonce -- $contractAddress -- ${EtherUnit.wei} -- $fxnCallHex');
      final signed = await ethClient.signTransaction(
          credentials,
          Transaction(
              nonce: nonce,
              to: EthereumAddress.fromHex(contractAddress),
              gasPrice: EtherAmount.fromInt(EtherUnit.gwei, gasPrice),
              maxGas: gasLimit,
              value: EtherAmount.fromInt(EtherUnit.wei, 0),
              data: Uint8List.fromList(string_utils.hex2Buffer(fxnCallHex))),
          chainId: chainId,
          fetchChainIdFromNetworkId: false);
      log.w('signed=');
      txHex = '0x${HEX.encode(signed)}';

      if (doSubmit) {
        var res = await _api.postEthTx(txHex);
        txHash = res['txHash'];
        errMsg = res['errMsg'];
      } else {
        txHash = getTransactionHash(signed);
      }
    }
    return {
      'txHex': txHex,
      'txHash': txHash,
      'errMsg': errMsg,
      'amountSent': amount,
      'transFee': transFeeDouble,
      'amountInTx': amountInTx,
      'txids': allTxids
    };
  }

/*----------------------------------------------------------------------
                getFabSmartContract
----------------------------------------------------------------------*/
  getFabSmartContract(
      String contractAddress, String fxnCallHex, gasLimit, gasPrice) async {
    contractAddress = string_utils.trimHexPrefix(contractAddress);
    fxnCallHex = string_utils.trimHexPrefix(fxnCallHex);

    var totalAmount = (Decimal.parse(gasLimit.toString()) *
            Decimal.parse(gasPrice.toString()) /
            Decimal.parse('1e8'))
        .toDouble();
    // let cFee = 3000 / 1e8 // fee for the transaction

    var totalFee = totalAmount;
    var chunks = [];
    log.w('Smart contract Address $contractAddress');
    chunks.add(84);

    chunks.add(Uint8List.fromList(string_utils.number2Buffer(gasLimit)));

    chunks.add(Uint8List.fromList(string_utils.number2Buffer(gasPrice)));

    chunks.add(Uint8List.fromList(string_utils.hex2Buffer(fxnCallHex)));

    chunks.add(Uint8List.fromList(string_utils.hex2Buffer(contractAddress)));

    chunks.add(194);

    var contract = script.compile(chunks);

    var contractSize = contract.toString().length;

    totalFee += convertLiuToFabcoin(contractSize * 10);

    var res = {'contract': contract, 'totalFee': totalFee};
    return res;
  }
}
