class NotificacaoModelo {
  final int id;
  final String titulo;
  final String corpoNotificacao;
  final dynamic data;
  final dynamic hora;
  final String payload;

  NotificacaoModelo(
      {required this.id,
      required this.titulo,
      required this.corpoNotificacao,
      required this.data,
      required this.hora,
      required this.payload});
}
