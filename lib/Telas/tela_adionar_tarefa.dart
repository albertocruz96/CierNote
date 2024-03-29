import 'dart:async';

import 'package:ciernote/Modelo/seletor_cor_modelo.dart';
import 'package:ciernote/Uteis/banco_de_dados.dart';
import 'package:ciernote/Uteis/paleta_cores.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Uteis/constantes.dart';
import '../Uteis/textos.dart';
import '../Widget/dados_usuario_widget.dart';

class TelaAdionarTarefa extends StatefulWidget {
  const TelaAdionarTarefa({Key? key}) : super(key: key);

  @override
  State<TelaAdionarTarefa> createState() => _TelaAdionarTarefaState();
}

class _TelaAdionarTarefaState extends State<TelaAdionarTarefa> {
  DateTime data = DateTime.now();
  late dynamic hora;
  dynamic horaFormatada;
  dynamic corSelecionada = Colors.black;
  bool exibirDefinirHora = false;
  bool tarefaSecreta = false;
  bool ativarTelaUsuario = false;
  final TextEditingController _controllerTitulo =
      TextEditingController(text: "");
  final TextEditingController _controllerConteudo =
      TextEditingController(text: "");
  bool confirmacaoSairTela = false;

  //variavel usada para validar o formulario
  final _chaveFormulario = GlobalKey<FormState>();

  // referencia classe para gerenciar o banco de dados
  final bancoDados = BancoDeDados.instance;

  //metodo para formatar a hora para o formato 12 horas
  formatarHora() {
    // pegando o formato desejado
    var formatoHora = DateFormat('HH:mm');
    // atribuindo a variavel de hora o formato e adicionando 30 minutos ao horario
    var horaParse = formatoHora.parse('${hora!.hour}:${hora!.minute}');
    // criando o formato de saida
    var saidaHoraFormatada = DateFormat('hh:mm a');
    //definindo que a variavel vai receber o formato de saida
    horaFormatada = saidaHoraFormatada.format(horaParse);
  }

  @override
  void initState() {
    super.initState();
    // pegando a hora no formato 24 horas e adicionando 30 minutos ao horario atual do aparelho
    String horaComAdicao =
        DateFormat('kk:mm').format(data.add(const Duration(minutes: 30)));
    // dividindo string conforme parametro passado
    List<String> dividirStringHora = horaComAdicao.split(":");
    int hour = int.parse(dividirStringHora.first);
    int minute = int.parse(dividirStringHora.last);
    hora = TimeOfDay(hour: hour, minute: minute);
    formatarHora();
  }

