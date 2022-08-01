import 'dart:async';

import 'package:ciernote/Modelo/seletor_cor_modelo.dart';
import 'package:ciernote/Uteis/banco_de_dados.dart';
import 'package:ciernote/Uteis/paleta_cores.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Modelo/tarefa_modelo.dart';
import '../Uteis/constantes.dart';
import '../Uteis/textos.dart';

class TelaEditarTarefa extends StatefulWidget {
  const TelaEditarTarefa({Key? key, required this.item}) : super(key: key);

  final TarefaModelo item;

  @override
  State<TelaEditarTarefa> createState() => _TelaEditarTarefaState();
}

class _TelaEditarTarefaState extends State<TelaEditarTarefa> {
  DateTime data = DateTime(2022, 07, 02);
  TimeOfDay? hora = const TimeOfDay(hour: 19, minute: 00);
  dynamic horaFormatada;
  dynamic corSelecionada = Colors.black;
  bool exibirDefinirHora = false;
  bool mudarStatus = false;
  bool tarefaSecreta = false;
  bool exibirMudarStatus = true;
  String status = "";
  final TextEditingController _controllerTitulo =
      TextEditingController(text: "");
  final TextEditingController _controllerConteudo =
      TextEditingController(text: "");
  bool confirmacaoSairTela = false;

  //variavel usada para validar o formulario
  final _chaveFormulario = GlobalKey<FormState>();

  // referencia nossa classe para gerenciar o banco de dados
  final bancoDados = BancoDeDados.instance;

  // lista com as cores para o usuario selecionar
  final List<SeletorCorModelo> itensCores = [
    SeletorCorModelo(cor: PaletaCores.corMarsala),
    SeletorCorModelo(cor: PaletaCores.corLaranja),
    SeletorCorModelo(cor: PaletaCores.corMarsalaEscuro),
    SeletorCorModelo(cor: PaletaCores.corRosa),
    SeletorCorModelo(cor: PaletaCores.corAmareloDesaturado),
    SeletorCorModelo(cor: PaletaCores.corVermelho),
    SeletorCorModelo(cor: PaletaCores.corAmarela),
    SeletorCorModelo(cor: PaletaCores.corVerde),
    SeletorCorModelo(cor: PaletaCores.corMagenta),
    SeletorCorModelo(cor: PaletaCores.corAzul),
    SeletorCorModelo(cor: PaletaCores.corVerdeLima),
  ];

  //medodo para recuperar dados para a edicao
  recuperarDados() {
    _controllerTitulo.text = widget.item.titulo;
    _controllerConteudo.text = widget.item.conteudo;
    status = widget.item.status;
    if (status.contains(Constantes.statusEmProgresso)) {
      setState(() {
        exibirMudarStatus = false;
      });
    }
    // recuperando a data e convertendo ela de string para o tipo data
    data = DateFormat("dd/MM/yyyy", "pt_BR").parse(widget.item.data);
    DateTime? converterHora;
    //verificando se o horario gravado no banco contem determinado texto para exibir
    // ou nao o campo
    if (widget.item.hora.toString().contains(Constantes.horaSemPrazo)) {
      setState(() {
        exibirDefinirHora = true;
      });
    } else {
      //recuperando hora gravado no banco e convertendo ela de string para o tipo Time
      converterHora = DateFormat("hh:mm").parse(widget.item.hora);
      TimeOfDay horaFormatar =
          TimeOfDay(hour: converterHora.hour, minute: converterHora.minute);
      formatarHora(horaFormatar);
    }
    // recuperando a cor definida e convertendo ela de string para o color
    dynamic cor = widget.item.corTarefa;
    String corString = cor.toString(); // Color(0x12345678)
    String valorString = corString.split('(0x')[1].split(')')[0];
    int valor = int.parse(valorString, radix: 16);
    Color instanciaCor = Color(valor);
    // verificando qual item da lista de cores corresponde
    // a cor recuperada para marcar no seletor
    for (var linha in itensCores) {
      if (linha.cor == instanciaCor) {
        linha.corMarcada = true;
        corSelecionada = linha.cor;
      }
    }
  }

  //metodo para formatar a hora para o formato de 12 horas
  formatarHora(dynamic hora) {
    var formatoHora = DateFormat('hh:mm');
    var horaParse = formatoHora.parse('${hora!.hour}:${hora!.minute}');
    var saidaHoraFormatada = DateFormat('hh:mm a');
    horaFormatada = saidaHoraFormatada.format(horaParse);
  }

