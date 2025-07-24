import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Înregistrare cu email + trimite email de verificare + initializează structura
  Future<String?> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user!.sendEmailVerification();
      await saveUserToFirestore(result.user!);

      //  Apel initialize pentru utilizator nou
      await initializeDefaultsOnce();

      return 'success';
    } catch (e) {
      print('Register error: $e');
      return 'A apărut o eroare la înregistrare';
    }
  }

  //  Verifică dacă e deja inițializat și apelează backendul /initialize
  static Future<void> initializeDefaultsOnce() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await doc.get();

    if (snapshot.exists && snapshot.data()?['initialized'] == true) {
      return; // Deja inițializat
    }

    final token = await user.getIdToken();
    final response = await http.post(
      Uri.parse('https://firebase-storage-141030912906.europe-west1.run.app/initialize'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      await doc.set({'initialized': true}, SetOptions(merge: true));
    } else {
      print('Eroare la /initialize: ${response.body}');
    }
  }

  //  Login cu email și parolă + verificare email + initialize
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user!.emailVerified) {
        await initializeDefaultsOnce();
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

  //  Autentificare cu Google + initialize
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
      await initializeDefaultsOnce();
      return 'success';
    } catch (e) {
      print('Google sign-in error: $e');
      return 'Autentificarea Google a eșuat';
    }
  }

  //  Salvează utilizatorul în Firestore
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

  //  Resetare parolă
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Logout complet
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
