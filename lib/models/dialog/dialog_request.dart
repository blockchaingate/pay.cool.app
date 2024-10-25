/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Class Name: AlertRequest
*
* Author: barry-ruprai@exchangily.com
*----------------------------------------------------------------------
*/

class DialogRequest {
  final String title;
  final String description;
  final String buttonTitle;
  final String? cancelButton;
  final String? secondaryButton;
  final bool? isSpecialReq;
  final bool? isBiometricPayment;

  DialogRequest(
      {required this.title,
      required this.description,
      required this.buttonTitle,
      this.cancelButton,
      this.secondaryButton,
      this.isSpecialReq,
      this.isBiometricPayment});
}
