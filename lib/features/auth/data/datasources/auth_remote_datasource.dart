import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/auth/data/models/user_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

abstract class AuthRemoteDataSource {
  Future<UserCredential?> signInWithGoogle();

  Future<UserCredential?> signInWithApple();

  Future logout();

  Future<UserModel> getCurrentUser(String id);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final db = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<UserCredential> signInWithGoogle() async {
    await GoogleSignIn.instance.initialize();
    final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    if (userCredential.user != null) {
      final doc = await db.collection(AppConstants.users).doc(userCredential.user!.uid).get();
      if (!doc.exists) {
        final email = userCredential.user!.email ?? '';
        final user = UserModel(id: userCredential.user!.uid, email: email);
        await db.collection(AppConstants.users).doc(userCredential.user!.uid).set(user.toJson());
      }
    }

    return userCredential;
  }

  @override
  Future<UserCredential> signInWithApple() async {
    final rawNonce = _generateNonce();

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
    );

    final OAuthCredential credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);

    if (userCredential.user != null) {
      final doc = await db.collection(AppConstants.users).doc(userCredential.user!.uid).get();
      if (!doc.exists) {
        final email = userCredential.user!.email ?? '';
        final user = UserModel(id: userCredential.user!.uid, email: email);
        await db.collection(AppConstants.users).doc(userCredential.user!.uid).set(user.toJson());
      }
    }
    return userCredential;
  }

  @override
  Future<dynamic> logout() {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> getCurrentUser(String id) async {
    final docSnap = await db.collection(AppConstants.users).doc(id).get();
    return UserModel.fromJson(docSnap.data()!);
  }

  String _generateNonce([int length = 32]) {
    const charset = '0123456789FFFFFFabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }
}
