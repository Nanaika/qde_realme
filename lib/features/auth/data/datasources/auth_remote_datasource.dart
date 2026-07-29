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

  Future<bool> getOnModerationStatus(String id);
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
    // final rawNonce = _generateNonce();
    //
    // final appleCredential = await SignInWithApple.getAppleIDCredential(
    //   scopes: [
    //     AppleIDAuthorizationScopes.email,
    //     AppleIDAuthorizationScopes.fullName,
    //   ],
    //   nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
    // );
    //
    // final OAuthCredential credential = OAuthProvider('apple.com').credential(
    //   idToken: appleCredential.identityToken,
    //   rawNonce: rawNonce,
    // );
    //
    // final userCredential = await _firebaseAuth.signInWithCredential(credential);

    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);
    final AuthorizationCredentialAppleID appleCredentials;

    appleCredentials = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredentials.identityToken,
      accessToken: appleCredentials.authorizationCode,
      rawNonce: rawNonce,
    );
    final userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);

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
  Future<dynamic> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<UserModel> getCurrentUser(String id) async {
    final docSnap = await db.collection(AppConstants.users).doc(id).get();
    return UserModel.fromJson(docSnap.data()!);
  }

  @override
  Future<bool> getOnModerationStatus(String id) async {
    final docSnap = await db
        .collection(AppConstants.moderateUsers)
        .doc(id)
        .get(const GetOptions(source: Source.server));

    return docSnap.exists;
  }

  String _generateNonce([int length = 32]) {
    const charset = '0123456789FFFFFFabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _generateNonce2([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }
}
