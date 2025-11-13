import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:card_ai/models/credit_card.dart';

class CardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<CreditCard>> getCardsForUser() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('cards')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CreditCard.fromFirestore(doc)).toList();
    });
  }

  Future<void> addCard(String name, String url) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    await _firestore.collection('cards').add({
      'name': name,
      'url': url,
      'userId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCard(String cardId, String name, String url) async {
    await _firestore.collection('cards').doc(cardId).update({
      'name': name,
      'url': url,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCard(String cardId) async {
    await _firestore.collection('cards').doc(cardId).delete();
  }
}
