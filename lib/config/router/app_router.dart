// importamos go router, sirve para manejar la navegacion de la app
import 'package:go_router/go_router.dart';
import 'package:chipileta_movies_app/config/router/presentation/screens/movies/home_screen.dart';

//Usar GoRouter nos ayuda a que nosostros no tengamos que hacer configuraciones especiales si lo queremos usar en la web.
//Creamos la configuracion global del router
//Define como navegamos entre pantallas
final appRouter = GoRouter
(
  //Panatlla inicial de la app
  initialLocation : '/',

  //Lista de rutas disponibles en nuestra app
  routes: [
    // Define tus rutas aquí

    GoRoute
    (
      //URL de la ruta
      path: '/',
      //Nombre de la ruta (util para la navegacion por nombre)
      name: HomeScreen.name,
      //Es el buider que se mostrara cuando entremos en nuestra pantalla.
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);