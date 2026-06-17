import 'package:chipileta_movies_app/config/router/app_router.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Chipileta Movies',
      theme: AppTheme().getTheme(),
      routerConfig: appRouter,
      builder: (context, child) {
        return ColoredBox(
          color: AppColors.backgroundDark,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}