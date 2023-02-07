import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/custom_styles.dart';
import 'pagination_model.dart';

class PaginationWidget extends StatelessWidget {
  final PaginationModel paginationModel;
  final Function(int) pageCallback;
  const PaginationWidget(
      {Key? key, required this.paginationModel, required this.pageCallback})
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
            visible: paginationModel.pageNumber != 1,
            replacement: SizedBox(
              width: 50,
              child: Icon(
                Icons.arrow_back_ios_outlined,
                color: white.withAlpha(125),
                size: 17,
              ),
            ),
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
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Visibility(
              visible: paginationModel.pages.isNotEmpty,
              child: Text(
                '${paginationModel.pageNumber} / ${paginationModel.totalPages}',
                style: headText5.copyWith(
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                    letterSpacing: 0.5,
                    fontSize: 15),
              ),
            ),
          ),
          Visibility(
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
          ),
        ],
      ),
    );
  }
}
