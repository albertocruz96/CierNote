class TarefaModelo {
  TarefaModelo(
      {required this.id,
      required this.titulo,
      required this.conteudo,
      required this.data,
      required this.hora,
      this.favorito = false,
      this.notificacaoAtiva = false,
      required this.status,
      required this.corTarefa,
      this.tarefaSecreta = false});

  int id;
  String titulo;
  String conteudo;
  dynamic data;
  dynamic hora;
  dynamic status;
  dynamic corTarefa;
  bool favorito;
  bool notificacaoAtiva;
  bool tarefaSecreta;
}
