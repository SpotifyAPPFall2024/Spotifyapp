import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotifyapp/common/helpers/dark_mode.dart';
import 'package:spotifyapp/common/widgets/button/login_button.dart';
import 'package:spotifyapp/core/configs/assets/app_vector.dart';
import 'package:spotifyapp/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:spotifyapp/presentation/welcome/page/log_in.dart';
import 'package:spotifyapp/presentation/welcome/page/sign_up.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppVectors.logo,
                height: 50,
              ),
              const SizedBox(height: 20),
              Text(
                'Millions of songs.\nFree on Spotify.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 30),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          context
                              .read<ThemeCubit>()
                              .updateTheme(ThemeMode.dark);
                        },
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 29, 185, 84)
                                      .withOpacity(0.5),
                                  shape: BoxShape.circle),
                              child: SvgPicture.asset(
                                AppVectors.moon,
                                color: context.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                fit: BoxFit.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Dark Mode',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: context.isDarkMode
                                ? Colors.white
                                : Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          context
                              .read<ThemeCubit>()
                              .updateTheme(ThemeMode.light);
                        },
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 29, 185, 84)
                                      .withOpacity(0.5),
                                  shape: BoxShape.circle),
                              child: SvgPicture.asset(
                                AppVectors.sun,
                                color: context.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                fit: BoxFit.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Light Mode',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: context.isDarkMode
                                ? Colors.white
                                : Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: 350,
                child: LoginButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => const SignUp()));
                  },
                  title: 'Sign up free',
                  textStyle: TextStyle(
                      color: context.isDarkMode ? Colors.white : Colors.black),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                width: 350,
                child: LoginButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => const LogIn()));
                  },
                  title: 'Log in',
                  textStyle: TextStyle(
                      color: context.isDarkMode ? Colors.white : Colors.black),
                  backgroundColor:
                      context.isDarkMode ? Colors.black : Colors.white,
                  borderColor: context.isDarkMode ? Colors.white : Colors.black,
                ),
              )
            ],
          )),
        ],
      ),
    );
  }
}
