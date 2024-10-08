import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotifyapp/common/widgets/appbar/app_bar.dart';
import 'package:spotifyapp/common/widgets/button/login_button.dart';
import 'package:spotifyapp/presentation/home/page/home_page.dart';
import 'package:spotifyapp/presentation/welcome/page/log_in.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/configs/assets/app_vector.dart';
import '../../../core/utils/authentication_service.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});
  @override
  signUpState createState() => signUpState();
}

class signUpState extends State<SignUp> {
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
                onPressed: handleLogin,
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

  Future<void> handleLogin() async {
    final authService = AuthenticationService();
    final authURL = await authService.getAuthorizationUrl();
    await launchUrl(authURL);
    await Future.delayed(Duration(minutes: 5));

    final code = await _handleLink();
    if (code != null) {
      try {
        final accessToken = code;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                HomePage(accessToken: accessToken),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authorization code missing')),
      );
    }
  }

  Future<String?> _handleLink() async {
    final AppLinks _appLinks = AppLinks();
    String? authorizationCode;

    _appLinks.uriLinkStream.listen((Uri? link) {
      if (link != null) {
        if (link.queryParameters.containsKey('code')) {
          authorizationCode = link.queryParameters['code'];
        }
      }
    });

    final Uri? initialLink = await _appLinks.getInitialLink();
    if (initialLink != null &&
        initialLink.queryParameters.containsKey('code')) {
      authorizationCode = initialLink.queryParameters['code'];
    }

    return authorizationCode;
  }
}
