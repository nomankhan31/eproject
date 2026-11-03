import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/customer_model.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CustomerModel>> getCustomers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'user')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CustomerModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  Future<void> updateBlockStatus(String customerId, bool isBlocked) async {
    await _firestore.collection('users').doc(customerId).update({
      'isBlocked': isBlocked,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
