import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

//Common Utils
class AppUtils {
  //Show dialog with 2 buttons
  static showDialogCommon(
      BuildContext context,
      String title,
      String content,
      String positiveBtn,
      String negativeBtn,
      VoidCallback positiveFn,
      VoidCallback negativeFn) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => WillPopScope(
            child: AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                  onPressed: positiveFn,
                  child: Text(positiveBtn),
                ),
                TextButton(onPressed: negativeFn, child: Text(negativeBtn))
              ],
            ),
            onWillPop: () async => false));
  }

  // Open app settings and exit the app
  static openSettingsAndExit() {
    openAppSettings();
    SystemNavigator.pop();
  }
}
