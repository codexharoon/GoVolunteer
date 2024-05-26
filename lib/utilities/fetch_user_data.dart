import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
  Future<Map<String, dynamic>> fetchUserData() async {
    try {
      // Get the current user's UID
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      final firestore = FirebaseFirestore.instance;
      if (uid == null) {
        // Handle the case where the user is not authenticated
        print('User is not authenticated');
        return {};
      }

      // Fetch user document from Firestore
      DocumentSnapshot userSnapshot =
          await firestore.collection('users').doc(uid).get();

      // Check if the document exists and the expected fields are present
      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          return userData;
        } else {
          print('User data is null');
          return {};
        }
      } else {
        return {};
        print('User document does not exist');
      }
    } catch (e) {
      // Handle errors
      print('Error fetching user data: $e');
      return {};
    }
  }
