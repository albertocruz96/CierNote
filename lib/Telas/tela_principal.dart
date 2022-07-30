import 'package:ciernote/Uteis/consulta_banco_dados.dart';
import 'package:ciernote/Modelo/tarefa_modelo.dart';
import 'package:ciernote/Uteis/constantes.dart';
import 'package:ciernote/Uteis/notificacao_servico.dart';
import 'package:ciernote/Uteis/paleta_cores.dart';
import 'package:ciernote/Widget/listagem_tela_principal_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Uteis/textos.dart';
import 'package:intl/intl.dart';

import '../Widget/barra_pesquisa_tarefas_widget.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({Key? key}) : super(key: key);

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> with WidgetsBindingObserver{
  List<TarefaModelo> tarefas = [];
  int quantidadeTarefas = 0;
  bool exibirOpcaoCriarTarefa = true;
  String nomeUsuario = "Jhonatan";
  TimeOfDay? hora = const TimeOfDay(hour: 19, minute: 00);
  DateTime data = DateTime(2022, 07, 02);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    consultarTarefas(); // chamando metodo
    checarNotificacao();
  }

  // metodo responsavel por verificar as notificacoes
  checarNotificacao() async {
    await Provider.of<NotificacaoServico>(context, listen: false)
        .verificarNotificacoes();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.resumed){
      print("retomou");
    }else if(state == AppLifecycleState.paused){
      print("fdfsd");
    }else if(state == AppLifecycleState.inactive){
      print("aaa");
    }else if(state == AppLifecycleState.detached){
      print("carai");
    }
  }
 @override
 void dispose(){
    super.dispose();
 }

