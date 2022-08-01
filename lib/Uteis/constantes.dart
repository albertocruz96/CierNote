class Constantes {
  // constantes para a rota das telas
  static const String telaInicial = "/telaInicial";
  static const String telaTarefaAdicao = "/telaTarefaAdicao";
  static const String telaTarefaDetalhada = "/telaTarefaDetalhada";
  static const String telaTarefaEditar = "/telaTarefaEdicao";
  static const String telaTarefasSecretas = "/telaTarefaSecreta";
  static const String telaTarefaConcluidaProgresso =
      "/telaTarefaConcluidaProgresso";

  static const String telaLixeira = "/telaLixeira";
  static const String telaExibirConcluido = "telaConcluida";
  static const String telaExibirProgresso = "telaProgresso";
  static const String telaParametroDetalhes = "detalhesTarefa";
  static const String telaParametroTelaDetalhesComando = "comandoTela";

  static String horaSemPrazo = "Sem Horário";
  static String tarefaSecreta = "Tarefa Secreta";

  // constantes para o status da tarefa
  static const String statusEmProgresso = "Em Progresso";
  static const String statusConcluido = "Concluido";

  // constantes usadas nos pop ups na tela onde fica os detalhes da tarefa
  static const String popUpMenuEditar = "editar";
  static const String popUpMenuFavoritar = "favorito";
  static const String popUpMenuNotificacao = "notificacao";

  // constantes para a notificacao
  static const String canalNotificacaoPadrao = "Notificações Padrão";
  static const String tipoNotiAgendada = "agendada";
  static const String tipoNotiPermanente = "permanente";

  // constantes para o banco de dados sql lite
  static const nomeBanco = "tarefasBanco.db";
  static const nomeTabelaTarefas = 'tarefas';
  static const nomeTabelaLixeira = 'lixeira';
  static const bancoId = 'id';
  static const bancoTitulo = 'titulo';
  static const bancoConteudo = 'conteudo';
  static const bancoCor = 'cor';
  static const bancoData = 'data';
  static const bancoHora = 'hora';
  static const bancoStatus = 'status';
  static const bancoFavorito = 'favorito';
  static const bancoNotificacao = 'notificacao';
  static const bancoTarefaSecreta = 'secreta';
}
