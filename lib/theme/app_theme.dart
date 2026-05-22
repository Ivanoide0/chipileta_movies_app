import 'package:flutter/material.dart';

class AppTheme {
  //ThemeData es una clase que represeta toda la configuracion visual de la aplicacion, como colores, tipografia, etc.
  //getTheme es un metodo que devuelve un objeto de tipo ThemeData, para estilizar toda la app.
  ThemeData getTheme() => ThemeData(

    useMaterial3: true,
    colorSchemeSeed: const Color(0xff2862F5),

  );
}