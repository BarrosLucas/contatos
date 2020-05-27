import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


final String contactTable = "contactTable";
final String idColumn     = "idColumn";
final String nameColumn   = "nameColumn";
final String emailColumn  = "emailColumn";
final String phoneColumn  = "phoneColumn";
final String imgColumn    = "imgColumn";


class ContactHelper{

  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _database;

  Future<Database> get db async {
    if(_database != null){
      return _database;
    }
    _database = await initDb();
    return _database;
  }

  Future<Database> initDb() async{
    final databasePth = await getDatabasesPath();
    final path = join(databasePth, "contacts.db");

    return await openDatabase(path,version: 1, onCreate: (Database db, int newVersion)async{
      await db.execute(
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
                "$phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  Future<Contact> save(Contact contact) async{
    Database database = await db;
    contact.id = await database.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async{
    Database database = await db;
    List<Map> maps = await database.query(
      contactTable,
      columns: [idColumn,nameColumn,emailColumn,phoneColumn,imgColumn],
      where: "$idColumn = ?",
      whereArgs: [id]
    );
    if(maps.length>0){
      return Contact.fromMap(maps.first);
    }
    return null;
  }

  Future<int >deleteContact(int id)async{
    Database database = await db;
    return await database.delete(contactTable, where: "$idColumn = ?",whereArgs: [id]);
  }

  Future <int> updateContact(Contact contact) async{
    Database database = await db;
    return await database.update(contactTable, contact.toMap(), where: "$idColumn = ?",whereArgs: [contact.id]);
  }

  Future<List> getAllContact() async{
    Database database = await db;
    List<Map> contactsMaps = await database.rawQuery("SELECT * FROM $contactTable");
    List<Contact> contacts = List();
    for(Map m in contactsMaps){
      contacts.add(Contact.fromMap(m));
    }
    return contacts;
  }

  Future<int> getCount() async{
    Database database = await db;
    return Sqflite.firstIntValue(await database.rawQuery("SELET COUNT(*) FROM $contactTable"));
  }

  Future close() async{
    Database database = await db;
    database.close();
  }

}

class Contact{
  Contact();

  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact.fromMap(Map map){
    id    = map[idColumn];
    name  = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img   = map[imgColumn];
  }

  Map toMap(){
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }


}