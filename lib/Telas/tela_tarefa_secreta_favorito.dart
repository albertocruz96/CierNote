import 'dart:ui';
import 'package:flutter/material.dart';

import '../Modelo/tarefa_modelo.dart';
import '../Uteis/constantes.dart';
import '../Uteis/consulta_banco_dados.dart';
import '../Uteis/paleta_cores.dart';
import '../Uteis/textos.dart';
import '../Widget/tarefa_widget.dart';

class TelaTarefaSecretaFavorito extends StatefulWidget {
  const TelaTarefaSecretaFavorito({Key? key, required this.tipoExibicao})
      : super(key: key);

  final String tipoExibicao;

  @override
  State<TelaTarefaSecretaFavorito> createState() =>
      _TelaTarefaSecretaFavoritoState();
}

class _TelaTarefaSecretaFavoritoState extends State<TelaTarefaSecretaFavorito> {
  List<TarefaModelo> listaTarefas = [];
  String nomeTela = "";

  @override
  void initState() {
    super.initState();
    consultarTarefas(); // chamando metodo
    if (widget.tipoExibicao.contains(Constantes.telaExibirTarefaSecreta)) {
      nomeTela = Textos.btnTarefasSecretas;
    } else {
      nomeTela = Textos.txtTelaFavorito;
    }
  }

  // metodo responsavel por realizar as consultas ao banco de dados
  consultarTarefas() async {
    // chamando metodo responsavel por pegar a lista de tarefas
    await Consulta.consultarTarefasBanco(Constantes.nomeTabelaTarefas)
        .then((value) {
      setState(() {
        //removendo elementos da lista que contenham os seguintes parametros
        if (widget.tipoExibicao.contains(Constantes.telaExibirTarefaSecreta)) {
          // removendo todos os elementos que contem o status concluido
          // ou em progresso que contenham o campo tarefa secreta como FALSE
          value.removeWhere((element) =>
              (element.status == Constantes.statusConcluido ||
                  element.status == Constantes.statusEmProgresso) &&
              element.tarefaSecreta == false);
        }else{
          // removendo todos os elementos que contem o status concluido
          // ou em progresso que contenham o campo tarefa secreta como TRUE
          value.removeWhere((element) =>
          element.status == Constantes.statusConcluido ||
              element.status == Constantes.statusEmProgresso && (element.tarefaSecreta == true || !element.favorito));
        }
        listaTarefas = value;
      });
    });
  }

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
              nomeTela,
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
            child: SizedBox(
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
                                  comandoTelaLixeira: false,
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
          ),
        ),
        onWillPop: () async {
          Navigator.popAndPushNamed(context, Constantes.telaInicial);
          return true;
        });
  }
}
