import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:flutter/material.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.only(top: 10, bottom: 12),
      decoration: const BoxDecoration(
        color: AppColors.gradientBottom,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _FooterItem(
            icon: Icons.home_outlined,
            selected: true,
          ),
          _FooterItem(
            icon: Icons.star_border_rounded,
          ),
          _FooterItem(
            icon: Icons.file_download_outlined,
          ),
          _FooterItem(
            icon: Icons.person_outline_rounded,
          ),
        ],
      ),
    );
  }
}

class _FooterItem extends StatelessWidget {
  final IconData icon;
  final bool selected;

  const _FooterItem({
    required this.icon,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: selected ? AppColors.yellow : AppColors.white70,
            size: 30,
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: selected ? 30 : 0,
            decoration: BoxDecoration(
              color: AppColors.yellow,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}