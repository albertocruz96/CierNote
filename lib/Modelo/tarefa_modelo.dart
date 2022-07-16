class TarefaModelo {
  TarefaModelo(
      {required this.titulo,
      required this.id,
      required this.conteudo,
      required this.data,
      required this.hora,
      required this.favorito,
      required this.status,
      required this.corTarefa});

  int id;
  String titulo;
  String conteudo;
  dynamic data;
  dynamic hora;
  dynamic status;
  dynamic corTarefa;
  bool favorito;
}
