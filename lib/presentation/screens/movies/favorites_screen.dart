import 'package:flutter/material.dart';

import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/presentation/screens/movies/widgets/home_footer.dart';

class FavoritesScreen extends StatelessWidget {
  static const name = 'favorites-screen';

  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeGradientBottom,
      bottomNavigationBar: const HomeFooter(currentIndex: 1),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.homeGradient,
        ),
        child: const SafeArea(
          bottom: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 38),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border_rounded,
                    color: AppColors.yellow,
                    size: 92,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Aun no tienes peliculas\nfavoritas chipiboy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 82),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}