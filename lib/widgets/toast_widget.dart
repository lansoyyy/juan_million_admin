import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ToastType { success, error, info }

showToast(msg, {ToastType type = ToastType.info}) {
  Color backgroundColor;
  IconData iconData;

  switch (type) {
    case ToastType.success:
      backgroundColor = const Color(0xFF2E7D32);
      iconData = Icons.check_circle_outline;
      break;
    case ToastType.error:
      backgroundColor = const Color(0xFFC62828);
      iconData = Icons.error_outline;
      break;
    case ToastType.info:
      backgroundColor = const Color(0xFF1565C0);
      iconData = Icons.info_outline;
      break;
  }

  Get.showSnackbar(
    GetSnackBar(
      message: msg,
      icon: Icon(iconData, color: Colors.white),
      backgroundColor: backgroundColor,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      duration: const Duration(seconds: 2),
    ),
  );
}
