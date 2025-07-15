import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // potreban zbog Navigatora i ScaffoldMessenger-a

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Login error';
    }
  }

  Future<User?> signUpWithEmail(String email, String password, String name, String role) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': Timestamp.now(),
      });

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Registration error';
    }
  }

  /// 🔐 PRIJAVA korisnika + automatsko preusmjeravanje na temelju role
  Future<void> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      final role = doc.data()?['role'];

      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin-setup');
      } else if (role == 'user') {
        Navigator.pushReplacementNamed(context, '/user-dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nepoznata uloga korisnika.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: ${e.toString()}')),
      );
    }
  }

  void signOut() {
    _auth.signOut();
  }

  Stream<User?> get userChanges => _auth.userChanges();
}