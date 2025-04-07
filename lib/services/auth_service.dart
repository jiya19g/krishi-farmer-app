import 'package:farmer_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(), 
        password: password
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("Error signing in: $e");
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<User?> registerWithEmail(
    String email, 
    String password, 
    String name,
    String phone,
    String state,
    String city,
    String farmSize,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), 
        password: password
      );
      
      await _firestore.collection('users').doc(result.user?.uid).set({
        'uid': result.user?.uid,
        'email': email.trim(),
        'name': name.trim(),
        'phone': phone.trim(),
        'state': state,
        'city': city,
        'farmSize': farmSize,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return result.user;
    } catch (e) {
      print("Error registering: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
      rethrow;
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error getting user data: $e");
      rethrow;
    }
  }

  Future<void> updateUserData(
    String uid,
    String name,
    String phone,
    String state,
    String city,
    String farmSize,
  ) async {
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
}