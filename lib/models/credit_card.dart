import 'package:cloud_firestore/cloud_firestore.dart';

class CreditCard {
  final String id;
  final String name;
  final String url;
  final String userId;

  CreditCard({required this.id, required this.name, required this.url, required this.userId});

  factory CreditCard.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CreditCard(
      id: doc.id,
      name: data['name'] ?? '',
      url: data['url'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'url': url,
      'userId': userId,
    };
  }
}
