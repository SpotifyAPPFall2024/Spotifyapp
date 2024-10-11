import 'package:flutter/material.dart';
import 'package:spotifyapp/common/helpers/dark_mode.dart';

class BasicAppBarS extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;

  const BasicAppBarS({
    this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: title ?? const Text(''),
      leading: const SizedBox.shrink(),
      actions: <Widget>[
        IconButton(
          onPressed: () {},
          icon: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? Colors.white.withOpacity(0.03)
                  : Colors.black.withOpacity(0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.settings,
              size: 15,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