  consultarUsuario() async {
    final registros =
        await bancoDados.consultarLinhas(Constantes.nomeTabelaUsuario);
    if (registros.isNotEmpty) {
      inserirDados();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(Textos.sucessoAdicaoTarefa)));
      if (tarefaSecreta) {
        Navigator.pushReplacementNamed(
            context, Constantes.telaTarefaSecretaFavorito,
            arguments: Constantes.telaExibirTarefaSecreta);
      } else {
        Navigator.pushReplacementNamed(
            context, Constantes.telaInicial);
      }
    } else {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(Textos.erroSemUsuario)));
      setState((){
        ativarTelaUsuario = true;
      });
    }
  }

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

  // metodo para inserir os dados no banco de dados
  inserirDados() async {
    // linha para incluir os dados
    Map<String, dynamic> linha = {
      BancoDeDados.columnTarefaTitulo: _controllerTitulo.text,
      BancoDeDados.columnTarefaConteudo: _controllerConteudo.text,
      BancoDeDados.columnTarefaData: '${data.day}/${data.month}/${data.year}',
      BancoDeDados.columnTarefaHora: horaFormatada.toString(),
      BancoDeDados.columnTarefaCor: corSelecionada.toString(),
      BancoDeDados.columnTarefaStatus: Constantes.statusEmProgresso,
      BancoDeDados.columnTarefaFavorito: false,
      BancoDeDados.columnTarefaNotificacao: false,
      BancoDeDados.columnTarefaSecreta: tarefaSecreta
    };
    await bancoDados.inserir(linha, Constantes.nomeTabelaTarefas);
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
                  onPressed: () => Navigator.popAndPushNamed(
                      context, Constantes.telaInicial),
                  child: const Text("Cancelar")),
              TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, Constantes.telaInicial),
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
              child: Text(Textos.txtTelaCriarTarefa,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(10),
                width: 100,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: PaletaCores.corVerde),
                      shadowColor: PaletaCores.corVerde,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      primary: Colors.white),
                  child: Text(Textos.btnSalvar,
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
                        if (tarefaSecreta) {
                          consultarUsuario();
                        } else {
                          inserirDados();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(Textos.sucessoAdicaoTarefa)));
                          if (tarefaSecreta) {
                            Navigator.pushReplacementNamed(
                                context, Constantes.telaTarefaSecretaFavorito,
                                arguments: Constantes.telaExibirTarefaSecreta);
                          } else {
                            Navigator.pushReplacementNamed(
                                context, Constantes.telaInicial);
                          }
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
                child: Stack(
                  children: [
                    SingleChildScrollView(
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
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 2, color: Colors.red),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        )),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 140,
                              width: larguraTela,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(Textos.txtData,
                                          style: const TextStyle(
                                              fontSize: 17,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(
                                        width: 180,
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
                                                    initialDate: data.add(
                                                        const Duration(
                                                            minutes: 30)),
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
                                                  width: 1,
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  width: 1,
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(Textos.tarefaSecreta),
                                          Switch(
                                              value: tarefaSecreta,
                                              activeColor:
                                                  PaletaCores.corAzulCianoClaro,
                                              onChanged: (value) {
                                                setState(() {
                                                  tarefaSecreta = value;
                                                  horaFormatada =
                                                      Textos.horaSemPrazo;
                                                });
                                              }),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      width: 180,
                                      child: Visibility(
                                        visible: !tarefaSecreta,
                                        child: Column(
                                          children: [
                                            Text(Textos.txtHora,
                                                style: const TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SizedBox(
                                                width: 180,
                                                height: 60,
                                                child: Visibility(
                                                  visible: !exibirDefinirHora,
                                                  child: TextField(
                                                    readOnly: true,
                                                    decoration: InputDecoration(
                                                      hintText: horaFormatada
                                                          .toString(),
                                                      prefixIcon: const Icon(Icons
                                                          .access_time_filled),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                                width: 1,
                                                                color: Colors
                                                                    .black),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                                width: 1,
                                                                color: Colors
                                                                    .black),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    onTap: () async {
                                                      TimeOfDay? novoHorario =
                                                          await showTimePicker(
                                                        context: context,
                                                        initialTime: hora!,
                                                        builder:
                                                            (context, child) {
                                                          return Theme(
                                                            data:
                                                                ThemeData.dark()
                                                                    .copyWith(
                                                              colorScheme:
                                                                  const ColorScheme
                                                                      .light(
                                                                primary: PaletaCores
                                                                    .corAzulCianoClaro,
                                                                onPrimary:
                                                                    Colors
                                                                        .white,
                                                                surface: Colors
                                                                    .white,
                                                                onSurface:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                            child: child!,
                                                          );
                                                        },
                                                      );
                                                      if (novoHorario != null) {
                                                        setState(() {
                                                          hora = novoHorario;
                                                          formatarHora();
                                                        });
                                                      }
                                                    },
                                                  ),
                                                )),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(Textos.horaSemPrazo),
                                                Switch(
                                                    value: exibirDefinirHora,
                                                    activeColor: PaletaCores
                                                        .corAzulCianoClaro,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        exibirDefinirHora =
                                                            value;
                                                        horaFormatada =
                                                            Textos.horaSemPrazo;
                                                        // redefindo valor da variavel ao desativar o switch
                                                        if (!exibirDefinirHora) {
                                                          horaFormatada = hora;
                                                          formatarHora();
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
                    ),
                    Positioned(
                        child: Visibility(
                      visible: ativarTelaUsuario,
                      child: SizedBox(
                        height: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: FloatingActionButton(
                                backgroundColor: PaletaCores.corVermelho,
                                heroTag: "btnFechar",
                                onPressed: () {
                                  setState(() {
                                    ativarTelaUsuario = false;
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const DadosUsuarioWidget()
                          ],
                        ),
                      ),
                    ))
                  ],
                )),
          )),
    );
  }
}
