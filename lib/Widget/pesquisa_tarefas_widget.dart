import 'package:flutter/material.dart';

import '../Modelo/tarefa_modelo.dart';
import '../Uteis/constantes.dart';

class PesquisaTarefasWidget extends SearchDelegate {
  List<TarefaModelo> tarefas;

  PesquisaTarefasWidget({
    required this.tarefas,
  });

  pegarItensResultado(List<TarefaModelo> listaResultado) {
    for (int i = 0; i < tarefas.length; i++) {
      if (tarefas[i].titulo.toLowerCase().contains(query.toLowerCase()) ||
          tarefas[i].data.toLowerCase().contains(query.toLowerCase()) ||
          tarefas[i].hora.toLowerCase().contains(query.toLowerCase())) {
        listaResultado.add(TarefaModelo(
            id: tarefas[i].id,
            titulo: tarefas[i].titulo,
            conteudo: tarefas[i].conteudo,
            data: tarefas[i].data,
            hora: tarefas[i].hora,
            status: tarefas[i].status,
            corTarefa: tarefas[i].corTarefa));
      }
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            close(context, null);
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    List<TarefaModelo> listaResultado = [];
    pegarItensResultado(listaResultado);
    return lista(listaResultado, context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<TarefaModelo> listaResultado = [];
    pegarItensResultado(listaResultado);
    return lista(listaResultado, context);
  }

  Widget lista(List<TarefaModelo> listaResultado, BuildContext context) =>
      SizedBox(
        height: 500,
        child: ListView(
          children: [
            DataTable(
                showCheckboxColumn: false,
                columns: const [
                  DataColumn(label: Text("Titulo")),
                  DataColumn(label: Text("Data")),
                  DataColumn(label: Text("Hora"))
                ],
                rows: listaResultado
                    .map((item) => DataRow(
                    selected: false,
                    onSelectChanged: (newValue) {
                      var dadosTela = {};
                      dadosTela[Constantes.telaParametroDetalhes] =
                          item;
                      Navigator.pushReplacementNamed(
                          context, Constantes.telaTarefaDetalhada,
                          arguments: dadosTela);
                    },
                    cells: [
                      DataCell(SizedBox(
                        height: 30,
                        width: 50,
                        child: Text(item.titulo),
                      )),
                      DataCell(SizedBox(
                        height: 30,
                        width: 100,
                        child: Text(item.data),
                      )),
                      DataCell(SizedBox(
                        height: 40,
                        width: 90,
                        child: Text(item.hora),
                      ))
                    ]))
                    .toList())
          ],
        ),
      );
}