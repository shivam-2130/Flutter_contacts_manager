import 'package:flutter/material.dart';

import 'package:contact_app/data/contact.dart';
import 'package:contact_app/ui/contacts/widget/contact_form.dart';

class BlockContact extends StatelessWidget {
  const BlockContact({
    super.key,
    required this.blockedContact,
  });
  final Contact blockedContact;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Contacts'),
      ),
      body: ContactForm(
        blockedContact: blockedContact,
      ),
    );
  }
}
