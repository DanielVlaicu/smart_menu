import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Register with email and password + send verification email
  Future<String?> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user!.sendEmailVerification();
      await saveUserToFirestore(result.user!);
      return 'success';
    } catch (e) {
      print('Register error: $e');
      return 'A apărut o eroare la înregistrare';
    }
  }

  // Login with email and password + check verification
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user!.emailVerified) {
        return 'success';
      } else {
        await result.user!.sendEmailVerification();
        await _auth.signOut();
        return 'Emailul nu este verificat. Verifică în inbox.';
      }
    } catch (e) {
      print('Login error: $e');
      return 'Email sau parolă incorecte';
    }
  }

  // Google Sign In
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential result = await _auth.signInWithCredential(credential);
      await saveUserToFirestore(result.user!);
      return 'success';
    } catch (e) {
      print('Google sign-in error: $e');
      return 'Autentificarea Google a eșuat';
    }
  }

  Future<void> saveUserToFirestore(User user) async {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final doc = usersRef.doc(user.uid);

    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'uid': user.uid,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'isGoogleUser': user.providerData.any((p) => p.providerId == 'google.com'),
      });
    }
  }

  // Reset password
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
