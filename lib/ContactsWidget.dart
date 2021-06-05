import 'package:acs_assignment/AppUtils.dart';
import 'package:acs_assignment/ContactItemWidget.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Constants.dart' as Constants;

class ContactsWidget extends StatefulWidget {
  ContactsWidget({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() {
    return ContactsState(title);
  }
}

class ContactsState extends State<ContactsWidget> {
  final String title;
  PermissionStatus _status;
  Iterable<Contact> _contacts;

  ContactsState(this.title);

  @override
  void initState() {
    permission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: (_status == null)
          ? Center(child: Text('Checking Permission'))
          : (_status == PermissionStatus.granted)
              ? (_contacts != null
                  //Build a list view of all contacts, displaying their avatar and
                  // display name
                  ? ListView.builder(
                      itemCount: _contacts?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        Contact contact = _contacts?.elementAt(index);
                        return ContactItemWidget(contact);
                      },
                    )
                  : Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          Constants.FETCHING_,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 10),
                            child: const CircularProgressIndicator())
                      ],
                    )))
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
          getContacts();
        }
      }
    } else {
      setState(() {});
      getContacts();
    }
  }

  void showRationalDialog() {
    AppUtils.showDialogCommon(
        context,
        Constants.GRANT_PERMISSION,
        Constants.ALLOW_PERMISSION_CONTENT,
        Constants.ALLOW,
        Constants.DENY, () {
      askPermissionFromDialog();
    }, () {
      SystemNavigator.pop();
    });
  }

  void showSettingsDialog() {
    AppUtils.showDialogCommon(
        context,
        Constants.GRANT_PERMISSION,
        Constants.ALLOW_PERMISSION_SETTING,
        Constants.SETTINGS,
        Constants.CANCEL, () {
      AppUtils.openSettingsAndExit();
    }, () {
      SystemNavigator.pop();
    });
  }

  Future<PermissionStatus> requestPermission() async {
    return await Permission.contacts.request();
  }

  askPermissionFromDialog() {
    Navigator.pop(context);
    permission();
  }

  Future<void> getContacts() async {
    //We already have permissions for contact when we get to this page, so we
    // are now just retrieving it
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }
}
