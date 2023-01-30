import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/custom_styles.dart';
import 'pagination_model.dart';

class PaginationWidget extends StatelessWidget {
  final PaginationModel paginationModel;
  final Function(int) pageCallback;
  const PaginationWidget({Key key, this.paginationModel, this.pageCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: grey.withAlpha(220),
          borderRadius: const BorderRadius.all(Radius.circular(25))),
      width: 200,
      height: 45,
      // color: primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Visibility(
            child: TextButton(
              onPressed: () {
                pageCallback(paginationModel.pageNumber - 1);
                //  model.updatePage(false);
                //  getPaginationRewards();
              },
              child: const Icon(
                Icons.arrow_back_ios_outlined,
                color: white,
                size: 18,
              ),
            ),
            visible: paginationModel.pageNumber != 1,
            replacement: SizedBox(
              width: 50,
              child: Icon(
                Icons.arrow_back_ios_outlined,
                color: white.withAlpha(125),
                size: 17,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Visibility(
              visible: paginationModel.pages.isNotEmpty,
              child: Text(
                paginationModel.pageNumber.toString() +
                    ' / ' +
                    paginationModel.totalPages.toString(),
                style: headText5.copyWith(
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                    letterSpacing: 0.5,
                    fontSize: 15),
              ),
            ),
          ),
          Visibility(
            child: TextButton(
              onPressed: () {
                if (paginationModel.pageNumber < paginationModel.totalPages) {
                  pageCallback(paginationModel.pageNumber + 1);
                }
              },
              child: const Icon(
                Icons.arrow_forward_ios_outlined,
                color: white,
                size: 18,
              ),
            ),
            visible: paginationModel.pages.isNotEmpty &&
                paginationModel.pageNumber < paginationModel.totalPages,
            replacement: SizedBox(
              width: 50,
              child: Icon(
                Icons.arrow_forward_ios_outlined,
                color: white.withAlpha(125),
                size: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Container(
//         margin: const EdgeInsets.only(bottom: 10),
//         decoration: BoxDecoration(
//             color: grey.withAlpha(125),
//             borderRadius: const BorderRadius.all(Radius.circular(25))),
//         width: 200,
//         height: 45,
//         // color: primaryColor,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Visibility(
//               child: TextButton(
//                 onPressed: () {
//                   //   if (model.pageNumber != 1) {
//                   model.pageNumber = model.pageNumber - 1;
//                   model.getPaginationRewards();
//                   //  } else {
//                   //   debugPrint('First page');
//                   // }
//                 },
//                 child: const Icon(
//                   Icons.arrow_back_ios_outlined,
//                   color: white,
//                   size: 14,
//                 ),
//               ),
//               visible: model.pageNumber != 1,
//               replacement: const SizedBox(
//                 width: 50,
//                 child: Icon(
//                   Icons.arrow_back_ios_outlined,
//                   color: grey,
//                   size: 14,
//                 ),
//               ),
//             ),
//             Visibility(
//               visible: model.children.isNotEmpty,
//               child: Text(
//                 model.pageNumber.toString() +
//                     '/' +
//                     model.totalPageCount.toString(),
//                 style: headText5.copyWith(
//                     fontWeight: FontWeight.bold, color: secondaryColor),
//               ),
//             ),
//             Visibility(
//               child: TextButton(
//                 onPressed: () {
//                   model.pageNumber = model.pageNumber + 1;
//                   model.getPaginationRewards();
//                 },
//                 child: const Icon(
//                   Icons.arrow_forward_ios_outlined,
//                   color: white,
//                   size: 14,
//                 ),
//               ),
//               visible: model.children.isNotEmpty &&
//                   model.children.length == model.pageSize,
//               replacement: const SizedBox(
//                 width: 50,
//                 child: Icon(
//                   Icons.arrow_forward_ios_outlined,
//                   color: grey,
//                   size: 14,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
