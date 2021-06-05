import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsWidget extends StatefulWidget {
  ContactsWidget({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() {
    return ContactsState();
  }
}

class ContactsState extends State<ContactsWidget> {
  PermissionStatus _status;

  @override
  void initState() {
    permission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contacts')),
      body: _status == null
          ? Center(child: Text('Checking Permission'))
          : Center(child: Text(_status.toString())),
    );
  }

  permission() async {
    _status = await requestPermission();
    print(_status);
    if (_status == PermissionStatus.permanentlyDenied) {
      showSettingsDialog();
    } else if (_status == PermissionStatus.denied) {
      bool isShown = await Permission.contacts.shouldShowRequestRationale;
      if (isShown) {
        showRationalDialog();
      } else {
        _status = await requestPermission();
        print(_status);
        if (_status.isDenied) {
          permission();
        } else {
          setState(() {});
        }
      }
    } else {
      setState(() {});
    }
  }

  void showRationalDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => WillPopScope(
            child: AlertDialog(
              title: Text('Grant Permission'),
              content: Text('Please allow permission to fetch contacts!'),
              actions: [
                TextButton(
                  onPressed: () => askPermissionDialog(),
                  child: Text('Allow'),
                ),
                TextButton(
                    onPressed: () => SystemNavigator.pop(), child: Text('Deny'))
              ],
            ),
            onWillPop: () async => false));
  }

  void showSettingsDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => WillPopScope(
            child: AlertDialog(
              title: Text('Grant Permission'),
              content: Text(
                  'Please allow permission to fetch contacts in the system settings. Once allowed the permission, reopen the application again.'),
              actions: [
                TextButton(
                  onPressed: () => openExit(),
                  child: Text('Settings'),
                ),
                TextButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: Text('Cancel'))
              ],
            ),
            onWillPop: () async => false));
  }

  Future<PermissionStatus> permissionStatus() async {
    return await Permission.contacts.status;
  }

  Future<PermissionStatus> requestPermission() async {
    return await Permission.contacts.request();
  }

  openExit() {
    openAppSettings();
    SystemNavigator.pop();
  }

  askPermissionDialog() {
    Navigator.pop(context);
    permission();
  }
}
