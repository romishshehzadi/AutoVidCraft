import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==========================
  // REGISTER USER
  // ==========================
  Future<User?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    // create account
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // save user data in firestore
    await _firestore.collection("users").doc(result.user!.uid).set({
      "uid": result.user!.uid,
      "name": name,
      "email": email,
      "role": "user",
      "createdAt": Timestamp.now(),
    });

    return result.user;
  }

  // ==========================
  // LOGIN USER
  // ==========================
  Future<DocumentSnapshot?> login({
    required String email,
    required String password,
  }) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 🔥 THIS IS THE KEY PART
    // same UID used to fetch profile
    return await _firestore.collection("users").doc(result.user!.uid).get();
  }

  // ==========================
  // CURRENT LOGGED IN USER
  // ==========================
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // ==========================
  // GET PROFILE DATA
  // ==========================
  Future<DocumentSnapshot?> getProfileData() async {
    User? user = _auth.currentUser;

    if (user == null) return null;

    return await _firestore.collection("users").doc(user.uid).get();
  }

  // ==========================
  // RESET PASSWORD
  // ==========================
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ==========================
  // LOGOUT
  // ==========================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ==========================
  // GOOGLE SIGN IN (NEW METHOD)
  // ==========================
  Future<User?> signInWithGoogle() async {
    try {
      // Initialize Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credentials
      UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      User? user = userCredential.user;

      // Check if user is new (first time login)
      if (userCredential.additionalUserInfo!.isNewUser) {
        // Create user document in Firestore
        await _firestore.collection('users').doc(user!.uid).set({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName ?? 'Google User',
          'role': 'user',  // Default role
          'createdAt': FieldValue.serverTimestamp(),
          'photoURL': user.photoURL,
          'provider': 'google',
        });
      } else {
        // Update last login time for existing user
        await _firestore.collection('users').doc(user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      print("Google Sign In Error: $e");
      rethrow;
    }
  }

  // ==========================
  // GITHUB SIGN IN (NEW METHOD)
  // ==========================
  Future<User?> signInWithGitHub() async {
    try {
      // Create a new GitHub provider instance
      GithubAuthProvider githubProvider = GithubAuthProvider();

      // Sign in with GitHub
      UserCredential userCredential =
      await _auth.signInWithProvider(githubProvider);

      User? user = userCredential.user;

      // Check if user is new
      if (userCredential.additionalUserInfo!.isNewUser) {
        // Get GitHub username from additional user info
        String? githubUsername;
        if (userCredential.additionalUserInfo!.profile != null) {
          var profile = userCredential.additionalUserInfo!.profile as Map<String, dynamic>;
          githubUsername = profile['login'];
        }

        // Create user document
        await _firestore.collection('users').doc(user!.uid).set({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName ?? githubUsername ?? 'GitHub User',
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
          'photoURL': user.photoURL,
          'githubUsername': githubUsername,
          'provider': 'github',
        });
      } else {
        // Update last login
        await _firestore.collection('users').doc(user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      print("GitHub Sign In Error: $e");
      rethrow;
    }
  }
}