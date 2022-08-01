import 'package:ciernote/Uteis/textos.dart';
import 'package:flutter/material.dart';

import '../Modelo/tarefa_modelo.dart';
import '../Uteis/constantes.dart';
import '../Uteis/consulta_banco_dados.dart';
import '../Widget/tarefa_widget.dart';

class TelaLixeira extends StatefulWidget {
  const TelaLixeira({Key? key}) : super(key: key);

  @override
  State<TelaLixeira> createState() => _TelaLixeiraState();
}


class _TelaLixeiraState extends State<TelaLixeira> {
  List<TarefaModelo> tarefasExcluidas = [];

  @override
  void initState() {
    super.initState();
    consultarTarefasExcluidas();
  }

  // metodo responsavel por realizar as consultas ao banco de dados
  consultarTarefasExcluidas() async {
    // chamando metodo responsavel por pegar a lista de tarefas
    await Consulta.consultarTarefasBanco(Constantes.nomeTabelaLixeira).then((
        value) {
      setState(() {
        tarefasExcluidas = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double alturaTela = MediaQuery
        .of(context)
        .size
        .height;
    double larguraTela = MediaQuery
        .of(context)
        .size
        .width;
    return WillPopScope(
      onWillPop: () async {
       Navigator.popAndPushNamed(context, Constantes.telaInicial);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black,size: 30),
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            Textos.txtTelaLixeira,
            style: const TextStyle(
                color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          width: larguraTela,
          height: alturaTela,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                  width: larguraTela,
                  height: alturaTela * 0.8,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (tarefasExcluidas.isNotEmpty) {
                        return GridView.count(
                          crossAxisCount: 2,
                          children: [
                            ...tarefasExcluidas
                                .map(
                                  (e) =>
                                  TarefaWidget(
                                    item: e,
                                    comandoTelaLixeira: true,
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
            ],
          ),
        ),
      )
      ,
    );
  }
}
