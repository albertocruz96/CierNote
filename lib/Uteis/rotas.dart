import 'package:ciernote/Telas/tela_editar_tarefa.dart';
import 'package:ciernote/Telas/tela_principal.dart';
import 'package:ciernote/Telas/tela_adionar_tarefa.dart';
import 'package:ciernote/Telas/tela_tarefa_concluida_progresso.dart';
import 'package:ciernote/Uteis/constantes.dart';
import 'package:ciernote/Telas/tela_tarefa_detalhada.dart';
import 'package:flutter/material.dart';

import '../Telas/tela_tarefa_secretas.dart';

class Rotas {
  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Recebe os parâmetros na chamada do Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case Constantes.telaInicial:
        return MaterialPageRoute(builder: (_) => const TelaPrincipal());
      case Constantes.telaTarefasSecretas:
        return MaterialPageRoute(builder: (_) => const TelaTarefasSecretas());
      case Constantes.telaTarefaAdicao:
        return MaterialPageRoute(builder: (_) => const TelaAdionarTarefa());
      case Constantes.telaTarefaDetalhada:
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => TarefaDetalhada(
              item: args[Constantes.telaParametroDetalhes],
            ),
          );
        } else {
          return erroRota(settings);
        }
      case Constantes.telaTarefaEditar:
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => TelaEditarTarefa(
              item: args[Constantes.telaParametroDetalhes],
            ),
          );
        } else {
          return erroRota(settings);
        }
      case Constantes.telaTarefaConcluidaProgresso:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => TelaTarefaConcluidaProgresso(
              tipoExibicao: args,
            ),
          );
        } else {
          return erroRota(settings);
        }
      // case Constantes.telaTarefaDetalhada:
      //   if (args is String) {
      //     return MaterialPageRoute(
      //       builder: (_) => TarefaDetalhada(
      //         item: args,
      //       ),
      //     );
      //   } else {
      //     return erroRota(settings);
      //   }
      // case Constantes.rotaSelecaoEscala:
      //   return MaterialPageRoute(builder: (_) => const TelaSelecaoEscalas());
      // case Constantes.rotaVerLista:
      //   if (args is String) {
      //     return MaterialPageRoute(
      //       builder: (_) => TelaListagem(
      //         nomeTabela: args,
      //       ),
      //     );
      //   } else {
      //     return erroRota(settings);
      //   }
    }

    // Se o argumento não é do tipo correto, retorna erro
    return erroRota(settings);
  }

  //metodo para exibir mensagem de erro
  static Route<dynamic> erroRota(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text("Tela não encontrada!"),
        ),
        body: Container(
          color: Colors.red,
          child: const Center(
            child: Text("Tela não encontrada."),
          ),
        ),
      );
    });
  }
}
