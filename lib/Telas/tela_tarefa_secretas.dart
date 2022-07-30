import 'package:flutter/material.dart';

import '../Uteis/constantes.dart';
import '../Uteis/textos.dart';

class TelaTarefasSecretas extends StatefulWidget {
  const TelaTarefasSecretas({Key? key}) : super(key: key);

  @override
  State<TelaTarefasSecretas> createState() => _TelaTarefasSecretasState();
}

class _TelaTarefasSecretasState extends State<TelaTarefasSecretas> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      appBar: AppBar(
        title: Text(Textos.btnNotasOcultas),
      ),
    ),  onWillPop: () async {
      Navigator.popAndPushNamed(context, Constantes.telaInicial);
      return true;
    });
  }
}
