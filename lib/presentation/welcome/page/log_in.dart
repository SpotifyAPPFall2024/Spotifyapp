import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotifyapp/common/widgets/appbar/app_bar.dart';
import 'package:spotifyapp/common/widgets/button/login_button.dart';
import 'package:spotifyapp/core/utils/authentication_service.dart';
import 'package:spotifyapp/presentation/home/page/home_page.dart';
import 'package:spotifyapp/presentation/welcome/page/sign_up.dart';

import '../../../core/configs/assets/app_vector.dart';

class LogIn extends StatelessWidget {
  const LogIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: _loginText(context),
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
              loginText(),
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
                onPressed: () async {
                  final authService = AuthenticationService();
                  final accesstoken = await authService.login();
                  if (accesstoken != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            HomePage(accessToken: accesstoken),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login failed')),
                    );
                  }
                },
                title: 'Log in',
                height: 80,
              ),
            ],
          ),
        ));
  }

  Widget loginText() {
    return const Text(
      'Log in',
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
        hintText: 'Enter Password',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _loginText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Not A Member? ',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const SignUp()));
              },
              child: const Text('Register Now'))
        ],
      ),
    );
  }
}
