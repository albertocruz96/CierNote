import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../textos.dart';

class AutenticacaoLocalServico extends ChangeNotifier {
  final LocalAuthentication autenticacao;

  AutenticacaoLocalServico({required this.autenticacao});

  Future<bool> verificarBiometriaDisponivel() async {
    final bool canAuthenticateWithBiometrics =
        await autenticacao.canCheckBiometrics;
    return canAuthenticateWithBiometrics ||
        await autenticacao.isDeviceSupported();
  }

  Future<bool> autenticar() async {
    return await autenticacao.authenticate(localizedReason: Textos.txtLegAutenticacao);
  }
}
