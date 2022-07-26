import 'dart:ui';

import '../Modelo/tarefa_modelo.dart';
import 'banco_de_dados.dart';
import 'constantes.dart';

class Consulta {
  // referencia nossa classe single para gerenciar o banco de dados
  static BancoDeDados bancoDados = BancoDeDados.instance;

  //metodo para realizar a consulta no banco de dados
  static Future<List<TarefaModelo>> consultarTarefasBanco(
      String removerTarefaConcluido) async {
    final registros = await bancoDados.consultarLinhas();
    List<TarefaModelo> lista = [];
    for (var linha in registros) {
      dynamic cor = linha[Constantes.bancoCor];
      // pegando valor e convertendo para o formato para definir a cor
      String corString = cor.toString().split('(0x')[1].split(')')[0];
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
      bool notificacao;
      if (linha[Constantes.bancoNotificacao].toString().contains("0")) {
        notificacao = false;
      } else {
        notificacao = true;
      }
      lista.add(TarefaModelo(
          id: linha[Constantes.bancoId],
          titulo: linha[Constantes.bancoTitulo],
          status: linha[Constantes.bancoStatus],
          hora: linha[Constantes.bancoHora],
          data: linha[Constantes.bancoData],
          conteudo: linha[Constantes.bancoConteudo],
          corTarefa: instanciaCor,
          favorito: favorito,
          notificacaoAtiva: notificacao));
      // verificando qual parametro foi passado para o metodo
      // para remover itens que nao devem aparecer dependendo da visualizacao
      if (removerTarefaConcluido == Constantes.statusConcluido) {
        for (int i = 0; i < lista.length; i++) {
          // percorrendo os index da lista e verificando quais contem a condicao desejada
          if (lista[i].status == Constantes.statusConcluido) {
            lista.removeAt(i);
          }
        }
      } else if (removerTarefaConcluido == Constantes.statusEmProgresso) {
        for (int i = 0; i < lista.length; i++) {
          // percorrendo os index da lista e verificando quais contem a condicao desejada
          if (lista[i].status == Constantes.statusEmProgresso) {
            lista.removeAt(i);
          }
        }
      }
    }
    return lista;
  }
}
