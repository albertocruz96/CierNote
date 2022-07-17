import 'dart:async';

import 'package:ciernote/Modelo/tarefa_modelo.dart';
import 'package:ciernote/Uteis/banco_de_dados.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../Uteis/constantes.dart';
import '../Uteis/paleta_cores.dart';
import '../Uteis/textos.dart';

class TarefaDetalhada extends StatefulWidget {
  const TarefaDetalhada({Key? key, required this.item}) : super(key: key);

  final TarefaModelo item;

  @override
  State<TarefaDetalhada> createState() => _TarefaDetalhadaState();
}

class _TarefaDetalhadaState extends State<TarefaDetalhada> {
  final bancoDados = BancoDeDados.instance;
  late bool ativarFavorito;
  late bool exibirBotoes = true;
  var dadosTela = {};
  DateTime data = DateTime(2022, 07, 02);
  TimeOfDay? hora = const TimeOfDay(hour: 19, minute: 00);

  String conteudoNotificacao = "";
  String tituloNotificacao = "";
  int idNotificacao = 0;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    ativarFavorito = widget.item.favorito;
    if (widget.item.status == Constantes.statusConcluido) {
      setState(() {
        exibirBotoes = false;
      });
    }
    idNotificacao = widget.item.id;
    tituloNotificacao = widget.item.titulo;
    conteudoNotificacao = widget.item.conteudo;
    iniciarNotificacao();
  }

  iniciarNotificacao() {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) => SelectNotification(payload!));
  }

  Future SelectNotification(String payload) async {
    var dadosTela = {};
    dadosTela[Constantes.telaParametroDetalhes] = widget.item;
    Navigator.pushNamed(context, Constantes.telaTarefaDetalhada,
        arguments: dadosTela);
  }

  void atualizarFavoritoBanco() async {
    setState(() {
      if (ativarFavorito) {
        ativarFavorito = false;
      } else {
        ativarFavorito = true;
      }
    });
    Map<String, dynamic> linha = {
      BancoDeDados.columnId: widget.item.id,
      BancoDeDados.columnTarefaTitulo: widget.item.titulo,
      BancoDeDados.columnTarefaConteudo: widget.item.conteudo,
      BancoDeDados.columnTarefaData: widget.item.data,
      BancoDeDados.columnTarefaHora: widget.item.hora,
      BancoDeDados.columnTarefaCor: widget.item.corTarefa.toString(),
      BancoDeDados.columnTarefaStatus: widget.item.status,
      BancoDeDados.columnTarefaFavorito: ativarFavorito,
    };
    await bancoDados.atualizar(linha);
  }

  void atualizarStatusBanco() async {
    Map<String, dynamic> linha = {
      BancoDeDados.columnId: widget.item.id,
      BancoDeDados.columnTarefaTitulo: widget.item.titulo,
      BancoDeDados.columnTarefaConteudo: widget.item.conteudo,
      BancoDeDados.columnTarefaData: widget.item.data,
      BancoDeDados.columnTarefaHora: widget.item.hora,
      BancoDeDados.columnTarefaCor: widget.item.corTarefa.toString(),
      BancoDeDados.columnTarefaStatus: Constantes.statusConcluido,
      BancoDeDados.columnTarefaFavorito: ativarFavorito,
    };
    await bancoDados.atualizar(linha);
  }

  //metodo para exibir alerta para excluir tarefa do banco de dados
  Future<void> exibirConfirmacaoExcluir() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(Textos.txtTituloAlertaExclusao),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancelar")),
              TextButton(
                  onPressed: () {
                    //chamando metodo para excluir passando como parametro o id
                    bancoDados.excluir(widget.item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(Textos.sucessoExclusaoTarefa)));
                    Navigator.pushNamed(context, Constantes.telaInicial);
                  },
                  child: const Text("Excluir"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;

    exibirNotificacao() async {
      var android = const AndroidNotificationDetails(
          "channelId", Constantes.canalNotificacaoPermanentes,
          priority: Priority.max, importance: Importance.high,indeterminate: true,);
      var iOS = const IOSNotificationDetails();
      var plataform = NotificationDetails(android: android, iOS: iOS);
      await flutterLocalNotificationsPlugin.show(
        idNotificacao,
        tituloNotificacao,
        conteudoNotificacao,
        plataform,
        payload: "fdfsdf",
      );
    }

    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              title: SizedBox(
                width: larguraTela * 0.7,
                child: Text(Textos.txtTelaDetalhes,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 25,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
              ),
              actions: [
                PopupMenuButton(
                  onSelected: (value) {
                    if (value == Constantes.popUpMenuEditar) {
                      var dadosTela = {};
                      dadosTela[Constantes.telaParametroDetalhes] = widget.item;
                      Navigator.pushNamed(context, Constantes.telaTarefaEditar,
                          arguments: dadosTela);
                    } else if (value == Constantes.popUpMenuFavoritar) {
                      atualizarFavoritoBanco();
                      if (ativarFavorito) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(Textos.sucessoAdicaoFavorito)));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(Textos.sucessoRemocaoFavorito)));
                      }
                    } else if (value == Constantes.popUpMenuNotificacao) {
                      exibirNotificacao();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                        value: Constantes.popUpMenuEditar,
                        child: Row(
                          children: const [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.edit,
                                size: 30,
                                color: PaletaCores.corAzulCianoClaro,
                              ),
                            ),
                            Text("Editar")
                          ],
                        )),
                    PopupMenuItem(
                        value: Constantes.popUpMenuFavoritar,
                        enabled: exibirBotoes,
                        child: Row(
                          children: [
                            SizedBox(
                                width: 40,
                                height: 40,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    if (ativarFavorito) {
                                      return const Icon(
                                        Icons.favorite_outlined,
                                        size: 30,
                                        color: PaletaCores.corAzulCianoClaro,
                                      );
                                    } else {
                                      return const Icon(
                                        Icons.favorite_border_outlined,
                                        size: 30,
                                        color: PaletaCores.corAzulCianoClaro,
                                      );
                                    }
                                  },
                                )),
                            const Text("Favoritar")
                          ],
                        )),
                    PopupMenuItem(
                        value: Constantes.popUpMenuNotificacao,
                        child: Row(
                          children: const [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.notification_add,
                                size: 30,
                                color: PaletaCores.corAzulCianoClaro,
                              ),
                            ),
                            Text("Ativar Notificacao")
                          ],
                        )),
                  ],
                )
              ],
              iconTheme: const IconThemeData(color: Colors.black),
              leading: IconButton(
                //setando tamanho do icone
                iconSize: 30,
                onPressed: () {
                  Navigator.pushNamed(context, Constantes.telaInicial);
                },
                icon: const Icon(Icons.arrow_back_outlined),
                color: Colors.black,
              ),
            ),
            body: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(
                  left: 10.0, bottom: 10.0, right: 10.0, top: 10.0),
              width: larguraTela,
              height: alturaTela,
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 30,
                            child: Text(Textos.txtTituloTarefa,
                                style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(
                            width: larguraTela * 0.5,
                            height: 30,
                            child: Text(widget.item.titulo,
                                style: const TextStyle(
                                  fontSize: 17,
                                )),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(Textos.txtData,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 0.0, horizontal: 10.0),
                                    height: 30,
                                    width: 30,
                                    child: Icon(Icons.calendar_month,
                                        color: widget.item.corTarefa),
                                  ),
                                  Text(widget.item.data),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(Textos.txtCor,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                width: 30,
                                height: 30,
                                child: Icon(Icons.circle,
                                    color: widget.item.corTarefa, size: 30),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(Textos.txtHora,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 0.0, horizontal: 10.0),
                                    height: 30,
                                    width: 30,
                                    child: Icon(Icons.access_time,
                                        color: widget.item.corTarefa),
                                  ),
                                  Text(widget.item.hora),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(Textos.txtStatus,
                              style: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          Text(widget.item.status,
                              style: const TextStyle(
                                  fontSize: 17, color: Colors.black)),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: larguraTela,
                        child: Text(Textos.txtDescricaoTarefa,
                            style: const TextStyle(
                                fontSize: 25,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          border: Border(
                            top: BorderSide(
                                width: 1,
                                color: Colors.black,
                                style: BorderStyle.solid), //BorderSide
                            bottom: BorderSide(
                                width: 1,
                                color: Colors.black,
                                style: BorderStyle.solid), //BorderSide
                            left: BorderSide(
                                width: 1,
                                color: Colors.black,
                                style: BorderStyle.solid), //Borderside
                            right: BorderSide(
                                width: 1,
                                color: Colors.black,
                                style: BorderStyle.solid), //BorderSide
                          ), //Border
                        ),
                        width: larguraTela,
                        height: 350,
                        child: Text(
                          widget.item.conteudo,
                          maxLines: 100,
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Visibility(
                              visible: exibirBotoes,
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                width: 120,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      primary: Colors.green),
                                  child: Text(Textos.btnConcluido,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                  onPressed: () {
                                    atualizarStatusBanco();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(Textos
                                                .sucessoConcluidoTarefa)));
                                    Navigator.pushNamed(context,
                                        Constantes.telaTarefaConcluidaProgresso,
                                        arguments:
                                            Constantes.telaExibirConcluido);
                                  },
                                ),
                              )),
                          Container(
                            margin: const EdgeInsets.all(10),
                            width: 120,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  primary: Colors.red),
                              child: Text(Textos.txtExcluir,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              onPressed: () {
                                exibirConfirmacaoExcluir();
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
            )),
        onWillPop: () async {
          Navigator.pushNamed(context, Constantes.telaInicial);
          return false;
        });
  }
}
