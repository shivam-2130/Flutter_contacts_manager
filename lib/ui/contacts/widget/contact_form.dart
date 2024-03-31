import 'dart:io';

import 'package:contact_app/data/contact.dart';
import 'package:contact_app/ui/model/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';

class ContactForm extends StatefulWidget {
  const ContactForm({
    super.key,
    this.editedContact,
    this.blockedContact,
  });
  final Contact? editedContact;
  final Contact? blockedContact;
  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  //XFile? imageFile;
  final picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _phoneNumber;
  File? _contactImageFile;

  bool get isEditMode => widget.editedContact != null;
  bool get hasSelectedCustomImage => _contactImageFile != null;

  @override
  void initState() {
    super.initState();
    _contactImageFile = widget.editedContact?.imageFile;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          const SizedBox(height: 10),
          _buildContactPicture(),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: widget.editedContact?.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter a Name';
              }
              return null;
            },
            onSaved: (value) => _name = value!,
            decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                )),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: widget.editedContact?.email,
            validator: (value) {
              final emailRegex = RegExp(r"[a-z0-9]+@[a-z]+\.[a-z]{2,3}");
              if (value == null || value.isEmpty) {
                return 'Enter a Email';
              } else if (!emailRegex.hasMatch(value)) {
                return 'Enter valid Email';
              } else {
                return null;
              }
            },
            onSaved: (value) => _email = value!,
            decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                )),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: widget.editedContact?.phoneNumber,
            validator: (value) {
              //final phoneRegex = RegExp(r"(^(?:[+0]9)?[0-9]{10,12}$)");
              if (value == null || value.isEmpty) {
                return 'Enter a Phone Number';
                // } else if (!phoneRegex.hasMatch(value)) {
                //   return 'Enter valid Phone Number';
              } else {
                return null;
              }
            },
            onSaved: (value) => _phoneNumber = value!,
            decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                )),
          ),
          ElevatedButton(
            onPressed: _onSaveContactButtonPressed,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Text('SAVE CONTACT'),
                  Icon(
                    Icons.person,
                    size: 18,
                  )
                ]),
          )
        ],
      ),
    );
  }

  Widget _buildContactPicture() {
    final halfScreenDiameter = MediaQuery.of(context).size.width / 2;
    return Hero(
      tag: widget.editedContact.hashCode,
      child: GestureDetector(
        onTap: _onContactPictureTapped,
        child: CircleAvatar(
          radius: halfScreenDiameter / 2,
          child: _buildCircleAvatarContent(halfScreenDiameter),
        ),
      ),
    );
  }

  void _onContactPictureTapped() async {
    final imageFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _contactImageFile = File(imageFile!.path);
    });
  }

  Widget _buildCircleAvatarContent(double halfScreenDiameter) {
    if (isEditMode || hasSelectedCustomImage) {
      return _buildEditModeCircleAvatarContent(halfScreenDiameter);
    } else {
      return Icon(
        Icons.person,
        size: halfScreenDiameter / 2,
      );
    }
  }

  Widget _buildEditModeCircleAvatarContent(double halfScreenDiameter) {
    if (_contactImageFile == null) {
      return Text(
        widget.editedContact!.name[0],
        style: TextStyle(fontSize: halfScreenDiameter / 2),
      );
    } else {
      return ClipOval(
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.file(
            _contactImageFile!,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

  void _onSaveContactButtonPressed() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      final newOrEditedContact = Contact(
        name: _name,
        email: _email,
        phoneNumber: _phoneNumber,
        isFavorite: widget.editedContact?.isFavorite ?? false,
        imageFile: _contactImageFile,
      );
      if (isEditMode) {
        //ID doesn't change after updating other contacts field.
        newOrEditedContact.id = widget.editedContact?.id;
        ScopedModel.of<ContactsModel>(context).updateContact(
          newOrEditedContact,
        );
      } else {
        ScopedModel.of<ContactsModel>(context).addContact(newOrEditedContact);
      }
      Navigator.of(context).pop();
    }
  }
}
