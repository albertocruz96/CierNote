import 'package:ciernote/Modelo/tarefa_modelo.dart';
import 'package:ciernote/Uteis/paleta_cores.dart';
import 'package:ciernote/Widget/tarefa_widget.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import '../Consulta.dart';
import '../Uteis/banco_de_dados.dart';
import 'package:intl/intl.dart';
import '../Uteis/constantes.dart';
import '../Uteis/textos.dart';

class TelaTarefaConcluidaProgresso extends StatefulWidget {
  const TelaTarefaConcluidaProgresso({Key? key, required this.tipoExibicao})
      : super(key: key);
  final String tipoExibicao;

  @override
  State<TelaTarefaConcluidaProgresso> createState() =>
      _TelaTarefaConcluidaProgressoState();
}

class _TelaTarefaConcluidaProgressoState
    extends State<TelaTarefaConcluidaProgresso> {
  List<TarefaModelo> listaTarefas = [];
  List<TarefaModelo> listaAuxiliar = [];
  DateTime dataInicial = DateTime(2022, 07, 02);
  int quantidadeTarefas = 0;
  String nomeTela = "";
  String tipoConsulta = "";

  // referencia a classepara gerenciar o banco de dados
  final bancoDados = BancoDeDados.instance;

  @override
  void initState() {
    super.initState();
    //verificando o tipo de exibicao da tela
    if (widget.tipoExibicao.contains(Constantes.telaExibirConcluido)) {
      nomeTela = Textos.txtTelaTarefaConcluida; // definindo o nome da tela
      tipoConsulta = Constantes
          .statusEmProgresso; // passando o tipo de status que sera removido da lista ao realizar a consulta
    } else {
      nomeTela = Textos.txtTelaTarefaProgresso; // definindo o nome da tela
      tipoConsulta = Constantes
          .statusConcluido; // passando o tipo de status que sera removido da lista ao realizar a consulta
    }
    consultarTarefas(); // chamando metodo
  }

  // metodo responsavel por realizar as consultas ao banco de dados
  consultarTarefas() async {
    // chamando metodo responsavel por pegar a lista de tarefas
    await Consulta.consultarTarefasBanco(tipoConsulta).then((value) {
      setState(() {
        listaTarefas = value;
        if (listaTarefas.isNotEmpty) {
          pegarDataAntiga();
          adicionarItensListaAuxiliar();
        }
      });
    });
  }

  // metodo para adicionar itens a lista auxiliar
  adicionarItensListaAuxiliar() {
    // percorrendo a lista principal para usar nas pesquisas pelas datas
    for (var element in listaTarefas) {
      //adicionando cada elemento na lista auxiliar
      listaAuxiliar.add(element);
    }
    //pegando o tamanho  da lista
    quantidadeTarefas = listaAuxiliar.length;
  }

  pegarDataAntiga() {
    // metodo responsavel por ordenar a lista
    //da data mais antigo para a mais recente e definir valor para a variavel
    listaTarefas.sort((a, b) => DateFormat("dd/MM/yyyy", "pt_BR")
        .parse(a.data)
        .compareTo(DateFormat("dd/MM/yyyy", "pt_BR").parse(b.data)));
    //convertendo a string para data pegando o primeiro elemento da lista
    dataInicial = DateFormat("dd/MM/yyyy", "pt_BR").parse(listaTarefas[0].data);
  }

  @override
  Widget build(BuildContext context) {
    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;
    double alturaBarraStatus = MediaQuery.of(context).padding.top;
    double alturaAppBar = AppBar().preferredSize.height;

    return WillPopScope(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              title: Text(nomeTela,
                  style: const TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              backgroundColor: Colors.white,
              leading: IconButton(
                iconSize: 30,
                onPressed: () {
                  Navigator.pushNamed(context, Constantes.telaInicial);
                },
                icon: const Icon(Icons.arrow_back_outlined),
                color: Colors.black,
              )),
          body: SizedBox(
            width: larguraTela,
            height: alturaTela - alturaBarraStatus - alturaAppBar,
            child: Column(
              children: [
                Text(
                  "Total de tarefas : $quantidadeTarefas ",
                  style: const TextStyle(fontSize: 20),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  width: larguraTela,
                  child: Text(
                    Textos.txtLegendaData,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(
                    width: larguraTela,
                    child: DatePicker(
                      locale: "pt_BR",
                      onDateChange: (selectedDate) {
                        listaAuxiliar.clear(); //limpando lista
                        quantidadeTarefas = 0;
                        setState(() {
                          // pegando os elemento da lista e
                          // adicionando na lista auxiliar
                          for (var element in listaTarefas) {
                            if (DateFormat("dd/MM/yyyy", "pt_BR")
                                    .parse(element.data) ==
                                selectedDate) {
                              listaAuxiliar.add(element);
                            }
                          }
                          quantidadeTarefas = listaAuxiliar.length;
                        });
                      },
                      height: 100,
                      width: 80,
                      dataInicial,
                      initialSelectedDate: DateTime.now(),
                      selectionColor: PaletaCores.corAzulCianoClaro,
                      dateTextStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                      monthTextStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                      dayTextStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    )),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          Textos.txtLegTarefas,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 35,
                          width: 150,
                          child: ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(primary: Colors.white),
                            onPressed: () {
                              setState(() {
                                listaAuxiliar.clear(); // limpando lista
                                adicionarItensListaAuxiliar(); // chamando metodo
                              });
                            },
                            child: Text(
                              Textos.btnVerTodasTarefa,
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ]),
                ),
                SizedBox(
                    width: larguraTela,
                    height: alturaTela * 0.5,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (listaAuxiliar.isNotEmpty) {
                          return GridView.count(
                            crossAxisCount: 2,
                            children: [
                              ...listaAuxiliar
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
                                Textos.txtLegListaVaziaDataSelecionada,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 20),
                              ));
                        }
                      },
                    ))
              ],
            ),
          ),
        ),
        onWillPop: () async {
          Navigator.popAndPushNamed(context, Constantes.telaInicial);
          return true;
        });
  }
}
