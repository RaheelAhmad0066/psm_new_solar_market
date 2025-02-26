import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BackNavigatingButton extends StatelessWidget {
  final Color color;
  const BackNavigatingButton({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      child:  Icon(
      color: color,
        Icons.arrow_back_ios_new_outlined,
      ),
    );
  }
}