import 'package:ciernote/Modelo/notificacao.dart';
import 'package:ciernote/Uteis/consulta_banco_dados.dart';
import 'package:ciernote/Modelo/tarefa_modelo.dart';
import 'package:ciernote/Uteis/constantes.dart';
import 'package:ciernote/Uteis/notificacao_servico.dart';
import 'package:ciernote/Uteis/paleta_cores.dart';
import 'package:ciernote/Widget/listagem_principal_tarefa_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Uteis/textos.dart';
import 'package:intl/intl.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({Key? key}) : super(key: key);

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  List<TarefaModelo> tarefas = [];
  int quantidadeTarefas = 0;
  bool mudarVisualizacao = false;
  String nomeBotaoMudarVisualizacao = Textos.btnVerGrade;
  final TextEditingController _controllerPesquisa =
      TextEditingController(text: "");

  TimeOfDay? hora = const TimeOfDay(hour: 19, minute: 00);
  DateTime data = DateTime(2022, 07, 02);

  @override
  void initState() {
    super.initState();
    consultarTarefas(); // chamando metodo
    checarNotificacao();
  }

  checarNotificacao() async {
    await Provider.of<NotificacaoServico>(context, listen: false)
        .verificarNotificacoes();
  }

  realizarPesquisa(String pesquisa, List<TarefaModelo> tarefa) {
    tarefa.where((element) => pesquisa.contains(element.titulo));

    for (var element in tarefa) {
      if (pesquisa.contains(element.titulo)) {
        //print("Resultado: " + element.titulo);
      }
    }
  }

// metodo responsavel por pegar os itens
// no banco de dados e exibir ao usuario ordenando pela data
  consultarTarefas() async {
    // chamando metodo responsavel por pegar os itens no banco de dados
    await Consulta.consultarTarefasBanco(Constantes.statusConcluido)
        .then((value) {
      setState(() {
        tarefas = value;
        //ordenando a lista pela data
        // mais recente para a mais antiga
        tarefas.sort((a, b) => DateFormat("dd/MM/yyyy", "pt_BR")
            .parse(b.data)
            .compareTo(DateFormat("dd/MM/yyyy", "pt_BR").parse(a.data)));
        // pegando a quantidade de itens na lista
        quantidadeTarefas = tarefas.length;
      });
    });
  }

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
                  height: 10,
                ),
                ListTile(
                  title: Text(Textos.txtLegMenuLateral,
                      style: const TextStyle(fontSize: 20)),
                ),
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.black),
                  title: Text(Textos.btnNotasOcultas),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.restore_from_trash_sharp,
                      color: Colors.black),
                  title: Text(Textos.btnLixeira),
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
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        child: Card(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: TextField(
                            controller: _controllerPesquisa,
                            onTap: () {
                              //mudando estado da variavel quando o usuario apertar dentro da barra de pesquisa
                              setState(() {
                                mudarVisualizacao = false;
                                nomeBotaoMudarVisualizacao = Textos.btnVerGrade;
                              });
                            },
                            decoration: InputDecoration(
                                prefixIcon:
                                    const Icon(Icons.search_rounded, size: 30),
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
                          child: Stack(
                            children: [
                              Positioned(
                                child: SizedBox(
                                  width: larguraTela,
                                  height: 100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        Textos.txtBoasVindas,
                                        style: const TextStyle(
                                            color: PaletaCores.corCinzaClaro,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        "Você tem $quantidadeTarefas tarefas a serem realizadas",
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(
                                      width: 110,
                                      height: 110,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  30))),
                                              primary: Colors.redAccent),
                                          onPressed: () {
                                            Navigator.pushReplacementNamed(
                                                context,
                                                Constantes.telaTarefaAdicao);
                                          },
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.list_alt,
                                                  size: 30),
                                              Text(
                                                Textos.btnCriarTarefa,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          )),
                                    ),
                                    SizedBox(
                                      width: 110,
                                      height: 110,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  30))),
                                              primary: PaletaCores.corAmarela),
                                          onPressed: () {
                                            Navigator.pushReplacementNamed(
                                                context,
                                                Constantes
                                                    .telaTarefaConcluidaProgresso,
                                                arguments: Constantes
                                                    .telaExibirProgresso);
                                          },
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.timer_outlined,
                                                  size: 30),
                                              Text(
                                                Textos.btnEmProgresso,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          )),
                                    ),
                                    SizedBox(
                                      width: 110,
                                      height: 110,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  30))),
                                              primary: Colors.green),
                                          onPressed: () {
                                            Navigator.pushReplacementNamed(
                                                context,
                                                Constantes
                                                    .telaTarefaConcluidaProgresso,
                                                arguments: Constantes
                                                    .telaExibirConcluido);
                                          },
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.done_outline,
                                                  size: 30),
                                              Text(
                                                Textos.btnConcluido,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          )),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )),
                    ],
                  ),
                )),
          ),
          bottomSheet: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: ListagemTarefasWidget(tarefas: tarefas))),
    );
  }
}


