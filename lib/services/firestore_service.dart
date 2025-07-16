import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static Future<void> askQuestion({
    required String recipeId,
    required String userId,
    required String questionText,
  }) async {
    await FirebaseFirestore.instance
        .collection('recipes')
        .doc(recipeId)
        .collection('qa')
        .add({
      'question': questionText,
      'askedBy': userId,
      'askedAt': FieldValue.serverTimestamp(),
      'answer': null,
      'answeredBy': null,
      'answeredAt': null,
    });
  }

  static Future<void> answerQuestion({
    required String recipeId,
    required String questionId,
    required String answerText,
    required String devId,
  }) async {
    await FirebaseFirestore.instance
        .collection('recipes')
        .doc(recipeId)
        .collection('qa')
        .doc(questionId)
        .update({
      'answer': answerText,
      'answeredBy': devId,
      'answeredAt': FieldValue.serverTimestamp(),
    });
  }
}
