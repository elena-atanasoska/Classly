import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/CustomUser.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  CustomUser? _userFromFirebaseUser(User? user) {
    return user != null ? CustomUser.fromFirebaseUser(user) : null;
  }

  Future<CustomUser?> register(String email, String password, String firstName, String lastName) async {
    try {
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = authResult.user;
      await user?.updateDisplayName('$firstName $lastName');

      return _userFromFirebaseUser(user);
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }


  Future<CustomUser?> login(String email, String password) async {
    try {
      UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = authResult.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }


  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<CustomUser?> get userStream {
    return _auth.authStateChanges().map((user) => _userFromFirebaseUser(user));
  }
}
