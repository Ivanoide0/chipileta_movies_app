import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';

enum ErrorViewType { notFound, noConnection, general }

class ErrorView extends StatelessWidget {
  static const name = 'error-view';
  final ErrorViewType type;
  final String returnRoute;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.type,
    this.returnRoute = '/home',
    this.onRetry
  });

  //404
  const ErrorView.notFound({
    super.key,
    this.returnRoute = '/home'
  }) : type = ErrorViewType.notFound, onRetry = null;

  //500
  const ErrorView.noConnection({
    super.key,
    this.returnRoute = '/home',
    this.onRetry
  }) : type = ErrorViewType.noConnection;

  //General
  const ErrorView.general({
    super.key,
    this.returnRoute = '/home'
  }) : type = ErrorViewType.general, onRetry = null;

  IconData get _icon {
    switch(type){
      case ErrorViewType.notFound:
        return Icons.travel_explore_rounded;
      case ErrorViewType.noConnection:
        return Icons.wifi_off_rounded;
      case ErrorViewType.general:
        return Icons.error_outline_rounded;
    }
  }

  String get _code {
    switch(type){
      case ErrorViewType.notFound:
        return '404';
      case ErrorViewType.noConnection:
        return '500';
      case ErrorViewType.general:
        return 'Ups';
    }
  }

  String get _title {
    switch(type){
      case ErrorViewType.notFound:
        return 'Página no encontrada';
      case ErrorViewType.noConnection:
        return 'Sin conexión';
      case ErrorViewType.general:
        return 'Algo salió mal';
    }
  }

  String get _message {
    switch(type){
      case ErrorViewType.notFound:
        return 'La página que buscas no existe o se movió.'
          'Revisa la dirección o vuelve al inicio';
      case ErrorViewType.noConnection:
        return 'No pudimos conectar con el servidor.'
          'Verifica tu conexión a internet e intenta de nuevo.';
      case ErrorViewType.general:
        return 'Ocurrió un error inesperado.'
          'Intenta de nuevo en unos momentos.';
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppColors.homeGradientBottom,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.homeGradient
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.turquoise.withValues(alpha: 0.12),
                      shape: BoxShape.circle
                    ),
                    child: Icon(
                      _icon,
                      size: 60,
                      color: AppColors.turquoise,
                    ),
                  ),
                  const SizedBox(height: 24),
                  //Codigo del error
                  Text(
                    _code,
                    style: const TextStyle(
                      color: AppColors.yellow,
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    _title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white70,
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  const SizedBox(height: 32),

                  //Botón
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onRetry ?? () => context.go(returnRoute),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.yellow,
                        foregroundColor: AppColors.backgroundDark,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)
                        ),
                        elevation: 0
                      ),
                      child: Text(
                        onRetry != null ? 'Reintentar':'Volver al inicio',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}