import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'multisig_dashboard_viewmodel.dart';

class MultisigDashboardView extends StatelessWidget {
  const MultisigDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MultisigDashboardViewModel>.reactive(
      viewModelBuilder: () => MultisigDashboardViewModel(),
      builder: (
        BuildContext context,
        MultisigDashboardViewModel model,
        Widget? child,
      ) {
        return Scaffold(
          body: Center(
            child: Text(
              'MultisigDashboardView',
            ),
          ),
        );
      },
    );
  }
}
