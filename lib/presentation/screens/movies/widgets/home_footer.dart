import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:chipileta_movies_app/resources/colors/colors.dart';

class HomeFooter extends StatelessWidget {
  final int currentIndex;

  const HomeFooter({
    super.key,
    required this.currentIndex,
  });

  void _goToPage(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/favorites');
        break;
      case 2:
        context.go('/downloads');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.footerBackground,
      elevation: 14,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 82,
          child: Row(
            children: [
              _FooterItem(
                icon: Icons.home_outlined,
                selected: currentIndex == 0,
                onTap: () => _goToPage(context, 0),
              ),
              _FooterItem(
                icon: Icons.star_border_rounded,
                selected: currentIndex == 1,
                onTap: () => _goToPage(context, 1),
              ),
              _FooterItem(
                icon: Icons.file_download_outlined,
                boxedIcon: true,
                selected: currentIndex == 2,
                onTap: () => _goToPage(context, 2),
              ),
              _FooterItem(
                icon: Icons.person_outline_rounded,
                selected: currentIndex == 3,
                onTap: () => _goToPage(context, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final bool boxedIcon;
  final VoidCallback onTap;

  const _FooterItem({
    required this.icon,
    required this.selected,
    required this.onTap,
    this.boxedIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.footerActive : AppColors.footerInactive;

    final Widget iconWidget = boxedIcon
        ? Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              border: Border.all(
                color: color,
                width: 2.2,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: color,
              size: 27,
            ),
          )
        : Icon(
            icon,
            color: color,
            size: 36,
          );

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 40,
              child: Center(child: iconWidget),
            ),
            const SizedBox(height: 7),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 42 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.footerActive,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}