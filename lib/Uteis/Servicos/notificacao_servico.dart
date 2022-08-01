import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import 'package:intl/intl.dart';

import '../../Modelo/notificacao_modelo.dart';
import '../constantes.dart';
import '../textos.dart';

class NotificacaoServico {
  late FlutterLocalNotificationsPlugin localNotificationsPlugin;
  TimeOfDay? hora = const TimeOfDay(hour: 19, minute: 00);
  DateTime data = DateTime(2022, 07, 02);

  NotificacaoServico() {
    localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    definirConfiguracaoNotificacao();
  }

  // metodo responsavel por formatar a hora e a data para
// o padrao especificado
  formatarDataHora(NotificacaoModelo notificacaoModelo) {
    DateTime? converterHora;
    converterHora = DateFormat("hh:mm")
        .parse(notificacaoModelo.hora); // convertendo para o formato
    converterHora = DateFormat("hh:mm a")
        .parse(notificacaoModelo.hora); // convertendo para o formato 12 horas
    TimeOfDay horaFormatar =
        TimeOfDay(hour: converterHora.hour, minute: converterHora.minute);
    hora = horaFormatar;
    data = DateFormat("dd/MM/yyyy", "pt_BR").parse(notificacaoModelo.data);
  }

  // metodo responsavel por chamar a exibicao da notificacao
  static chamarExibirNotificacao(NotificacaoModelo notificacaoModelo,
      String tipoNotificacao, BuildContext context) {
    // instaniando o provider passando a classe modelo com os parametros necessarios
    Provider.of<NotificacaoServico>(context, listen: false).exibirNotificacao(
      tipoNotificacao,
      NotificacaoModelo(
          id: notificacaoModelo.id,
          titulo: notificacaoModelo.titulo,
          corpoNotificacao: notificacaoModelo.corpoNotificacao,
          payload: notificacaoModelo.payload,
          data: notificacaoModelo.data,
          hora: notificacaoModelo.hora),
    );
  }

  // future responsavel por cancelar a notificacao
  Future<void> cancelarNotificacao(int id) async {
    await localNotificationsPlugin.cancel(id);
  }

  // metodo para chamar metodos de configuracao da notificacao
  definirConfiguracaoNotificacao() async {
    await configTimeZone();
    await iniciarNotificacao();
  }

  // future para configurar o time zone
  Future<void> configTimeZone() async {
    tz.initializeTimeZones();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Detroit'));
  }

  // metodo para iniciar a notificaco
  iniciarNotificacao() async {
    const android = AndroidInitializationSettings("@mipmap/ic_launcher");
    await localNotificationsPlugin.initialize(
      const InitializationSettings(
        android: android,
      ),
      onSelectNotification: clickNotificacao,
    );
  }

  // metodo responsavel por definir acao no click na notificacao
  clickNotificacao(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      print(payload);
    } else {
      print("Vazio ou Nulo");
    }
  }

  // metodo para exibir a notificacao de acordo com os parametros passados
  exibirNotificacao(
      String tipoNotificaco, NotificacaoModelo notificacaoModelo) async {
    // verificando se no campo especificado nao contem string
    // indicando que a notificacao sera sem horario
    if (!notificacaoModelo.hora.toString().contains(Textos.horaSemPrazo)) {
      formatarDataHora(notificacaoModelo);
    }
    // variavel com os detalhes da notificacao
    // ON GOING  verdadeiro para quando a notificacao ser ativada ela
    // ela nao poder ser removida deslizando

    var androidDetalhes = const AndroidNotificationDetails(
      "lembrete_notificacao",
      Constantes.canalNotificacaoPadrao,
      priority: Priority.max,
      importance: Importance.high,
      autoCancel: false,
      ongoing: true,
      onlyAlertOnce: true,
      enableVibration: true,
      enableLights: true,
    );
    if (tipoNotificaco.contains(Constantes.tipoNotiAgendada)) {
      // definindo que a variavel vai receber a
      // DIFERENCA entre o horario atual do dispositivo
      // e o horario e a data salvo no banco de dados
      Duration diferencaHora = tz.TZDateTime.now(tz.local).difference(
          DateTime(data.year, data.month, data.day, hora!.hour, hora!.minute));
      // verificando se a variavel contem valor com sinal de negativo
      if (diferencaHora.inSeconds.toString().contains("-")) {
        diferencaHora = -(diferencaHora);
      }
      await localNotificationsPlugin.zonedSchedule(
          notificacaoModelo.id,
          notificacaoModelo.titulo,
          notificacaoModelo.corpoNotificacao,
          payload: "",
          tz.TZDateTime.now(tz.local)
              .add(Duration(seconds: diferencaHora.inSeconds)),
          NotificationDetails(android: androidDetalhes),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    } else {
      await localNotificationsPlugin.show(
          notificacaoModelo.id,
          notificacaoModelo.titulo,
          notificacaoModelo.corpoNotificacao,
          NotificationDetails(android: androidDetalhes),
          payload: notificacaoModelo.payload);
    }
  }

  // metodo para verificar notificacoes quando o aplicativo for destruido
  // e houver o click sobre a notificacao
  verificarNotificacoes() async {
    final detalhes =
        await localNotificationsPlugin.getNotificationAppLaunchDetails();
    if (detalhes != null && detalhes.didNotificationLaunchApp) {
      clickNotificacao(detalhes.payload);
    }
  }
}
