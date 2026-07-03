import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserCredential?> signInWithGoogle();

  Future<UserCredential?> signInWithApple();

  Future logout();
  Future<UserModel> getCurrentUser(String id);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final db = FirebaseFirestore.instance;

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
  Future<UserCredential?> signInWithApple() {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> logout() {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> getCurrentUser(String id) async{
    final docSnap = await db.collection(AppConstants.users).doc(id).get();
    return UserModel.fromJson(docSnap.data()!);

  }
}
