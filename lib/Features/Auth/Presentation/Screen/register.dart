// ignore_for_file: camel_case_types, depend_on_referenced_packages

import '../Cubit/auth_States.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Components/inputText.dart';
import '../Cubit/authCubit.dart';

// ignore: duplicate_ignore
// ignore: camel_case_types, must_be_immutable
class registerScreen extends StatefulWidget {
  void Function()? backToLogin;
  registerScreen({super.key, required this.backToLogin});

  @override
  State<registerScreen> createState() => _registerScreenState();
}

class _registerScreenState extends State<registerScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  bool isLoading = false;

  void register() async {
    final String email = emailController.text.trim();
    final String password = passController.text.trim();
    final String name = nameController.text.trim();

    final bool checkMail = EmailValidator.validate(email);

    if (checkMail && password.length >= 6 && name.length >= 4) {
      setState(() {
        isLoading = true;
      });
      final user =
          await context.read<Authcubit>().register(name, email, password);
      if (!mounted) return;
      if (user != null) {
        Navigator.pop(context);
      }
    } else if (!checkMail && password.isNotEmpty && name.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Email không hợp lệ', style: TextStyle(fontSize: 16))));
    } else if (name.length < 4 && checkMail && password.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tên phải có ít nhất 4 ký tự',
              style: TextStyle(fontSize: 16))));
    } else if (password.length < 6 && checkMail && name.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Mật khẩu phải có ít nhất 6 ký tự',
              style: TextStyle(fontSize: 16))));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Bạn cần nhập đầy đủ thông tin',
              style: TextStyle(fontSize: 16))));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    nameController.dispose();
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
                    onTap: widget.backToLogin,
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
                            vertical: isTablet ? 22 : 18),
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
                              height: isTablet ? 110 : 90,
                              child: Image.asset(
                                'assets/images/themovie.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Bắt đầu ngay!',
                              style: TextStyle(
                                  fontSize: isTablet ? 30 : 26,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nhập thông tin của bạn bên dưới',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                            const SizedBox(height: 12),
                            Inputtext(
                                prefixIcon: Icons.person,
                                isObscureText: false,
                                controller: nameController,
                                hintText: 'Tên người dùng',
                                isPass: false),
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
                            const SizedBox(height: 14),
                            GestureDetector(
                              onTap: register,
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
                                        'Đăng ký',
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
                            const SizedBox(height: 12),
                            Text(
                              'Hoặc tiếp tục với',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(14)),
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            width: 1.0),
                                      ),
                                      child: Image.asset(
                                        'assets/images/iconGG.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(14)),
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            width: 1.0),
                                      ),
                                      child: Image.asset(
                                        'assets/images/appleIcon.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '''Bạn đã có tài khoản?''',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                                GestureDetector(
                                  onTap: widget.backToLogin,
                                  child: Text(
                                    ' Đăng nhập',
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
      )),
    );
  }
}
