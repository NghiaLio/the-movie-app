// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../../../Components/inputText.dart';

class Resetpass extends StatelessWidget {
  final TextEditingController controller;
  void Function()? onSend;
  Resetpass({super.key, required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Đặt lại mật khẩu',
        style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary),
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.17,
        child: Column(
          children: [
            Text(
              'Nhập email, chúng tôi sẽ gửi liên kết đặt lại mật khẩu cho bạn',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, fontSize: 18),
            ),
            Inputtext(
                prefixIcon: Icons.email,
                isObscureText: false,
                isPass: false,
                controller: controller,
                hintText: 'Email')
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: onSend,
            child: const Text(
              'Gửi',
              style: TextStyle(fontSize: 24),
            ))
      ],
    );
  }
}