  @override
  void initState() {
    super.initState();
    formatarHora(hora);
    recuperarDados();
    tarefaSecreta = widget.item.tarefaSecreta;
  }

  // metodo para atualizar os dados no banco de dados
  atualizarDados() async {
    // linha para incluir os dados
    if (mudarStatus && status.contains(Constantes.statusConcluido)) {
      status = Constantes.statusEmProgresso;
    }
    Map<String, dynamic> linha = {
      BancoDeDados.columnId: widget.item.id,
      BancoDeDados.columnTarefaTitulo: _controllerTitulo.text,
      BancoDeDados.columnTarefaConteudo: _controllerConteudo.text,
      BancoDeDados.columnTarefaData: '${data.day}/${data.month}/${data.year}',
      BancoDeDados.columnTarefaHora: horaFormatada.toString(),
      BancoDeDados.columnTarefaCor: corSelecionada.toString(),
      BancoDeDados.columnTarefaStatus: status,
      BancoDeDados.columnTarefaFavorito: false,
      BancoDeDados.columnTarefaSecreta: tarefaSecreta
    };
    await bancoDados.atualizar(linha,Constantes.nomeTabelaTarefas);
  }

  // metodo para exibir alerta pedindo confirmacao para sair da tela
  Future<bool?> exibirConfirmacaoSairTela() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(Textos.txtTituloAlertaSair),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancelar")),
              TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, Constantes.telaInicial),
                  child: const Text("Sair"))
            ],
          );
        });
  }

