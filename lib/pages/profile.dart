import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/pages/user_profile_screen.dart';
import 'signin_screen.dart';

// User Profile Model
class UserProfile {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String profilePhotoUrl;
  final String type;

  UserProfile({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.profilePhotoUrl,
    required this.type,
  });

  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    return UserProfile(
      fullName: doc['fullName'],
      email: doc['email'],
      phoneNumber: doc['phone_number'],
      address: doc['address'],
      profilePhotoUrl: doc['profilePhotoUrl'],
      type: doc['type'],
    );
  }
}

// Function to fetch user profile from Firestore
Future<UserProfile?> getUserProfile() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
    if (doc.exists) {
      return UserProfile.fromDocument(doc);
    }
  }
  return null;
}

// Profile Page Widget
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const UserProfileScreen();
          } else {
            return const SignInScreen();
          }
        },
      ),
    );
  }
}