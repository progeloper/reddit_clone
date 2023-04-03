import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_clione/core/constants/firebase_constants.dart';
import 'package:reddit_clione/core/failure.dart';
import 'package:reddit_clione/core/providers/firebase_providers.dart';
import 'package:reddit_clione/core/type_defs.dart';
import 'package:reddit_clione/models/user_model.dart';

import '../../../core/constants/constants.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    auth: ref.read(firebaseAuthProvider),
    firestore: ref.read(firestoreProvider),
    googleSignIn: ref.read(googleProvider),
  );
});

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository(
      {required FirebaseAuth auth,
      required FirebaseFirestore firestore,
      required GoogleSignIn googleSignIn})
      : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signIn();

      final googleAuth = await user?.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCred;
      if(isFromLogin){
        userCred = await _auth.signInWithCredential(cred);
      } else{
        userCred = await _auth.currentUser!.linkWithCredential(cred);
      }



      UserModel userModel;

      if (userCred.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
            name: userCred.user!.displayName ?? 'No name',
            profilePic: userCred.user!.photoURL ?? Constants.avatarDefault,
            banner: Constants.bannerDefault,
            uid: userCred.user!.uid,
            isAuthenticated: true,
            karma: 0,
            awards: [
              'awesomeAnswer',
              'gold',
              'helpful',
              'platinum',
              'plusOne',
              'thankYou',
              'rocket',
              'til',
            ]);
        await _users.doc(userModel.uid).set(userModel.toMap());
      } else {
        userModel = await (getUserData(userCred.user!.uid)).first;
      }
      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel> signInAsGuest() async {
    try {
      final userCred = await _auth.signInAnonymously();
        UserModel userModel = UserModel(
            name: 'Guest',
            profilePic: Constants.avatarDefault,
            banner: Constants.bannerDefault,
            uid: userCred.user!.uid,
            isAuthenticated: false,
            karma: 0,
            awards: []);
        await _users.doc(userModel.uid).set(userModel.toMap());

      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
        (event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }

  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
