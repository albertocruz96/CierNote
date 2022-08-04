class Constantes {
  // constantes para a rota das telas
  static const String telaInicial = "/telaInicial";
  static const String telaTarefaAdicao = "/telaTarefaAdicao";
  static const String telaTarefaDetalhada = "/telaTarefaDetalhada";
  static const String telaTarefaEditar = "/telaTarefaEdicao";
  static const String telaTarefaSecretaFavorito = "/telaTarefaSecretaFavorito";
  static const String telaTarefaConcluidaProgresso =
      "/telaTarefaConcluidaProgresso";
  static const String telaLixeira = "/telaLixeira";

  // constantes de parametros passsados para as telas
  static const String telaExibirConcluido = "telaConcluida";
  static const String telaExibirProgresso = "telaProgresso";
  static const String parametroDetalhesTarefa = "detalhesTarefa";
  static const String parametroDetalhesComando = "comandoTela";
  static const String telaExibirTarefaSecreta = "tarefaSecreta";
  static const String telaExibirTarefaFavorito = "tarefaFavorito";

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
  static const nomeTabelaUsuario = "usuario";

  static const bancoNomeUsuario = "nomeUsuario";
  static const bancoSenha = "senhaUsuario";
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
