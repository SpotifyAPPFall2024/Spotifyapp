import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double? height;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? borderColor;

  const LoginButton(
      {required this.onPressed,
      required this.title,
      this.height,
      this.textStyle,
      this.backgroundColor,
      this.borderColor,
      super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          minimumSize: Size.fromHeight(height ?? 40),
          side: BorderSide(
            color: borderColor ?? Theme.of(context).primaryColor,
            width: 2,
          )),
      child: Text(
        title,
        style: textStyle ??
            TextStyle(
              color: borderColor ?? Colors.white,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
