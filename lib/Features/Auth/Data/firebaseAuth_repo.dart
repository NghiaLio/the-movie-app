// ignore: file_names
// ignore_for_file: file_names, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Domain/Entities/UserModel.dart';
import '../Domain/Repo/authRepo.dart';

class FirebaseauthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  String _authMessageFromCode(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Tài khoản hoặc mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Email đã tồn tại.';
      case 'weak-password':
        return 'Mật khẩu quá yếu.';
      case 'too-many-requests':
        return 'Bạn thao tác quá nhiều lần, vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng, vui lòng kiểm tra internet.';
      default:
        return e.message ?? 'Đã xảy ra lỗi xác thực. Vui lòng thử lại.';
    }
  }

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final AppUser? user = await getCurrentUser();
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_authMessageFromCode(e));
    } catch (_) {
      throw Exception('Không thể đăng nhập. Vui lòng thử lại.');
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
      String name, String email, String password) async {
    try {
      // sign up
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // create user
      AppUser userReturn =
          AppUser(userName: name, email: email, uid: userCredential.user!.uid);

      // save to firestore
      await firebaseFirestore
          .collection('User')
          .doc(userReturn.uid)
          .set(userReturn.toJson());

      return userReturn;
    } on FirebaseAuthException catch (e) {
      throw Exception(_authMessageFromCode(e));
    } catch (_) {
      throw Exception('Không thể đăng ký tài khoản. Vui lòng thử lại.');
    }
  }

  @override
  Future<void> logOut() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      // get firebase user logged
      final firebaseUser = firebaseAuth.currentUser;

      // no user
      if (firebaseUser == null) {
        return null;
      }
      final AppUser? currentUser = await firebaseFirestore
          .collection('User')
          .doc(firebaseUser.uid)
          .get()
          .then((value) {
        if (value.exists) {
          return AppUser.fromJson(value.data()!);
        } else {
          return null;
        }
      });
      // user exists
      return currentUser;
    } catch (e) {
      throw Exception('Fail: $e');
    }
  }
}
