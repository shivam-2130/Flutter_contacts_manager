// ignore_for_file: prefer_const_constructors

import 'package:contact_app/data/contact.dart';
import 'package:contact_app/ui/contacts/contact_edit_page.dart';
import 'package:contact_app/ui/model/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../../contacts/block_contact.dart';

class ContactTile extends StatelessWidget {
  const ContactTile({
    super.key,
    required this.contactIndex,
  });

  final int contactIndex;

  get doNothing => null;

  @override
  Widget build(BuildContext context) {
    final model = ScopedModel.of<ContactsModel>(context);
    final displayedContact = model.contacts[contactIndex];
    return Slidable(
      enabled: true,
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            label: 'Delete',
            onPressed: (context) {
              model.deleteContact(displayedContact);
            },
            icon: Icons.delete,
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
          ),
        ],
      ),
      startActionPane: ActionPane(motion: const BehindMotion(), children: [
        SlidableAction(
          label: 'Call',
          onPressed: (context) {
            _callPhoneNumber(
              context,
              displayedContact.phoneNumber,
            );
          },
          icon: Icons.call,
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
        ),
        SlidableAction(
          label: 'Email',
          onPressed: (context) => _writeEmail(context, displayedContact.email),
          icon: Icons.mail_outline,
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
        ),
      ]),
      child: _buildContext(displayedContact, model, context),
    );
  }

  Future _callPhoneNumber(
    BuildContext context,
    String number,
  ) async {
    Uri url = Uri(
      scheme: "tel",
      path: number,
    );
    if (await url_launcher.canLaunchUrl(url)) {
      await url_launcher.launchUrl(url);
    } else {
      final snackbar = SnackBar(
        content: Text('Cannot make a call'),
      );
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Future _writeEmail(
    BuildContext context,
    String emailAddress,
  ) async {
    final url = Uri(
      scheme: "mailto",
      path: emailAddress,
    );
    if (await url_launcher.canLaunchUrl(url)) {
      await url_launcher.launchUrl(url);
    } else {
      final snackbar = SnackBar(
        content: Text('Cannot write a email'),
      );
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  ListTile _buildContext(
      Contact displayedContact, ContactsModel model, BuildContext context) {
    return ListTile(
        title: Text(displayedContact.name),
        subtitle: Text(displayedContact.email),
        leading: _buildCircleAvatar(displayedContact),
        trailing: IconButton(
          icon: Icon(
            displayedContact.isFavorite ? Icons.star : Icons.star_border,
            color: displayedContact.isFavorite ? Colors.amber : Colors.grey,
          ),
          onPressed: () {
            model.changeFavoriteStatus(displayedContact);
          },
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ContactEditPage(
                editedContact: displayedContact,
              ),
            ),
          );
        },
        onLongPress: () {
          showMenu(
            items: <PopupMenuEntry>[
              PopupMenuItem(
                value: contactIndex,
                child: Row(
                  children: const <Widget>[
                    Icon(Icons.block),
                    Text("Block"),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlockContact(
                        blockedContact: displayedContact,
                      ),
                    ),
                  );
                },
              ),
            ],
            context: context,
            position: RelativeRect.fill,
          );
        });
  }

  Hero _buildCircleAvatar(Contact displayedContact) {
    return Hero(
      tag: displayedContact.hashCode,
      child: CircleAvatar(
        child: _buildCircleAvatarContent(displayedContact),
      ),
    );
  }

  Widget _buildCircleAvatarContent(Contact displayedContact) {
    if (displayedContact.imageFile == null) {
      return Text(
        displayedContact.name[0],
      );
    } else {
      return ClipOval(
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.file(
            displayedContact.imageFile!,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }
}
