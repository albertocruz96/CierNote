import 'dart:ui';

import 'package:ciernote/Uteis/Servicos/autenticacao_local_servico.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../Modelo/tarefa_modelo.dart';
import '../Uteis/constantes.dart';
import '../Uteis/consulta_banco_dados.dart';
import '../Uteis/paleta_cores.dart';
import '../Uteis/textos.dart';
import '../Widget/tarefa_widget.dart';

class TelaTarefasSecretas extends StatefulWidget {
  const TelaTarefasSecretas({Key? key}) : super(key: key);

  @override
  State<TelaTarefasSecretas> createState() => _TelaTarefasSecretasState();
}

class _TelaTarefasSecretasState extends State<TelaTarefasSecretas>
    with WidgetsBindingObserver {
  bool bloquearTela = true;
  bool biometriaDisponivel = false;
  List<TarefaModelo> listaTarefas = [];
  final ValueNotifier<bool> autenticacaoFalha = ValueNotifier(false);

  checarAutenticacao() async {
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

  // sobreescrevendo os estados da tela
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // qualquer estado que seja diferente de retomada fazer as instrucoes abaixo
    if (state != AppLifecycleState.resumed) {
      setState(() {
        bloquearTela = true;
      });
    } else if (state == AppLifecycleState.resumed) {
      checarAutenticacao();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    //verificando o tipo de exibicao da tela
    consultarTarefas(); // chamando metodo
    checarAutenticacao();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // metodo responsavel por realizar as consultas ao banco de dados
  consultarTarefas() async {
    // chamando metodo responsavel por pegar a lista de tarefas
    await Consulta.consultarTarefasBanco().then((value) {
      setState(() {
        //removendo elementos da lista que contenham os seguintes parametros
        value.removeWhere((element) =>
            (element.status == Constantes.statusConcluido ||
                element.status == Constantes.statusEmProgresso) &&
            element.tarefaSecreta == false);
        listaTarefas = value;
      });
    });
  }

  Widget botoes(double largura, double altura, String tituloBotao) => SizedBox(
        height: altura,
        width: largura,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            side: const BorderSide(color: PaletaCores.corAzulCianoClaro),
            primary: Colors.white,
            elevation: 5,
            shadowColor: PaletaCores.corAzulCianoClaro,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
          ),
          onPressed: () {
            if (tituloBotao == Textos.btnTentarNovamente) {
              checarAutenticacao();
            } else {
              setState(() {
                bloquearTela = false;
              });
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
    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black, size: 30),
            elevation: 0,
            backgroundColor: Colors.white,
            title: Text(
              Textos.btnNotasOcultas,
              style: const TextStyle(fontSize: 25, color: Colors.black),
            ),
            actions: [
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                width: 40,
                height: 40,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, Constantes.telaTarefaAdicao);
                  },
                  child: const Icon(
                    Icons.add,
                    size: 30,
                    color: PaletaCores.corAzulCianoClaro,
                  ),
                ),
              )
            ],
          ),
          body: Container(
              padding: const EdgeInsets.only(
                  left: 0.0, bottom: 0.0, top: 20.0, right: 0.0),
              height: alturaTela,
              width: larguraTela,
              color: Colors.white,
              child: Stack(
                children: [
                  SizedBox(
                      width: larguraTela,
                      height: alturaTela,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (listaTarefas.isNotEmpty) {
                            return GridView.count(
                              crossAxisCount: 2,
                              children: [
                                ...listaTarefas
                                    .map(
                                      (e) => TarefaWidget(
                                        item: e,
                                      ),
                                    )
                                    .toList()
                              ],
                            );
                          } else {
                            return Container(
                                width: larguraTela,
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  Textos.txtLegListaVazia,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 20),
                                ));
                          }
                        },
                      )),
                  Positioned(
                      child: Visibility(
                    visible: bloquearTela,
                    child: SizedBox(
                      height: alturaTela,
                      width: larguraTela,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                        child: Container(
                            height: alturaTela,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.0)),
                            child: ValueListenableBuilder(
                                valueListenable: autenticacaoFalha,
                                builder: (context, failed, _) {
                                  if (failed == true) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SizedBox(
                                              width: larguraTela * 0.50,
                                              child: TextFormField(
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return Textos
                                                          .erroCampoVazio;
                                                    }
                                                    return null;
                                                  },
                                                  maxLines: 1,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  decoration: InputDecoration(
                                                    hintText: Textos
                                                        .txtLiberarSenhaHint,
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              width: 1,
                                                              color:
                                                                  Colors.black),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              width: 1,
                                                              color:
                                                                  Colors.black),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              width: 2,
                                                              color:
                                                                  Colors.red),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              width: 1,
                                                              color:
                                                                  Colors.black),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  )),
                                            ),
                                            botoes(150, 50,
                                                Textos.btnLiberarAcesso)
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Visibility(
                                            visible: biometriaDisponivel,
                                            child: botoes(250, 50,
                                                Textos.btnTentarNovamente))
                                      ],
                                    );
                                  } else {
                                    return Container();
                                  }
                                })),
                      ),
                    ),
                  ))
                ],
              )),
        ),
        onWillPop: () async {
          Navigator.popAndPushNamed(context, Constantes.telaInicial);
          return true;
        });
  }
}
