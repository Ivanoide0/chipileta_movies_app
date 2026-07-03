import 'package:flutter/material.dart';

import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/presentation/screens/movies/widgets/home_footer.dart';

class DownloadsScreen extends StatelessWidget {
  static const name = 'downloads-screen';

  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeGradientBottom,
      bottomNavigationBar: const HomeFooter(currentIndex: 2),
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
                    Icons.file_download_outlined,
                    color: AppColors.yellow,
                    size: 92,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Aun no guardas nada chipiboy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Gruñeme',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
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