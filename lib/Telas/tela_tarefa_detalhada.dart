import 'dart:async';

import 'package:ciernote/Modelo/notificacao_modelo.dart';
import 'package:ciernote/Modelo/tarefa_modelo.dart';
import 'package:ciernote/Uteis/banco_de_dados.dart';
import 'package:ciernote/Widget/bloquear_tela_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Uteis/Servicos/notificacao_servico.dart';
import '../Uteis/constantes.dart';
import '../Uteis/paleta_cores.dart';
import '../Uteis/textos.dart';

class TarefaDetalhada extends StatefulWidget {
  const TarefaDetalhada(
      {Key? key, required this.item, required this.comandoTelaLixeira})
      : super(key: key);

  final TarefaModelo item;
  final bool comandoTelaLixeira;

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
    // verificando se a tarefa contem os seguintes parametros
    // para definir valor da variavel que ira exibir ou nao determinados botoes
    if (widget.item.status == Constantes.statusConcluido ||
        widget.item.tarefaSecreta == true) {
      setState(() {
        exibirBotoes = false;
      });
    } else if (widget.comandoTelaLixeira) {
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
        setState(() {
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
    await bancoDados.atualizar(linha, Constantes.nomeTabelaTarefas);
  }

  // metodo para cancelar a notificacao
  chamarCancelarNotificacao() async {
    // passando um provider com o id da tarefa
    await Provider.of<NotificacaoServico>(context, listen: false)
        .cancelarNotificacao(widget.item.id);
  }

  // metodo para iniciar as notificacoes dependendo
  // do tipo de horario especificado
  iniciarNotificacao() {
    String tipoNotificacao = Constantes.tipoNotiAgendada;
    //
    if (widget.item.hora.toString().contains(Textos.horaSemPrazo)) {
      tipoNotificacao = Constantes.tipoNotiPermanente;
    }
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
                    // verificando se a variavel contem o valor verdadeira
                    // se tiver corresponde a tela de lixeira
                    if (widget.comandoTelaLixeira) {
                      bancoDados.excluir(
                          widget.item.id, Constantes.nomeTabelaLixeira);
                      Navigator.pushReplacementNamed(
                          context, Constantes.telaInicial);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(Textos.sucessoExclusaoTarefa)));
                    } else {
                      chamarCancelarNotificacao();
                      // inserindo dados na tabela
                      inserirDadosTabela(Constantes.nomeTabelaLixeira);
                      // definindo um timer para excluir os dados da tabela apos inserir na outra tabela
                      bancoDados.excluir(
                          widget.item.id, Constantes.nomeTabelaTarefas);
                      Navigator.pushReplacementNamed(
                          context, Constantes.telaLixeira);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(Textos.sucessoMoverTarefaLixeira)));
                    }
                  },
                  child: Text(widget.comandoTelaLixeira
                      ? Textos.btnExcluir
                      : Textos.btnMoverLixeira))
            ],
          );
        });
  }

  // metodo para inserir os dados na tabela no banco de dados
  inserirDadosTabela(String tabela) async {
    // linha para incluir os dados
    Map<String, dynamic> linha = {
      BancoDeDados.columnTarefaTitulo: widget.item.titulo,
      BancoDeDados.columnTarefaConteudo: widget.item.conteudo,
      BancoDeDados.columnTarefaData: widget.item.data,
      BancoDeDados.columnTarefaHora: widget.item.hora,
      BancoDeDados.columnTarefaCor: widget.item.corTarefa.toString(),
      BancoDeDados.columnTarefaStatus: widget.item.status,
      BancoDeDados.columnTarefaFavorito: widget.item.favorito,
      BancoDeDados.columnTarefaNotificacao: false,
      BancoDeDados.columnTarefaSecreta: widget.item.tarefaSecreta
    };
    await bancoDados.inserir(linha, tabela);
  }

  Widget botoes(double largura, double altura, String tituloBotao, Color cor) =>
      SizedBox(
        height: altura,
        width: largura,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            side: BorderSide(color: cor),
            primary: Colors.white,
            elevation: 5,
            shadowColor: cor,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
          ),
          onPressed: () {
            if (tituloBotao == Textos.btnMoverLixeira ||
                tituloBotao == Textos.btnExcluir) {
              exibirConfirmacaoExcluir();
            } else if (tituloBotao == Textos.btnConcluido) {
              chamarCancelarNotificacao();
              atualizarInfoBanco(Constantes.bancoStatus);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(Textos.sucessoConcluidoTarefa)));
              Navigator.pushReplacementNamed(
                  context, Constantes.telaTarefaConcluidaProgresso,
                  arguments: Constantes.telaExibirConcluido);
            } else {
              inserirDadosTabela(Constantes.nomeTabelaTarefas);
              bancoDados.excluir(
                  widget.item.id, Constantes.nomeTabelaLixeira);
              Navigator.pushReplacementNamed(context, Constantes.telaInicial);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(Textos.sucessoRestaurarTarefa)));
            }
          },
          child: Text(
            tituloBotao,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      );

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
                  enabled: !widget.comandoTelaLixeira,
                  onSelected: (value) {
                    if (value == Constantes.popUpMenuEditar) {
                      //passando dados para a tela de edicao
                      var dadosTela = {};
                      dadosTela[Constantes.parametroDetalhesTarefa] =
                          widget.item;
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
              iconTheme: const IconThemeData(color: Colors.black, size: 30),
            ),
            body: Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                    left: 10.0, bottom: 10.0, right: 10.0, top: 10.0),
                width: larguraTela,
                height: alturaTela,
                child: Stack(
                  children: [
                    SingleChildScrollView(
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
                                          color: widget.item.corTarefa,
                                          size: 30),
                                    ),
                                  ],
                                ),
                                Visibility(
                                    visible: !widget.item.tarefaSecreta,
                                    child: Column(
                                      children: [
                                        Text(Textos.txtHora,
                                            style: const TextStyle(
                                                fontSize: 17,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold)),
                                        Row(
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 0.0,
                                                      horizontal: 10.0),
                                              height: 30,
                                              width: 30,
                                              child: Icon(Icons.access_time,
                                                  color: widget.item.corTarefa),
                                            ),
                                            Text(widget.item.hora),
                                          ],
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Visibility(
                              visible: !widget.item.tarefaSecreta,
                              child: Row(
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
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Visibility(
                                    visible: widget.comandoTelaLixeira
                                        ? true
                                        : exibirBotoes,
                                    child: botoes(
                                        widget.comandoTelaLixeira ? 180 : 150,
                                        50,
                                        widget.comandoTelaLixeira
                                            ? Textos.btnRestaurarLixeira
                                            : Textos.btnConcluido,
                                        PaletaCores.corVerde)),
                                botoes(
                                    widget.comandoTelaLixeira ? 120 : 200,
                                    50,
                                    widget.comandoTelaLixeira
                                        ? Textos.btnExcluir
                                        : Textos.btnMoverLixeira,
                                    PaletaCores.corVermelho)
                              ],
                            )
                          ],
                        )),
                    BloquearTelaWidget(
                      item: widget.item,
                    ),
                  ],
                ))),
        onWillPop: () async {
          if (widget.item.tarefaSecreta && !widget.comandoTelaLixeira) {
            Navigator.popAndPushNamed(context, Constantes.telaTarefaSecretaFavorito,arguments: Constantes.telaExibirTarefaSecreta);
          }else if (widget.comandoTelaLixeira) {
            Navigator.popAndPushNamed(context, Constantes.telaLixeira);
          } else {
            Navigator.popAndPushNamed(context, Constantes.telaInicial);
          }
          return false;
        });
  }
}
