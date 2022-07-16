import 'dart:ui';

import 'Modelo/tarefa_modelo.dart';
import 'Uteis/banco_de_dados.dart';
import 'Uteis/constantes.dart';

class Consulta {
  // referencia nossa classe single para gerenciar o banco de dados
  static BancoDeDados bancoDados = BancoDeDados.instance;

  //metodo para realizar a consulta no banco de dados
  static Future<TarefaModelo> consultarTarefas() async {
    final registros = await bancoDados.consultarLinhas();
    for (var linha in registros) {
      dynamic cor = linha[Constantes.bancoCor];
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
      return TarefaModelo(
          id: linha[Constantes.bancoId],
          titulo: linha[Constantes.bancoTitulo],
          status: linha[Constantes.bancoStatus],
          hora: linha[Constantes.bancoHora],
          data: linha[Constantes.bancoData],
          conteudo: linha[Constantes.bancoConteudo],
          corTarefa: instanciaCor,
          favorito: favorito);
    }
    return TarefaModelo(titulo: "titulo",
        id: 1,
        conteudo: "conteudo",
        data: "data",
        hora: "hora",
        favorito: false,
        status: "status",
        corTarefa: "corTarefa");
  }
}