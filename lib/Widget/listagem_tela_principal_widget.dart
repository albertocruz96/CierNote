import 'package:ciernote/Widget/tarefa_widget.dart';
import 'package:flutter/material.dart';

import '../Modelo/tarefa_modelo.dart';
import '../Uteis/paleta_cores.dart';
import '../Uteis/textos.dart';

class ListagemTelaPrincipalWidget extends StatefulWidget {
  const ListagemTelaPrincipalWidget({Key? key, required this.tarefas})
      : super(key: key);

  final List<TarefaModelo> tarefas;

  @override
  State<ListagemTelaPrincipalWidget> createState() =>
      _ListagemTelaPrincipalWidgetState();
}

class _ListagemTelaPrincipalWidgetState
    extends State<ListagemTelaPrincipalWidget> {
  bool mudarVisualizacao = false;
  String nomeBotaoMudarVisualizacao = Textos.btnVerGrade;

  @override
  Widget build(BuildContext context) {
    double larguraTela = MediaQuery.of(context).size.width;
    return AnimatedContainer(
      curve: Curves.easeInOutBack,
      duration: const Duration(seconds: 2),
      height: mudarVisualizacao == true ? 400 : 270,
      width: larguraTela,
      child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 1.0),
                  width: larguraTela,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Textos.txtLegTarefas,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 30,
                        width: 150,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: const BorderSide(
                                color: PaletaCores.corAzulCianoClaro),
                            primary: Colors.white,
                            elevation: 5,
                            shadowColor: PaletaCores.corAzulCianoClaro,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                          ),
                          onPressed: () {
                            setState(() {
                              if (!mudarVisualizacao) {
                                mudarVisualizacao = true;
                                nomeBotaoMudarVisualizacao =
                                    Textos.btnVerLista;
                              } else {
                                nomeBotaoMudarVisualizacao =
                                    Textos.btnVerGrade;
                                mudarVisualizacao = false;
                              }
                            });
                          },
                          child: Text(
                            nomeBotaoMudarVisualizacao,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                    width: larguraTela,
                    height: mudarVisualizacao == true ? 360 : 220,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (widget.tarefas.isEmpty) {
                          return SizedBox(
                              width: larguraTela,
                              child: Center(
                                child: Text(Textos.txtLegListaVazia,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 20)),
                              ));
                        } else if (mudarVisualizacao) {
                          return GridView(
                            scrollDirection: Axis.vertical,
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            children: [
                              ...widget.tarefas
                                  .map(
                                    (e) => TarefaWidget(
                                  item: e,
                                  comandoTelaLixeira: false,
                                ),
                              )
                                  .toList()
                            ],
                          );
                        } else {
                          return ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ...widget.tarefas
                                  .map((e) => TarefaWidget(
                                item: e,
                                comandoTelaLixeira: false,
                              ))
                                  .toList()
                            ],
                          );
                        }
                      },
                    )),
              ],
            ),
          ),),
    );
  }
}
