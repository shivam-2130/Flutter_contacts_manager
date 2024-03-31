import 'package:contact_app/data/contact.dart';
import 'package:contact_app/ui/contacts/widget/contact_form.dart';
import 'package:flutter/material.dart';

class ContactEditPage extends StatelessWidget {
  const ContactEditPage({
    super.key,
    required this.editedContact,
  });
  final Contact editedContact;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit'),
      ),
      body: ContactForm(
        editedContact: editedContact,
      ),
    );
  }
}
