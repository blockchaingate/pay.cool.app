/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: ken.qiu@exchangily.com
*----------------------------------------------------------------------
*/

import 'dart:convert';

import '../logger.dart';
import '../service_locator.dart';
import '../utils/custom_http_util.dart';
import 'config_service.dart';

mixin KanbanService {
  final client = CustomHttpUtil.createLetsEncryptUpdatedCertClient();
  final log = getLogger('KanbanService');
  ConfigService configService = locator<ConfigService>();

/*----------------------------------------------------------------------
                    Get scar/exchangily address
----------------------------------------------------------------------*/
  getScarAddress() async {
    var url =
        configService.getKanbanBaseUrl() + 'exchangily/getExchangeAddress';
    var response = await client.get(url);
    var json = jsonDecode(response.body);
    return json;
  }

/*----------------------------------------------------------------------
                    Get Decimal configuration for the coins
----------------------------------------------------------------------*/

  Future getDepositTransactionStatus(String transactionId) async {
    var url = configService.getKanbanBaseUrl() + 'checkstatus/' + transactionId;
    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body);
      log.w(' getDepositTransactionStatus $json');
      return json;
    } catch (err) {
      log.e('In getDepositTransactionStatus catch $err');
    }
  }
}
