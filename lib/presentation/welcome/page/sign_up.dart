import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotifyapp/common/widgets/appbar/app_bar.dart';
import 'package:spotifyapp/common/widgets/button/login_button.dart';
import 'package:spotifyapp/presentation/home/page/home_page.dart';
import 'package:spotifyapp/presentation/welcome/page/log_in.dart';

import '../../../core/configs/assets/app_vector.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: _registerText(context),
        appBar: BasicAppBar(
          title: SvgPicture.asset(
            AppVectors.logo,
            height: 40,
            width: 40,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              registerText(),
              const SizedBox(
                height: 50,
              ),
              emailAddress(context),
              const SizedBox(
                height: 20,
              ),
              password(context),
              const SizedBox(
                height: 20,
              ),
              LoginButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => const HomePage()));
                },
                title: 'Create Account',
                height: 80,
              ),
            ],
          ),
        ));
  }

  Widget registerText() {
    return const Text(
      'Register',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget emailAddress(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        hintText: ' Enter Email Address',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget password(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Create Password',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _registerText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Do you have an account? ',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const LogIn()));
              },
              child: const Text('Sign in'))
        ],
      ),
    );
  }
}
