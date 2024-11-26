import 'package:hive/hive.dart';

class StorageServices {
  Future<void> addSampleContacts(String number, String name) async {
    final contactsBox = await Hive.openBox('contact');
    contactsBox.put(number, name);
  }
}
