import 'package:ciernote/Modelo/tarefa_modelo.dart';
import 'package:ciernote/Uteis/paleta_cores.dart';
import 'package:ciernote/Widget/tarefa_widget.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import '../Uteis/banco_de_dados.dart';
import 'package:intl/intl.dart';
import '../Uteis/constantes.dart';
import '../Uteis/textos.dart';

class TelaTarefaConcluidaProgresso extends StatefulWidget {
  const TelaTarefaConcluidaProgresso({Key? key, required this.tipoExibicao})
      : super(key: key);
  final String tipoExibicao;

  @override
  State<TelaTarefaConcluidaProgresso> createState() => _TelaTarefaConcluidaProgressoState();
}

class _TelaTarefaConcluidaProgressoState extends State<TelaTarefaConcluidaProgresso> {
  List<TarefaModelo> listaTarefas = [];
  List<TarefaModelo> listaAuxiliar = [];
  DateTime dataInicial = DateTime(2022, 07, 02);
  int quantidadeTarefas = 0;
  String nomeTela = "";

  // referencia a classepara gerenciar o banco de dados
  final bancoDados = BancoDeDados.instance;

  @override
  void initState() {
    super.initState();
    consultarTarefas(); //chamando metodo
    if(widget.tipoExibicao.contains(Constantes.telaExibirConcluido)){
      nomeTela = Textos.txtTelaTarefaConcluida;
    }else{
      nomeTela = Textos.txtTelaTarefaProgresso;
    }
  }

  //metodo para realizar a consulta no banco de dados
  void consultarTarefas() async {
    // chamando metodo de consulta
    final registros = await bancoDados.consultarLinhas();
    // pegando os valores de cada linha e mudando o estado
    // e atribuindo o valor a variaveis
    for (var linha in registros) {
      setState(() {
        String corString =
            linha[Constantes.bancoCor].toString().split('(0x')[1].split(')')[0];
        int valor = int.parse(corString, radix: 16);
        Color instanciaCor = Color(valor);
        //criando variavel para converter o valor
        // salvo no banco para um valor boleano
        bool favorito;
        if (linha[Constantes.bancoFavorito].toString().contains("0")) {
          favorito = false;
        } else {
          favorito = true;
        }
        // verificando o status da tarefa
        if ((linha[Constantes.bancoStatus] == Constantes.statusConcluido) &&
            widget.tipoExibicao.contains(Constantes.telaExibirConcluido)) {
          // adicionando itens a lista
          adicionarItens(linha, instanciaCor, favorito);
        } else if ((linha[Constantes.bancoStatus] ==
                Constantes.statusEmProgresso) &&
            widget.tipoExibicao.contains(Constantes.telaExibirProgresso)) {
          // adicionando itens a lista
          adicionarItens(linha, instanciaCor, favorito);
        }
      });
    }

    pegarDataAntiga(); // chamando metodo
    adicionarItensListaAuxiliar();
  }

  adicionarItens(var linha, var instanciaCor, var favorito) {
    return listaTarefas.add(TarefaModelo(
        id: linha[Constantes.bancoId],
        titulo: linha[Constantes.bancoTitulo],
        status: linha[Constantes.bancoStatus],
        hora: linha[Constantes.bancoHora],
        data: linha[Constantes.bancoData],
        conteudo: linha[Constantes.bancoConteudo],
        corTarefa: instanciaCor,
        favorito: favorito));
  }

  adicionarItensListaAuxiliar() {
    for (var element in listaTarefas) {
      listaAuxiliar.add(element);
    }
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
                //setando tamanho do icone
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
                  "Você tem $quantidadeTarefas tarefas",
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 25),
                              ));
                        }
                      },
                    ))
              ],
            ),
          ),
        ),
        onWillPop: () async {
          Navigator.pushNamed(context, Constantes.telaInicial);
          return false;
        });
  }
}
