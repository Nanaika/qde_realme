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

  Future deleteUser(String id);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final db = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<UserCredential> signInWithGoogle() async {
    await GoogleSignIn.instance.initialize();
    final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
    print('LOGIN==================google user  ${googleUser}');

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
    print('LOGIN==================cred  ${googleUser}');

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    if (userCredential.user == null || userCredential.user!.uid.trim().isEmpty) {
      throw Exception('Firebase Auth dont return user UID');
    }
    print('LOGIN==================user  ${userCredential}');

    final doc = await db.collection(AppConstants.users).doc(userCredential.user!.uid).get();
    if (!doc.exists) {
      final email = userCredential.user!.email ?? '';
      final user = UserModel(id: userCredential.user!.uid, email: email);
      await db.collection(AppConstants.users).doc(userCredential.user!.uid).set(user.toJson());
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
    if (userCredential.user == null || userCredential.user!.uid.trim().isEmpty) {
      throw Exception('Firebase Auth dont return user UID');
    }

    final doc = await db.collection(AppConstants.users).doc(userCredential.user!.uid).get();
    if (!doc.exists) {
      final email = userCredential.user!.email ?? '';
      final user = UserModel(id: userCredential.user!.uid, email: email);
      await db.collection(AppConstants.users).doc(userCredential.user!.uid).set(user.toJson());
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

  @override
  Future<dynamic> deleteUser(
    String userId,
  ) async {
    final DocumentReference userRef = db.collection(AppConstants.users).doc(userId);

    final QuerySnapshot subCol1Docs = await userRef.collection(AppConstants.ownerSales).get();
    final QuerySnapshot subCol2Docs = await userRef.collection(AppConstants.history).get();

    final DocumentReference moderationUserRef = db.collection(AppConstants.moderateUsers).doc(userId);

    final QuerySnapshot moderationSalesDocs = await db
        .collection(AppConstants.moderateSales)
        .where('ownerId', isEqualTo: userId)
        .get();

    // 3. Удаляем профиль на модерации
    await moderationUserRef.delete();

    // 4. Удаляем продажи на модерации
    for (final doc in moderationSalesDocs.docs) {
      await doc.reference.delete();
    }

    // 1. Удаляем документы из первой подколлекции
    for (final doc in subCol1Docs.docs) {
      await doc.reference.delete();
    }

    // 2. Удаляем документы из второй подколлекции
    for (final doc in subCol2Docs.docs) {
      await doc.reference.delete();
    }

    // 5. Удаляем самого юзера
    await userRef.delete();

    // 6. УДАЛЕНИЕ ИЗ FIREBASE AUTH
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.uid == userId) {
      await currentUser.delete();
    }
  }
}
