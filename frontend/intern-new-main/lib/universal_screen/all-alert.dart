// lib/utils/custom_alert.dart

import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class CustomAlert {
  static Future<void> showSuccessAlert(BuildContext context, String message,
      {Function? onConfirmBtnTap}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: "Success",
      confirmBtnColor: const Color(0xFF12C06A),
      customAsset: 'assets/gif/Success.gif',
      text: message,
      onConfirmBtnTap: () {
        if (onConfirmBtnTap != null) {
          onConfirmBtnTap(); // Panggil fungsi navigasi terlebih dahulu
        } else {
          Navigator.of(context).pop(); // Tutup dialog jika tidak ada aksi lain
        }
      },
    );
  }
  static Future<void> showFailedAlert(BuildContext context, String message) async {
    Future.delayed(const Duration(milliseconds: 500));
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: "Failed",
      confirmBtnColor: const Color(0xFFde0239),
      text: message,
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
      },
    );
  }

  
}
