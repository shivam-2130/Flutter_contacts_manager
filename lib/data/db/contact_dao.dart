// ignore_for_file: constant_identifier_names

import 'package:contact_app/data/contact.dart';
import 'package:contact_app/data/db/app_database.dart';
import 'package:sembast/sembast.dart';

class ContactDao {
  static const String CONTACT_STORE_NAME = 'contacts';
  //A store with int keys and Map<String, dynamic> values.
  //This is precisely what we need since we convert contatcs object to Mao.
  final _contactStore = intMapStoreFactory.store(CONTACT_STORE_NAME);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insert(Contact contact) async {
    _contactStore.add(
      await _db,
      contact.toMap(),
    );
  }

  Future update(Contact contact) async {
    final finder = Finder(
      filter: Filter.byKey(contact.id),
    );
    await _contactStore.update(
      await _db,
      contact.toMap(),
      finder: finder,
    );
  }

  Future delete(Contact contact) async {
    final finder = Finder(
      filter: Filter.byKey(contact.id),
    );
    await _contactStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future<List<Contact>> getAllInSortedOrder() async {
    final finder = Finder(sortOrders: [
      SortOrder('isFavorite', false),
      SortOrder('name'),
    ]);

    final recordSnapshots = await _contactStore.find(await _db, finder: finder);

    //Map iterates over the whole list and gives us access to every element
    return recordSnapshots.map((snapshot) {
      final contact = Contact.fromMap(snapshot.value);
      contact.id = snapshot.key;
      return contact;
    }).toList();
  }
}
