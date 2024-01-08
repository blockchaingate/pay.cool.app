import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/models/wallet/add_coin_model.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/widgets/shimmer_layouts/shimmer_layout.dart';

class AllCoinsListView extends StatefulWidget {
  final List<AddCoinModel> data;
  const AllCoinsListView(this.data, {super.key});

  @override
  State<AllCoinsListView> createState() => _AllCoinsListViewState();
}

class _AllCoinsListViewState extends State<AllCoinsListView> {
  bool isLoading = false;

  List<AddCoinModel> coinList = [];

  @override
  void initState() {
    coinList = widget.data;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      resizeToAvoidBottomInset: false,
      appBar: customAppBarWithIcon(
        title: FlutterI18n.translate(context, "homePageCoinList"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: isLoading || coinList.isEmpty
                  ? const ShimmerLayout(
                      layoutType: 'walletDashboard',
                      count: 12,
                    )
                  : buildListView(0),
            ),
          ],
        ),
      ),
    );
  }

  ListView buildListView(int index) {
    return ListView.builder(
      itemCount: coinList.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: CachedNetworkImage(
                  imageUrl: coinList[index].token!.image!,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 500),
                  fadeOutDuration: const Duration(milliseconds: 500),
                  fadeOutCurve: Curves.easeOut,
                  fadeInCurve: Curves.easeIn,
                  imageBuilder: (context, imageProvider) => FadeInImage(
                    placeholder: const AssetImage(
                        'assets/images/launcher/paycool-logo.png'),
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              UIHelper.horizontalSpaceSmall,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coinList[index].token!.name!,
                    style: TextStyle(
                      color: black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "${coinList[index].id!.substring(0, 6)}...${coinList[index].id!.substring(coinList[index].id!.length - 4)}",
                    style: TextStyle(
                      color: grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Expanded(child: SizedBox()),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "100,000.00",
                    style: TextStyle(
                      color: black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    FlutterI18n.translate(context, "balance"),
                    style: TextStyle(
                      color: grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              UIHelper.horizontalSpaceMedium,
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.add_circle_outline,
                  color: black,
                  size: 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
