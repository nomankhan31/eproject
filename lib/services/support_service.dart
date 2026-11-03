import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/support_message_model.dart';

class SupportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _messages =>
      _firestore.collection('support_messages');

  Stream<List<SupportMessageModel>> getMessages(String userId) {
    return _messages
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return SupportMessageModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }

  Stream<List<SupportMessageModel>> getAllMessages() {
    return _messages.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return SupportMessageModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  Future<void> sendMessage({
    required String userId,
    required String message,
    required String sender,
  }) async {
    await _messages.add({
      'userId': userId,
      'message': message.trim(),
      'sender': sender,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
