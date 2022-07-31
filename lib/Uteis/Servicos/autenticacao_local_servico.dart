import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../textos.dart';

class AutenticacaoLocalServico extends ChangeNotifier {
  final LocalAuthentication autenticacao;

  AutenticacaoLocalServico({required this.autenticacao});

  // future para verificar se o aparelho suporta leitor de
  // biometria e se existe biometria cadastrada
  Future<bool> verificarBiometriaDisponivel() async {
    final bool verificarBiometriaDisponivel =
        await autenticacao.canCheckBiometrics;
    final dispositivoSuportaBiometria = await autenticacao.isDeviceSupported();
    return verificarBiometriaDisponivel && dispositivoSuportaBiometria;
  }

  //future para exibir box de autenticacao
  Future<bool> autenticar() async {
    return await autenticacao.authenticate(
        localizedReason: Textos.txtLegAutenticacao);
  }
}
