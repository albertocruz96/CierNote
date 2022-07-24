import 'dart:async';

import 'package:ciernote/Modelo/notificacao.dart';
import 'package:ciernote/Modelo/tarefa_modelo.dart';
import 'package:ciernote/Uteis/banco_de_dados.dart';
import 'package:ciernote/Uteis/notificacao_servico.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  late bool ativarNotificacao;
  late bool exibirBotoes = true;

  @override
  void initState() {
    super.initState();
    ativarFavorito = widget.item.favorito;
    ativarNotificacao = widget.item.notificacaoAtiva;
    if (widget.item.status == Constantes.statusConcluido) {
      setState(() {
        exibirBotoes = false;
      });
    }
  }

  // metodo para atualizar os campos status,favorito e notificacao no banco de dados
  void atualizarInfoBanco(String tipoAtualizacao) async {
    String status = widget.item.status;
    setState(() {
      if (tipoAtualizacao.contains(Constantes.bancoFavorito)) {
        if (ativarFavorito) {
          ativarFavorito = false;
        } else {
          ativarFavorito = true;
        }
      } else if (tipoAtualizacao.contains(Constantes.bancoStatus)) {
        setState((){
          status = Constantes.statusConcluido;
          ativarNotificacao = false;
          ativarFavorito = false;
        });
      } else if (tipoAtualizacao.contains(Constantes.bancoNotificacao)) {
        if (ativarNotificacao) {
          chamarCancelarNotificacao();
          ativarNotificacao = false;
        } else {
          iniciarNotificacao();
          ativarNotificacao = true;
        }
      }
    });
    Map<String, dynamic> linha = {
      BancoDeDados.columnId: widget.item.id,
      BancoDeDados.columnTarefaTitulo: widget.item.titulo,
      BancoDeDados.columnTarefaConteudo: widget.item.conteudo,
      BancoDeDados.columnTarefaData: widget.item.data,
      BancoDeDados.columnTarefaHora: widget.item.hora,
      BancoDeDados.columnTarefaCor: widget.item.corTarefa.toString(),
      BancoDeDados.columnTarefaStatus: status,
      BancoDeDados.columnTarefaFavorito: ativarFavorito,
      BancoDeDados.columnTarefaNotificacao: ativarNotificacao
    };
    await bancoDados.atualizar(linha);
  }

  chamarCancelarNotificacao() async {
    await Provider.of<NotificacaoServico>(context, listen: false)
        .cancelarNotificacao(widget.item.id);
  }

  iniciarNotificacao() {
    String tipoNotificacao = Constantes.tipoNotiAgendada;
    if (widget.item.hora.toString().contains(Constantes.horaSemPrazo)) {
      tipoNotificacao = Constantes.tipoNotiPermanente;
    }
    var dados = {};
    dados["teste"] = Constantes.telaTarefaDetalhada;
    NotificacaoServico.chamarExibirNotificacao(
        NotificacaoModelo(
            id: widget.item.id,
            titulo: widget.item.titulo,
            corpoNotificacao: widget.item.conteudo,
            data: widget.item.data,
            hora: widget.item.hora,
            payload: Constantes.telaTarefaDetalhada),
        tipoNotificacao,
        context);
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
                    chamarCancelarNotificacao();
                    //chamando metodo para excluir passando como parametro o id
                    bancoDados.excluir(widget.item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(Textos.sucessoExclusaoTarefa)));
                    Navigator.pushReplacementNamed(
                        context, Constantes.telaInicial);
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
                      //passando dados para a tela de edicao
                      var dadosTela = {};
                      dadosTela[Constantes.telaParametroDetalhes] = widget.item;
                      Navigator.pushReplacementNamed(
                          context, Constantes.telaTarefaEditar,
                          arguments: dadosTela);
                    } else if (value == Constantes.popUpMenuFavoritar) {
                      atualizarInfoBanco(Constantes.bancoFavorito);
                      if (ativarFavorito) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(Textos.sucessoAdicaoFavorito)));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(Textos.sucessoRemocaoFavorito)));
                      }
                    } else if (value == Constantes.popUpMenuNotificacao) {
                      atualizarInfoBanco(Constantes.bancoNotificacao);
                      if (ativarNotificacao) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(Textos.sucessoAtivarNotificacao)));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(Textos.sucessoDesativarNotificacao)));
                      }
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
                        enabled: exibirBotoes,
                        child: Row(
                          children: [
                            SizedBox(
                                width: 40,
                                height: 40,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    if (ativarNotificacao) {
                                      return const Icon(
                                        Icons.notification_add,
                                        size: 30,
                                        color: PaletaCores.corAzulCianoClaro,
                                      );
                                    } else {
                                      return const Icon(
                                        Icons.notification_add_outlined,
                                        size: 30,
                                        color: PaletaCores.corAzulCianoClaro,
                                      );
                                    }
                                  },
                                )),
                            const Text("Ativar Notificacao")
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
                                    chamarCancelarNotificacao();
                                    atualizarInfoBanco(Constantes.bancoStatus);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(Textos
                                                .sucessoConcluidoTarefa)));
                                    Navigator.pushReplacementNamed(context,
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
