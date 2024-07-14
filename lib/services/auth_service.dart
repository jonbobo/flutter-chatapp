import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  // create a reference to the users in realtime database
  final DatabaseReference usersRef =
      FirebaseDatabase.instance.ref().child('users');

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await usersRef.child(userCredential.user!.uid).update({'online': true});
      return userCredential.user;
    } catch (e) {
      if (kDebugMode) {
        print("Error during login: $e");
      }
      return null;
    }
  }

  void setOnlineStatus(bool online) async {
    User? user = auth.currentUser;
    if (user != null) {
      await usersRef.child(user.uid).update({'online': online});
    }
  }

  void updateUsername(String username) {
    User? user = auth.currentUser;
    if (user != null) {
      user.updateDisplayName(username);
      usersRef.child(user.uid).update({'displayName': username});
    }
  }

  void updateGuestProfile(String email, String password, String username) async {
    User? user = auth.currentUser;
    if (user != null) {
      try {
        print('User not null and anonymous');

        // Create credentials for the new email and password
        final credential =
            EmailAuthProvider.credential(email: email, password: password);

        // Link the new credentials with the anonymous user
        await user.linkWithCredential(credential);

        print('Email and password updated successfully');

        // change the user's display name
        await user.updateDisplayName(username);


        // You may want to update additional user information if needed
        // usersRef.child(user.uid).update({'email': email});
      } catch (e) {
        print('Error updating email and password: $e');
        // Handle the error appropriately
      }
    } else {
      print('User is not anonymous or is null');
      // Handle the case when the user is not anonymous or is not signed in
    }
  }

  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      // Update the user profile with the provided username
      if (user != null) {
        await user.updateDisplayName(username);
      }

      // use user id as document id, key displayName to store username and online to store user online status
      await usersRef.child(user!.uid).set({
        'displayName': username,
        'online': true,
      });

      return user;
    } catch (e) {
      if (kDebugMode) {
        print("Error during sign up: $e");
      }
      return null;
    }
  }

  Future<User?> signInAnonymously() async {
    try {
      UserCredential userCredential = await auth.signInAnonymously();

      User? user = userCredential.user;

      if (user == null) {
        return null;
      }

      String username = 'Guest ${user.uid.substring(0, 5)}';

      await usersRef.child(user!.uid).set({
        'displayName': username,
        'online': true,
      });

      // Return the refreshed user
      return user;
    } catch (e) {
      if (kDebugMode) {
        print("Error during guest login: $e");
      }
      return null;
    }
  }

  bool isGuest() {
    final currentUser = auth.currentUser;
    return currentUser != null && currentUser.displayName == null && currentUser.email == null;
  }

  Future<User?> getCurrentUser() async {
    try {
      User? user = auth.currentUser;
      if (user == null) {
        // If no user is currently signed in
        return null;
      }
      await user.reload(); // Refresh user data
      return auth.currentUser;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting current user: $e");
      }
      return null;
    }
  }

  Future<void> updateProfile(String newDisplayName, String newEmail) async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(newDisplayName);
        await user.verifyBeforeUpdateEmail(newEmail);

        // Update display name and email in the database
        await usersRef.child(user.uid).update({
          'displayName': newDisplayName,
          'email': newEmail,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating profile: $e");
      }
      throw e;
    }
  }

  void signOut() async {
    // Check if the user is signed in
    User? user = auth.currentUser;

    if (user != null && user.email != null) {
      // User has an email, update online status
      await usersRef.child(user.uid).update({'online': false});
      await auth.signOut();
    } else {
      // User is a guest user, delete their account
      if (user != null) {
        await usersRef.child(user.uid).remove();
        await user.delete();
      }
    }
  }
}
