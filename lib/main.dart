
import 'package:ciernote/Uteis/paleta_cores.dart';
import 'package:flutter/material.dart';
import 'Uteis/constantes.dart';
import 'Uteis/rotas.dart';
import 'Uteis/textos.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Textos.nomeApp,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'Boli', primaryColor: PaletaCores.corAzulCianoClaro),
      //definicoes usadas no date picker
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      //setando o suporte da lingua usada no data picker
      supportedLocales: const [Locale('pt', 'BR')],
      //definindo rota inicial
      initialRoute: Constantes.telaInicial,
      onGenerateRoute: Rotas.generateRoute,
    );
  }
}
