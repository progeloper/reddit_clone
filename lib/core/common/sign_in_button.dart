import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clione/core/constants/constants.dart';
import 'package:reddit_clione/features/auth/controller/auth_controller.dart';
import 'package:reddit_clione/theme/palette.dart';

class SignInButton extends ConsumerWidget {
  final String label;
  final bool isFromLogin;
  const SignInButton({Key? key, required this.label, this.isFromLogin = true})
      : super(key: key);

  void signInWithGoogle(WidgetRef ref, BuildContext context){
    final authController = ref.read(authControllerProvider.notifier);
    authController.signInWithGoogle(context, isFromLogin);
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: ElevatedButton.icon(
        onPressed: () => signInWithGoogle(ref, context),
        icon: Image.asset(
          Constants.googlePath,
          width: 35,
        ),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Palette.greyColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ),
    );
  }
}
