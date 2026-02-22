// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Domain/Entities/UserModel.dart';
import '../../Domain/Repo/authRepo.dart';
import 'auth_States.dart';

class Authcubit extends Cubit<AuthStates> {
  AppUser? _currentUser;
  final AuthRepo authRepo;

  Authcubit({required this.authRepo}) : super(initial());

  String _errorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return 'Đã xảy ra lỗi, vui lòng thử lại.';
  }

  // check if user logged
  void checkAuth() async {
    try {
      final AppUser? user = await authRepo.getCurrentUser();

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(Error(_errorMessage(e)));
    }
  }

  //get currentUser
  AppUser? get currentUser => _currentUser;
  //login
  Future<AppUser?> login(String email, String password) async {
    try {
      emit(loading());
      final user = await authRepo.loginWithEmailPassword(email, password);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
        return user;
      } else {
        emit(Error('Đăng nhập thất bại.'));
      }
    } catch (e) {
      emit(Error(_errorMessage(e)));
    }
    return null;
  }

  //register
  Future<AppUser?> register(String name, String email, String password) async {
    try {
      emit(loading());
      final user =
          await authRepo.registerWithEmailPassword(name, email, password);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
        return user;
      } else {
        emit(Error('Đăng ký thất bại.'));
      }
    } catch (e) {
      emit(Error(_errorMessage(e)));
    }
    return null;
  }

  //logOut
  Future<void> logOut() async {
    await authRepo.logOut();
    emit(UnAuthenticated());
  }

  //back to home when login fail
  Future<void> backToHome() async {
    emit(UnAuthenticated());
  }

  //reset pass
  Future<bool> resetPass(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      emit(Error(e.message ?? 'Không thể gửi email đặt lại mật khẩu.'));
      return false;
    } catch (e) {
      emit(Error(_errorMessage(e)));
      return false;
    }
  }
}
