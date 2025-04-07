import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Operations
  Future<void> updateUserData({
    required String uid,
    required String name,
    required String phone,
    required String state,
    required String city,
    required String farmSize,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'name': name.trim(),
        'phone': phone.trim(),
        'state': state,
        'city': city,
        'farmSize': farmSize,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating user data: $e");
      rethrow;
    }
  }

  Future<DocumentSnapshot> getUserData(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  // Discussion Operations
  Future<DocumentReference> createDiscussion({
    required String content,
    required String category,
    required String authorId,
  }) async {
    try {
      return await _firestore.collection('discussions').add({
        'content': content,
        'authorId': authorId,
        'category': category,
        'timestamp': FieldValue.serverTimestamp(),
        'likeCount': 0,
        'commentCount': 0,
      });
    } catch (e) {
      print("Error creating discussion: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getDiscussions({String? category}) {
    Query query = _firestore.collection('discussions')
      .orderBy('timestamp', descending: true);
    
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    
    return query.snapshots();
  }

  // Comment Operations - SIMPLIFIED VERSION
  Future<void> addComment({
    required String discussionId,
    required String content,
    required String authorId,
  }) async {
    try {
      // First create the comment document
      await _firestore
          .collection('discussions')
          .doc(discussionId)
          .collection('comments')
          .add({
            'content': content,
            'authorId': authorId,
            'timestamp': FieldValue.serverTimestamp(),
          });

      // Then update the comment count separately
      await _firestore.collection('discussions').doc(discussionId).update({
        'commentCount': FieldValue.increment(1)
      });
    } catch (e) {
      print("Error adding comment: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getComments(String discussionId) {
    return _firestore
        .collection('discussions')
        .doc(discussionId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  // Activity Methods
Future<String> addActivity({
  required String userId,
  required String title,
  required DateTime date,
  required String tag,
  required String phone,
  required bool wantsReminder,
}) async {
  try {
    final docRef = await _firestore.collection('activities').add({
      'userId': userId,
      'title': title,
      'date': date, // Stored as Timestamp
      'tag': tag,
      'phone': phone.isEmpty ? await _getUserPhone(userId) : phone,
      'wantsReminder': wantsReminder,
      'status': 'pending', // pending/sent/failed
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  } catch (e) {
    print("Error adding activity: $e");
    rethrow;
  }
}

Future<String> _getUserPhone(String userId) async {
  final doc = await _firestore.collection('users').doc(userId).get();
  return doc['phone'] ?? ''; // Fallback to empty if phone not set
}

Stream<QuerySnapshot> getUserActivities(String userId) {
  return _firestore
      .collection('activities')
      .where('userId', isEqualTo: userId)
      .orderBy('date', descending: false)
      .snapshots();
}

Future<void> updateActivityStatus(String activityId, String status) async {
  await _firestore.collection('activities').doc(activityId).update({
    'status': status,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

}