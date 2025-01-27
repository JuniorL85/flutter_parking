import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cli_shared/cli_shared.dart';

class PersonRepository {
  PersonRepository._privateConstructor();

  static final personInstance = PersonRepository._privateConstructor();

  final db = FirebaseFirestore.instance.collection('persons');

  Future<Person> addPerson(Person person) async {
    await db.doc(person.id).set(person.toJson());

    return person;
  }

  Future<List<Person>> getAllPersons() async {
    final snapshots = await db.get();

    final docs = snapshots.docs;

    final jsons = docs.map((doc) {
      final json = doc.data();
      json["id"] = doc.id;

      return json;
    }).toList();

    return jsons.map((person) => Person.fromJson(person)).toList();
  }

  Future<Person> getPersonById(String id) async {
    final snapshot = await db.doc(id).get();

    final json = snapshot.data();

    if (json == null) {
      throw Exception("Person with id $id not found");
    }

    json["id"] = snapshot.id;

    return Person.fromJson(json);
  }

  Future<Person?> getByAuthId(String authId) async {
    final snapshot = await db.where("id", isEqualTo: authId).get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final json = snapshot.docs.first.data();

    return Person.fromJson(json);
  }

  Future<Person> updatePersons(Person person) async {
    await db.doc(person.id).set(person.toJson());

    return person;
  }

  Future<Person> deletePerson(Person person) async {
    final personById = await getPersonById(person.id);

    await db.doc(person.id).delete();

    return personById;
  }
}
