import 'package:flutter/material.dart';

class NameAddressInputWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController addressController;
  const NameAddressInputWidget(
      {super.key,
      required this.nameController,
      required this.addressController});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: const [],
      ),
    );
  }
}
