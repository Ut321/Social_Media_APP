import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_media_app/services/post_controller.dart';

class AuthServices with ChangeNotifier {
  final PostUploader postUploader = PostUploader();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  late String userUid;
  String get getUserUid => userUid;

  //google signIn
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credentials
      UserCredential userCredential =
          await auth.signInWithCredential(authCredential);
      User? user = userCredential.user;

      if (user != null) {
        return user;
      } else {
        return null;
      }
    } catch (e) {
      print("Error during Google Sign In: $e");
      return null;
    }
    
  }

  //Signup
  Future signupUser(
      String email, String password, String name, BuildContext context) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await auth.currentUser!.updateDisplayName(name);
      await auth.currentUser!.updateEmail(email);
      await postUploader.saveUser(name, email, userCredential.user!.uid);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful')));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password Provided is too weak')));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Email Provided already Exists ,Please Login In !')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    notifyListeners();
  }

  //Login
  signinUser(String email, String password, BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('You are Logged in')));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user Found with this Email')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Incorrect email or password. Please provide the correct email or  password.'),
          ),
        );
      }
    }
    notifyListeners();
  }



//forget password
  Future resetPassword(String email, BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password reset email sent. Please check your email.'),
      ));
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          // Email is not registered, show a message
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Email is not registered. Please sign up.'),
          ));
        } else {
          // Handle other FirebaseAuthException codes as needed
          print('Error sending password reset email: ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${e.message}'),
          ));
        }
      } else {
        // Handle other exceptions as needed
        print('Error sending password reset email: $e');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Error sending password reset email. Please try again.'),
        ));
      }
    }
    notifyListeners();
  }
}
