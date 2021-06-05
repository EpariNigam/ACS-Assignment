import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class ContactItemWidget extends StatelessWidget {
  final Contact _contact;

  ContactItemWidget(this._contact) {}

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
        leading: (_contact.avatar != null && _contact.avatar.isNotEmpty)
            ? CircleAvatar(
                backgroundImage: MemoryImage(_contact.avatar),
              )
            : CircleAvatar(
                child: Text(_contact.initials()),
                backgroundColor: Theme.of(context).accentColor,
              ),
        title: Text(_contact.displayName ?? ''));
  }
}