// widget para selecao de cor da tarefa
  Widget seletorCor(SeletorCorModelo corModelo) => Column(
        children: [
          Visibility(
            visible: corModelo.corMarcada,
            child: const SizedBox(
              width: 60,
              height: 20,
              child: Icon(Icons.arrow_drop_down, size: 35),
            ),
          ),
          SizedBox(
            height: 50,
            width: 60,
            child: IconButton(
              icon: const Icon(Icons.circle_rounded, size: 50),
              color: corModelo.cor,
              onPressed: () {
                setState(() {
                  setState(() {
                    // utilizando um for para pegar todos os elementos da lista e
                    // setando novo valor para tal parametro permitindo assim
                    // evidenciar somente uma cor selecionada
                    for (var itemLista in itensCores) {
                      itemLista.corMarcada = false;
                    }
                  });
                  //deixando a cor selecionada marcada
                  corModelo.corMarcada = true;
                  corSelecionada = corModelo.cor;
                });
              },
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        if (!confirmacaoSairTela) {
          final confirmacao = await exibirConfirmacaoSairTela();
          return confirmacao ?? false;
        }
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black, size: 30),
            elevation: 0,
            backgroundColor: Colors.white,
            title: SizedBox(
              width: larguraTela * 0.7,
              child: Text(Textos.txtTelaEdicao,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(10),
                width: 120,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(color: PaletaCores.corVerde),
                    shadowColor: PaletaCores.corVerde,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      primary: Colors.white),
                  child: Text(Textos.btnAtualizar,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  onPressed: () {
                    confirmacaoSairTela = true;
                    if (_chaveFormulario.currentState!.validate()) {
                      //verificando se os campos estao vazios
                      // e se o usuario selecionou uma cor para a tarefa
                      if (corSelecionada == Colors.black) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(Textos.erroCorSelecionada)));
                      } else {
                        atualizarDados();
                        //dfsf
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(Textos.sucessoEditarTarefa)));
                        if (tarefaSecreta) {
                          Navigator.pushReplacementNamed(
                              context, Constantes.telaTarefasSecretas);
                        } else {
                          Navigator.pushReplacementNamed(
                              context, Constantes.telaInicial);
                        }
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                    left: 10.0, bottom: 0.0, right: 10.0, top: 10.0),
                width: larguraTela,
                height: alturaTela,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Form(
                    key: _chaveFormulario,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 80,
                          child: Row(
                            children: [
                              Text(Textos.txtTituloTarefa,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                width: larguraTela * 0.55,
                                child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return Textos.erroCampoVazio;
                                      }
                                      return null;
                                    },
                                    maxLines: 1,
                                    maxLength: 50,
                                    controller: _controllerTitulo,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      hintText: Textos.txtTituloTarefaHint,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 2, color: Colors.red),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    )),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 182,
                          width: larguraTela,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 160,
                                child: Column(
                                  children: [
                                    Text(Textos.txtData,
                                        style: const TextStyle(
                                            fontSize: 17,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(
                                      height: 60,
                                      child: TextField(
                                        readOnly: true,
                                        onTap: () async {
                                          DateTime? novaData =
                                              await showDatePicker(
                                                  builder: (context, child) {
                                                    return Theme(
                                                        data: ThemeData.dark()
                                                            .copyWith(
                                                          colorScheme:
                                                              const ColorScheme
                                                                  .light(
                                                            primary: PaletaCores
                                                                .corAzulCianoClaro,
                                                            onPrimary:
                                                                Colors.white,
                                                            onSurface:
                                                                Colors.black,
                                                          ),
                                                          dialogBackgroundColor:
                                                              Colors.white,
                                                        ),
                                                        child: child!);
                                                  },
                                                  context: context,
                                                  initialDate: data,
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2100));

                                          if (novaData == null) return;
                                          setState(() {
                                            data = novaData;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText:
                                              '${data.day}/${data.month}/${data.year}',
                                          prefixIcon:
                                              const Icon(Icons.date_range),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: exibirMudarStatus,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: 160,
                                            child: Text(Textos.txtMudarStatus,
                                                textAlign: TextAlign.center),
                                          ),
                                          Switch(
                                              value: mudarStatus,
                                              activeColor:
                                                  PaletaCores.corAzulCianoClaro,
                                              onChanged: (value) {
                                                setState(() {
                                                  mudarStatus = value;
                                                });
                                              }),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: !exibirMudarStatus,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(Constantes.tarefaSecreta),
                                          Switch(
                                              value: tarefaSecreta,
                                              activeColor:
                                                  PaletaCores.corAzulCianoClaro,
                                              onChanged: (value) {
                                                setState(() {
                                                  tarefaSecreta = value;
                                                  horaFormatada =
                                                      Constantes.horaSemPrazo;
                                                  // redefindo valor da variavel ao desativar o switch
                                                  if (!exibirDefinirHora) {
                                                    horaFormatada = hora;
                                                    formatarHora(hora);
                                                  }
                                                });
                                              }),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                  width: 160,
                                  child: Visibility(
                                    visible: !tarefaSecreta,
                                    child: Column(
                                      children: [
                                        Text(Textos.txtHora,
                                            style: const TextStyle(
                                                fontSize: 17,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(
                                            height: 60,
                                            child: Visibility(
                                              visible: !exibirDefinirHora,
                                              child: TextField(
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      horaFormatada.toString(),
                                                  prefixIcon: const Icon(
                                                      Icons.access_time_filled),
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
                                                ),
                                                onTap: () async {
                                                  TimeOfDay? novoHorario =
                                                      await showTimePicker(
                                                    context: context,
                                                    initialTime: hora!,
                                                    builder: (context, child) {
                                                      return Theme(
                                                        data: ThemeData.dark()
                                                            .copyWith(
                                                          colorScheme:
                                                              const ColorScheme
                                                                  .light(
                                                            primary: PaletaCores
                                                                .corAzulCianoClaro,
                                                            onPrimary:
                                                                Colors.white,
                                                            surface:
                                                                Colors.white,
                                                            onSurface:
                                                                Colors.black,
                                                          ),
                                                        ),
                                                        child: child!,
                                                      );
                                                    },
                                                  );
                                                  if (novoHorario != null) {
                                                    setState(() {
                                                      hora = novoHorario;
                                                      formatarHora(hora);
                                                    });
                                                  }
                                                },
                                              ),
                                            )),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(Constantes.horaSemPrazo),
                                            Switch(
                                                value: exibirDefinirHora,
                                                activeColor: PaletaCores
                                                    .corAzulCianoClaro,
                                                onChanged: (value) {
                                                  setState(() {
                                                    exibirDefinirHora = value;
                                                    horaFormatada =
                                                        Constantes.horaSemPrazo;
                                                    // redefindo valor da variavel ao desativar o switch
                                                    if (!exibirDefinirHora) {
                                                      horaFormatada = hora;
                                                      formatarHora(hora);
                                                    }
                                                  });
                                                }),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: larguraTela,
                          child: Text(Textos.txtDescricaoTarefa,
                              style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(
                          width: larguraTela,
                          height: 300,
                          child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return Textos.erroCampoVazio;
                                }
                                return null;
                              },
                              maxLines: 100,
                              controller: _controllerConteudo,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                hintText: Textos.txtDescricaoTarefaHint,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.black),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 2, color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.black),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              )),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: larguraTela,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(Textos.txtCor,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                width: larguraTela,
                                height: 100,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    ...itensCores
                                        .map((e) => seletorCor(e))
                                        .toList()
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )),
          )),
    );
  }
}
