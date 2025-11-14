import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  static CollectionReference get usersCollection =>
      _firestore.collection('users');
  static CollectionReference get productsCollection =>
      _firestore.collection('products');
  static CollectionReference get ordersCollection =>
      _firestore.collection('orders');

  // Auth methods
  static User? get currentUser => _auth.currentUser;

  static Future<UserCredential> signInWithEmail(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  static Future<UserCredential> signUpWithEmail(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Firestore methods
  static Future<void> addUser(String uid, Map<String, dynamic> userData) async {
    await usersCollection.doc(uid).set(userData);
  }

  static Stream<QuerySnapshot> getProducts() {
    return productsCollection.snapshots();
  }

  static Future<void> placeOrder(Map<String, dynamic> orderData) async {
    await ordersCollection.add(orderData);
  }
}
