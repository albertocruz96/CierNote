import 'dart:ui';

import 'package:ciernote/Modelo/tarefa_modelo.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../Uteis/Servicos/autenticacao_local_servico.dart';
import '../Uteis/banco_de_dados.dart';
import '../Uteis/constantes.dart';
import '../Uteis/paleta_cores.dart';
import '../Uteis/textos.dart';

class BloquearTelaWidget extends StatefulWidget {
  const BloquearTelaWidget({Key? key, required this.item}) : super(key: key);

  final TarefaModelo item;

  @override
  State<BloquearTelaWidget> createState() => _BloquearTelaWidgetState();
}

class _BloquearTelaWidgetState extends State<BloquearTelaWidget>
    with WidgetsBindingObserver {
  bool bloquearTela = true;
  bool biometriaDisponivel = false;
  final ValueNotifier<bool> autenticacaoFalha = ValueNotifier(false);
  bool autenticacao = false;

  // referencia classe para gerenciar o banco de dados
  final bancoDados = BancoDeDados.instance;
  TextEditingController controllerSenha = TextEditingController(text: "");
  String senhaUsuario = "";

  // metodo para verificar identidade usando a biometria
  autenticarBiometria() async {
    final autenticacao =
        AutenticacaoLocalServico(autenticacao: LocalAuthentication());
    final verificarDisponibilidadeBiometria =
        await autenticacao.verificarBiometriaDisponivel();
    autenticacaoFalha.value = false;

    //verificando se o dispositivo tem biometria
    if (verificarDisponibilidadeBiometria) {
      biometriaDisponivel = true;
      final autenticar = await autenticacao.autenticar();
      //caso a autenticacao falhe mudar valor da variavel
      if (!autenticar) {
        autenticacaoFalha.value = true;
      } else {
        setState(() {
          bloquearTela = false;
        });
      }
    } else {
      // em caso de biometria indisponivel mudar valor das variaveis
      autenticacaoFalha.value = true;
      biometriaDisponivel = false;
    }
  }

  consultarUsuario() async {
    final registros =
        await bancoDados.consultarLinhas(Constantes.nomeTabelaUsuario);
    if (registros.isNotEmpty) {
      for (var linha in registros) {
        setState(() {
          senhaUsuario = linha[Constantes.bancoSenha];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // verificando se a tarefa e um tarefa secreta para exibir autenticacao
    consultarUsuario();
    if (widget.item.tarefaSecreta) {
      autenticarBiometria();
    } else {
      setState(() {
        bloquearTela = false;
      });
    }
  }

  // sobreescrevendo os estados da tela
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (widget.item.tarefaSecreta) {
      // qualquer estado que seja diferente de retomada
      // fazer as instrucoes abaixo
      if (state != AppLifecycleState.resumed) {
        setState(() {
          bloquearTela = true;
        });
      } else if (state == AppLifecycleState.resumed) {
        autenticarBiometria();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // widget dos botoes apresentados na tela
  Widget botoes(double largura, double altura, String tituloBotao, Color cor) =>
      SizedBox(
        height: altura,
        width: largura,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            side: BorderSide(color: cor),
            primary: Colors.white,
            elevation: 5,
            shadowColor: cor,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
          ),
          onPressed: () {
            if (tituloBotao == Textos.btnTentarNovamente) {
              autenticarBiometria(); // chamando metodo
            } else {
              if (controllerSenha.text == senhaUsuario) {
                setState(() {
                  bloquearTela = false;
                });
              }else{
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(Textos.erroSenhaIncorreta)));
              }
            }
          },
          child: Text(
            tituloBotao,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    double larguraTela = MediaQuery.of(context).size.width;
    return Visibility(
      visible: bloquearTela,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: Center(
            child: ValueListenableBuilder(
                valueListenable: autenticacaoFalha,
                builder: (context, failed, _) {
                  if (failed == true) {
                    return SizedBox(
                      height: 250,
                      width: larguraTela,
                      child: Card(
                        elevation: 10,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10),
                              child: Text(
                                Textos.txtLegLiberarAcesso,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: larguraTela * 0.50,
                                  height: 50,
                                  child: TextFormField(
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return Textos.erroCampoVazio;
                                        }
                                        return null;
                                      },
                                      maxLines: 1,
                                      controller: controllerSenha,
                                      obscureText: true,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        label: Text(Textos.txtLiberarSenhaHint),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              width: 1, color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              width: 1, color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              width: 2, color: Colors.red),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              width: 1, color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      )),
                                ),
                                botoes(150, 50, Textos.btnLiberarAcesso,
                                    PaletaCores.corAzulCianoClaro)
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Visibility(
                                visible: biometriaDisponivel,
                                child: botoes(
                                    250,
                                    50,
                                    Textos.btnTentarNovamente,
                                    PaletaCores.corAzulCianoClaro))
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                })),
      ),
    );
  }
}
