import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> addHistory(String name, int received, int companyIncome) async {
  final docUser = FirebaseFirestore.instance
      .collection('History')
      .doc(DateTime.now().toString());

  final json = {
    'uid': FirebaseAuth.instance.currentUser!.uid,
    'name': name,
    'dateTime': DateTime.now(),
    'received': received,
    'companyIncome': companyIncome,
  };

  await docUser.set(json);
  return docUser.id;
}
