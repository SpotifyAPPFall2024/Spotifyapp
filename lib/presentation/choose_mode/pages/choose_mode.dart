// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// import '../../../common/widgets/appbar/app_bar.dart';
// import '../../../common/widgets/button/login_button.dart';
// import '../../../core/configs/assets/app_image.dart';
// import '../../../core/configs/assets/app_vector.dart';
// import '../../welcome/page/sign_up.dart';
// import '../bloc/theme_cubit.dart';

// class ChooseMode extends StatelessWidget {
//   const ChooseMode({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//               decoration: const BoxDecoration(
//                   image: DecorationImage(
//                       fit: BoxFit.fill,
//                       image: AssetImage(
//                         AppImage.welcomeBG,
//                       ))),
//               child: Center(
//                   child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SvgPicture.asset(
//                     AppVectors.logo,
//                     height: 50,
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Millions of songs.\nFree on Spotify.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         fontSize: 30),
//                   ),
//                   const SizedBox(
//                     height: 30,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Column(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               context
//                                   .read<ThemeCubit>()
//                                   .updateTheme(ThemeMode.dark);
//                             },
//                             child: ClipOval(
//                               child: BackdropFilter(
//                                 filter:
//                                     ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                                 child: Container(
//                                   height: 50,
//                                   width: 50,
//                                   decoration: BoxDecoration(
//                                       color:
//                                           const Color.fromARGB(255, 29, 185, 84)
//                                               .withOpacity(0.5),
//                                       shape: BoxShape.circle),
//                                   child: SvgPicture.asset(
//                                     AppVectors.moon,
//                                     fit: BoxFit.none,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           const Text(
//                             'Dark Mode',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 13,
//                                 color: Colors.white),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(
//                         width: 30,
//                       ),
//                       Column(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               context
//                                   .read<ThemeCubit>()
//                                   .updateTheme(ThemeMode.light);
//                             },
//                             child: ClipOval(
//                               child: BackdropFilter(
//                                 filter:
//                                     ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                                 child: Container(
//                                   height: 50,
//                                   width: 50,
//                                   decoration: BoxDecoration(
//                                       color:
//                                           const Color.fromARGB(255, 29, 185, 84)
//                                               .withOpacity(0.5),
//                                       shape: BoxShape.circle),
//                                   child: SvgPicture.asset(
//                                     AppVectors.sun,
//                                     fit: BoxFit.none,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           const Text(
//                             'Light Mode',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 13,
//                                 color: Colors.white),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 30,
//                   ),
//                   SizedBox(
//                     width: 350,
//                     child: LoginButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (BuildContext context) =>
//                                     const SignUp()));
//                       },
//                       title: 'Sign up free',
//                       textStyle: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 5,
//                   ),
//                   SizedBox(
//                     width: 350,
//                     child: LoginButton(
//                       onPressed: () {},
//                       title: 'Log in',
//                       textStyle: const TextStyle(color: Colors.white),
//                       backgroundColor: Colors.black,
//                       borderColor: Colors.white,
//                     ),
//                   )
//                 ],
//               ))),
//         ],
//       ),
//     );
//   }
// }
