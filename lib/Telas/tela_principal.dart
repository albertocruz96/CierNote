import 'package:ciernote/Uteis/consulta_banco_dados.dart';
import 'package:ciernote/Modelo/tarefa_modelo.dart';
import 'package:ciernote/Uteis/constantes.dart';
import 'package:ciernote/Uteis/paleta_cores.dart';
import 'package:ciernote/Widget/listagem_tela_principal_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Uteis/Servicos/notificacao_servico.dart';
import '../Uteis/textos.dart';
import 'package:intl/intl.dart';

import '../Widget/barra_pesquisa_tarefas_widget.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({Key? key}) : super(key: key);

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  List<TarefaModelo> tarefas = [];
  int quantidadeTarefas = 0;
  String nomeUsuario = "Jhonatan";
  TimeOfDay? hora = const TimeOfDay(hour: 19, minute: 00);
  DateTime data = DateTime(2022, 07, 02);

  @override
  void initState() {
    super.initState();
    consultarTarefas(); // chamando metodo
    checarNotificacao();
  }

  // metodo responsavel por verificar as notificacoes
  checarNotificacao() async {
    await Provider.of<NotificacaoServico>(context, listen: false)
        .verificarNotificacoes();
  }

// metodo responsavel por pegar os itens
// no banco de dados e exibir ao usuario ordenando pela data
  consultarTarefas() async {
    // chamando metodo responsavel por pegar os itens no banco de dados
    await Consulta.consultarTarefasBanco(Constantes.nomeTabelaTarefas).then((value) {
      setState(() {
        tarefas = value;
        // removendo itens da lista que corresponde aos criterios passados
        value.removeWhere((element) =>
            element.status == Constantes.statusConcluido ||
            element.tarefaSecreta == true);
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

  // widget dos botoes utilizados em tela
  Widget botoes(double largura, double altura, String tituloBotao, Color cor) =>
      SizedBox(
        width: largura,
        height: altura,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                side: BorderSide(color: cor),
                shadowColor: cor,
                elevation: 10,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                primary: Colors.white),
            onPressed: () {
              // verificando se o nome do botao corresponde ao parametro passado
              if (tituloBotao == Textos.btnCriarTarefa) {
                Navigator.pushReplacementNamed(
                    context, Constantes.telaTarefaAdicao);
              } else if (tituloBotao == Textos.btnEmProgresso) {
                Navigator.pushReplacementNamed(
                    context, Constantes.telaTarefaConcluidaProgresso,
                    arguments: Constantes.telaExibirProgresso);
              } else {
                Navigator.pushReplacementNamed(
                    context, Constantes.telaTarefaConcluidaProgresso,
                    arguments: Constantes.telaExibirConcluido);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    // verificando o nome do botao para exibir icone correspondente
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
                    Navigator.popAndPushNamed(
                        context, Constantes.telaTarefasSecretas);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite,
                      size: 25, color: PaletaCores.corAzulCianoClaro),
                  title: Text(Textos.btnFavoritos,
                      style: const TextStyle(fontSize: 18)),
                  onTap: () {

                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restore_from_trash_sharp,
                      size: 25, color: PaletaCores.corAzulCianoClaro),
                  title: Text(Textos.btnLixeira,
                      style: const TextStyle(fontSize: 18)),
                  onTap: () {
                    Navigator.popAndPushNamed(
                        context, Constantes.telaLixeira);
                  },
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
                  onPressed: () {},
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
                        margin: const EdgeInsets.only(
                            right: 10.0, top: 0.0, bottom: 10.0, left: 10.0),
                        child: Card(
                          elevation: 10,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          child: TextField(
                            readOnly: true,
                            onTap: () {
                              // chamando metodo resposavel por exibir
                              // a barra de pesquisa personalizada
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
                                child: Row(
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
