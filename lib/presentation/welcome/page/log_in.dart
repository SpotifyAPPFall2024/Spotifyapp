import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotifyapp/common/widgets/appbar/app_bar.dart';
import 'package:spotifyapp/common/widgets/button/login_button.dart';
import 'package:spotifyapp/core/utils/authentication_service.dart';
import 'package:spotifyapp/presentation/home/page/home_page.dart';
import 'package:spotifyapp/presentation/welcome/page/sign_up.dart';
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/configs/assets/app_vector.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  logInState createState() => logInState();
}

class logInState extends State<LogIn> {
  final TextEditingController emailControll = TextEditingController();
  final TextEditingController passwordControll = TextEditingController();
  //bool isLoading = false;

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
              onPressed: handleLogin,
              title: 'Sign in',
              height: 80,
            ),
          ],
        ),
      ),
    );
  }

  Widget loginText() {
    return const Text(
      'Sign in',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget emailAddress(BuildContext context) {
    return TextField(
      controller: emailControll,
      decoration: const InputDecoration(
        hintText: ' Enter Email Address',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget password(BuildContext context) {
    return TextField(
      controller: passwordControll,
      decoration: const InputDecoration(
        hintText: 'Enter Password',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      obscureText: true,
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

  Future<void> handleLogin() async {
    final authService = AuthenticationService();
    final authURL = await authService.getAuthorizationUrl();
    await launchUrl(authURL);
    await Future.delayed(Duration(minutes: 5));

    final code = await _handleLink();
    if(code != null){
      try{
        final accessToken = code;//await authService.exchangeCodeForToken(code);
        if(accessToken!=null){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => HomePage(accessToken: accessToken),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('login failed')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Error: $e')),
        );
      }
    } else{
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

    // Wait for the initial link
    final Uri? initialLink = await _appLinks.getInitialLink();
    if (initialLink != null && initialLink.queryParameters.containsKey('code')) {
      authorizationCode = initialLink.queryParameters['code'];
    }

    // Return the authorization code
    return authorizationCode;
  }

  String? _extractCodeFromUri(Uri uri) {
    final code = uri.queryParameters['code'];
    return code;
  }

}