// metodo responsavel por pegar os itens
// no banco de dados e exibir ao usuario ordenando pela data
  consultarTarefas() async {
    // chamando metodo responsavel por pegar os itens no banco de dados
    await Consulta.consultarTarefasBanco()
        .then((value) {
      setState(() {

        tarefas = value;
        value.removeWhere((element) => element.status == Constantes.statusConcluido);
        //ordenando a lista pela data
        // da mais recente para a mais antiga
        tarefas.sort((a, b) => DateFormat("dd/MM/yyyy", "pt_BR")
            .parse(b.data)
            .compareTo(DateFormat("dd/MM/yyyy", "pt_BR").parse(a.data)));
        // pegando a quantidade de itens na lista
        quantidadeTarefas = tarefas.length;
      });
    });



  }

  Widget botoes(double largura, double altura, String tituloBotao, Color cor) =>
      SizedBox(
        width: largura,
        height: altura,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shadowColor: cor,
                elevation: 10,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                primary: Colors.white),
            onPressed: () {
              if (tituloBotao == Textos.btnCriarTarefa) {
                setState(() {
                  exibirOpcaoCriarTarefa = false;
                });
              } else if (tituloBotao == Textos.btnEmProgresso) {
                Navigator.pushReplacementNamed(
                    context, Constantes.telaTarefaConcluidaProgresso,
                    arguments: Constantes.telaExibirProgresso);
              } else if (tituloBotao == Textos.btnConcluido) {
                Navigator.pushReplacementNamed(
                    context, Constantes.telaTarefaConcluidaProgresso,
                    arguments: Constantes.telaExibirConcluido);
              } else if (tituloBotao == Textos.btnCriarTarefaTexto) {
                Navigator.pushReplacementNamed(
                    context, Constantes.telaTarefaAdicao);
              } else {
                setState(() {
                  exibirOpcaoCriarTarefa = true;
                });
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (tituloBotao == Textos.btnCriarTarefa) {
                      return const Icon(
                        Icons.list_alt_outlined,
                        size: 40,
                        color: Colors.black,
                      );
                    } else if (tituloBotao == Textos.btnEmProgresso) {
                      return const Icon(
                        Icons.access_time_outlined,
                        size: 40,
                        color: Colors.black,
                      );
                    } else if (tituloBotao == Textos.btnConcluido) {
                      return const Icon(
                        Icons.done,
                        size: 40,
                        color: Colors.black,
                      );
                    } else if (tituloBotao == Textos.btnCriarTarefaTexto) {
                      return const Icon(
                        Icons.text_snippet_outlined,
                        size: 40,
                        color: Colors.black,
                      );
                    } else if (tituloBotao == Textos.btnCriarTarefaLista) {
                      return const Icon(
                        Icons.list,
                        size: 40,
                        color: Colors.black,
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                Text(
                  tituloBotao,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                )
              ],
            )),
      );

  @override
  Widget build(BuildContext context) {
    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          drawerEnableOpenDragGesture: true,
          drawer: Drawer(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                ListTile(
                  title: Text(Textos.txtLegMenuLateral,
                      style: const TextStyle(fontSize: 25)),
                ),
                ListTile(
                  leading: const Icon(Icons.lock,
                      size: 25, color: PaletaCores.corAzulCianoClaro),
                  title: Text(Textos.btnNotasOcultas,
                      style: const TextStyle(fontSize: 18)),
                  onTap: () {
                    Navigator.popAndPushNamed(context, Constantes.telaTarefasSecretas);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite,
                      size: 25, color: PaletaCores.corAzulCianoClaro),
                  title: Text(Textos.btnFavoritos,
                      style: const TextStyle(fontSize: 18)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.restore_from_trash_sharp,
                      size: 25, color: PaletaCores.corAzulCianoClaro),
                  title: Text(Textos.btnLixeira,
                      style: const TextStyle(fontSize: 18)),
                  onTap: () {},
                ),
              ],
            ),
          ),
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            title: Text(Textos.nomeApp,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold)),
            elevation: 0,
            actions: [
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                width: 40,
                height: 40,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    //showSearch(context: context, delegate: Pesquisa());
                  },
                  child: const Icon(
                    Icons.account_circle,
                    size: 30,
                    color: PaletaCores.corAzulCianoClaro,
                  ),
                ),
              )
            ],
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Container(
                color: Colors.white,
                width: larguraTela,
                height: alturaTela,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Container(
                        width: larguraTela,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        child: Card(
                          elevation: 20,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          child: TextField(
                            readOnly: true,
                            onTap: () {
                              // chamando metodo resposavel por exibir a barra de pesquisa personalizada
                              showSearch(
                                  context: context,
                                  delegate:
                                      PesquisaTarefasWidget(tarefas: tarefas));
                            },
                            decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  size: 30,
                                  color: PaletaCores.corAzulCianoClaro,
                                ),
                                prefixIconColor: PaletaCores.corCinzaClaro,
                                hintText: Textos.txtLegBarraBusca,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                hoverColor: PaletaCores.corCinzaClaro,
                                focusColor: PaletaCores.corCinzaClaro),
                          ),
                        ),
                      ),
                      SizedBox(
                          width: larguraTela,
                          height: 300,
                          child: Column(
                            children: [
                              SizedBox(
                                width: larguraTela,
                                height: 70,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${Textos.txtBoasVindas} $nomeUsuario",
                                      style: const TextStyle(
                                          color: PaletaCores.corCinzaMenosClaro,
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "Você tem $quantidadeTarefas tarefas a serem realizadas",
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              SizedBox(
                                height: 215,
                                width: larguraTela,
                                child: AnimatedCrossFade(
                                    firstChild: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        botoes(120, 140, Textos.btnCriarTarefa,
                                            PaletaCores.corVermelho),
                                        botoes(120, 140, Textos.btnEmProgresso,
                                            PaletaCores.corAmarela),
                                        botoes(120, 140, Textos.btnConcluido,
                                            PaletaCores.corVerde),
                                      ],
                                    ),
                                    secondChild: SizedBox(
                                      height: 200,
                                      child: Card(
                                        margin: const EdgeInsets.all(10),
                                        elevation: 10,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(Textos.btnCriarTarefa,
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                //btn criar em texto
                                                botoes(
                                                    120,
                                                    120,
                                                    Textos.btnCriarTarefaTexto,
                                                    PaletaCores
                                                        .corAzulCianoClaro),
                                                //btn fechar janela
                                                botoes(
                                                    90,
                                                    30,
                                                    Textos.btnFecharJanela,
                                                    PaletaCores.corVermelho),
                                                //btn criar em lista
                                                botoes(
                                                    120,
                                                    120,
                                                    Textos.btnCriarTarefaLista,
                                                    PaletaCores
                                                        .corAzulCianoClaro),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    crossFadeState: exibirOpcaoCriarTarefa
                                        ? CrossFadeState.showFirst
                                        : CrossFadeState.showSecond,
                                    duration:
                                        const Duration(milliseconds: 1000)),
                              )
                            ],
                          )),
                    ],
                  ),
                )),
          ),
          bottomNavigationBar: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: ListagemTelaPrincipalWidget(tarefas: tarefas))),
    );
  }
}
