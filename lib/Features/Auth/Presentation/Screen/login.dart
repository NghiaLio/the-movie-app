// ignore_for_file: must_be_immutable, use_build_context_synchronously

import '../Cubit/auth_States.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Components/inputText.dart';
import '../Cubit/authCubit.dart';
import 'resetPass.dart';

class LoginScreen extends StatefulWidget {
  void Function()? pushToSignUpPage;
  final bool isError;

  LoginScreen(
      {super.key, required this.pushToSignUpPage, required this.isError});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController emailToResetController = TextEditingController();

  bool isLoading = false;

  void login() async {
    final String email = emailController.text.trim();
    final String password = passController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty && password.length >= 6) {
      setState(() {
        isLoading = true;
      });
      final user = await context.read<Authcubit>().login(email, password);
      if (!mounted) return;
      if (user != null) {
        Navigator.pop(context);
      }
    } else if (password.length < 6 && email.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        'Mật khẩu phải có ít nhất 6 ký tự',
        style: TextStyle(fontSize: 16),
      )));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Bạn cần nhập email và mật khẩu',
              style: TextStyle(fontSize: 16))));
    }
  }

  // click forgot button
  void forgotPassword() {
    showDialog(
        context: context,
        builder: (c) => Resetpass(
              controller: emailToResetController,
              onSend: onSend,
            ));
  }

  //click send email
  void onSend() async {
    final email = emailToResetController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Vui lòng nhập email', style: TextStyle(fontSize: 16))));
      return;
    }

    final isSent = await context.read<Authcubit>().resetPass(email);
    if (!mounted) return;
    if (isSent) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Đã gửi liên kết đặt lại mật khẩu',
              style: TextStyle(fontSize: 16))));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    emailToResetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 700;

    return BlocListener<Authcubit, AuthStates>(
      listener: (context, state) {
        if (state is loading) {
          if (!isLoading) {
            setState(() {
              isLoading = true;
            });
          }
        }
        if (state is Authenticated ||
            state is UnAuthenticated ||
            state is Error) {
          if (isLoading) {
            setState(() {
              isLoading = false;
            });
          }
        }
        if (state is Error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message ?? 'Đã xảy ra lỗi',
                  style: const TextStyle(fontSize: 16))));
        }
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        !widget.isError
                            ? Navigator.pop(context)
                            : context.read<Authcubit>().backToHome();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: isTablet ? 44 : 40,
                        height: isTablet ? 44 : 40,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 28 : 18,
                              vertical: isTablet ? 24 : 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.14),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(24)),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: isTablet ? 120 : 98,
                                child: Image.asset(
                                  'assets/images/themovie.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Chào mừng trở lại!',
                                style: TextStyle(
                                    fontSize: isTablet ? 30 : 26,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Nhập thông tin của bạn bên dưới',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                              const SizedBox(height: 14),
                              Inputtext(
                                  prefixIcon: Icons.email,
                                  isObscureText: false,
                                  controller: emailController,
                                  hintText: 'Email của bạn',
                                  isPass: false),
                              Inputtext(
                                prefixIcon: Icons.password,
                                isObscureText: true,
                                controller: passController,
                                hintText: 'Mật khẩu',
                                isPass: true,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: forgotPassword,
                                  child: Text(
                                    'Quên mật khẩu?',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              GestureDetector(
                                onTap: login,
                                child: Container(
                                  height: 54,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(16))),
                                  child: !isLoading
                                      ? Text(
                                          'Đăng nhập',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer,
                                              fontWeight: FontWeight.w600),
                                        )
                                      : CircularProgressIndicator(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          strokeWidth: 3.2,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '''Bạn chưa có tài khoản?''',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                  GestureDetector(
                                    onTap: widget.pushToSignUpPage,
                                    child: Text(
                                      ' Đăng ký',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
