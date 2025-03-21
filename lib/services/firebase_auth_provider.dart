import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/services/exceptions.dart';
import 'package:chatapp/model/auth_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthProvider {

  AuthUser? get getUser {

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }

  }

  Future<void> initialise() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  Future<AuthUser?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try{
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = getUser;
      if (user != null) {
        final User currUser = userCredential.user!;
        await currUser.updateProfile(displayName: name, photoURL: '');

        return user;
      }
      else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseException catch(e){
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch(e){
      throw GenericAuthException();

    }
  }

  Future<AuthUser?> signIn({
    required String email,
    required String password,
  }) async {
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = getUser;
      if (user != null) {
        return user;
      }
      else{
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch(e){
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      }
      else if(e.code == 'invalid-credential'){
        throw CouldNotFindUserAuthException();
      }
      else {
        throw GenericAuthException();
      }
    } catch(e){
      throw GenericAuthException();

    }

  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch(e){
      if(e.code == 'firebase_auth/invalid-email'){
        throw InvalidEmailAuthException();
      }
      else if(e.code == 'firebase_auth/user-not-found'){
        throw UserNotFoundAuthException();
      }
      else{
        throw GenericAuthException();
      }
    } catch(e){
      throw GenericAuthException();
    }

  }

  Future<void> sendEmailVerification({required String email}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      user.sendEmailVerification();
    }
    else{
      throw UserNotLoggedInAuthException();
    }
  }
  Future<void> logout()async{
    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      await FirebaseAuth.instance.signOut();
    }
    else{
      throw UserNotLoggedInAuthException();
    }
  }

}
