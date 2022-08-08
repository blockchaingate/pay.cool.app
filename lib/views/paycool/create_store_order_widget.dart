
// class CreateStoreOrderWidget
//     extends ViewModelBuilderWidget<PayCoolViewmodel> {
//   @override
//   bool get reactive => false;

//   @override
//   bool get createNewModelOnInsert => false;

//   @override
//   bool get disposeViewModel => true;

//   @override
//   Widget builder(
//     BuildContext context,
//     PayCoolViewmodel model,
//     Widget child,
//   ) {
//     return AlertDialog(
//       titlePadding: const EdgeInsets.all(0),
//       actionsPadding: const EdgeInsets.all(0),
//       elevation: 5,
//       backgroundColor: walletCardColor.withOpacity(0.95),
//       title: Container(
//         alignment: Alignment.center,
//         color: primaryColor.withOpacity(0.1),
//         padding: const EdgeInsets.all(10),
//         child: const Text('Create the order'),
//       ),
//       titleTextStyle: headText5,
//       contentTextStyle: const TextStyle(color: grey),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 10),
//       content: StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             UIHelper.verticalSpaceMedium,
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
//               child: Text(
//                   // add here cupertino widget to check in these small widgets first then the entire app
//                   'Please fill the order details and submit',
//                   textAlign: TextAlign.left,
//                   style: headText5),
//             ),
//             // Do not show checkbox and text does not require to show on all dialogs

//             // SizedBox(height: 10),
//           ],
//         );
//       }),
//       // actions: [],
//       actions: <Widget>[
//         Container(
//           margin: const EdgeInsetsDirectional.only(bottom: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               OutlinedButton(
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all<Color>(red),
//                   padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
//                       const EdgeInsets.all(0)),
//                 ),
//                 child: Text(
//                   FlutterI18n.translate(context, "close"),
//                   style: const TextStyle(color: Colors.white, fontSize: 12),
//                 ),
//                 onPressed: () {
//                   Navigator.of(context).pop(false);
//                 },
//               ),
//               UIHelper.horizontalSpaceSmall,
//             ],
//           ),
//         )
//       ],
//     );
//   }

//   @override
//   PayCoolViewmodel viewModelBuilder(BuildContext context) =>
//       PayCoolViewmodel();
// }
