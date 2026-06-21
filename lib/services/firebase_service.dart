import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase service utility for initialization and common operations
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  // Getters for Firebase instances
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user UID
  String? get currentUserUid => _auth.currentUser?.uid;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Sign out user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Get Firestore collection reference
  CollectionReference getCollection(String collectionPath) {
    return _firestore.collection(collectionPath);
  }

  // Get Firestore document reference
  DocumentReference getDocument(String collectionPath, String docId) {
    return _firestore.collection(collectionPath).doc(docId);
  }

  // Batch write operations for multiple documents
  WriteBatch getBatch() {
    return _firestore.batch();
  }

  // Handle Firestore exceptions
  static String handleFirestoreException(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You do not have permission to access this data.';
        case 'not-found':
          return 'The requested document was not found.';
        case 'unavailable':
          return 'Service is currently unavailable. Please try again later.';
        case 'unauthenticated':
          return 'You must be logged in to perform this action.';
        default:
          return 'An error occurred: ${error.message}';
      }
    }
    return 'An unexpected error occurred: $error';
  }

  // Handle Firebase Auth exceptions
  static String handleAuthException(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'operation-not-allowed':
          return 'This operation is not allowed.';
        case 'too-many-requests':
          return 'Too many login attempts. Please try again later.';
        default:
          return 'Authentication error: ${error.message}';
      }
    }
    return 'An unexpected authentication error occurred: $error';
  }
}
