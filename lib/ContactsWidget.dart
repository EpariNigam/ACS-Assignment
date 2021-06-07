import 'package:acs_assignment/ContactItemWidget.dart';
import 'package:acs_assignment/util/AppUtils.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'util/Constants.dart' as Constants;

// Contacts Screen
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
  List<Contact> _contactsList;
  List<String> _namesList = [];

  ContactsState(this.title);

  @override
  void initState() {
    permission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: (_status == null)
          ? Center(child: Text(Constants.CHECKING_PERMISSION))
          : (_status == PermissionStatus.granted)
              ? (_contactsList != null
                  // Build a list view of all contacts, displaying their avatar and name
                  ? AlphabetListScrollView(
                      strList: _namesList,
                      indexedHeight: (i) {
                        return 80;
                      },
                      showPreview: true,
                      itemBuilder: (context, index) {
                        return ContactItemWidget(_contactsList[index]);
                      },
                      keyboardUsage: true,
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

  // Asks permission and displays dialogs accordingly
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

  // Show rational dialog asking user to allow permission
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

  // Show dialog to open settings
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

  // Request contacts permission
  Future<PermissionStatus> requestPermission() async {
    return await Permission.contacts.request();
  }

  // Dismiss the dialog and again ask permission
  askPermissionFromDialog() {
    Navigator.pop(context);
    permission();
  }

  // Retrieve contacts and sort them also prepare the names list for fast scroller
  Future<void> getContacts() async {
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    _contactsList = contacts.toList();
    _contactsList.removeWhere((element) => element.displayName == null);
    _contactsList.sort((a, b) =>
        a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    _contactsList.forEach((element) {
      _namesList.add(element.displayName.toUpperCase());
    });
    setState(() {});
  }
}
