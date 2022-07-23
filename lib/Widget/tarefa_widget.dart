import 'package:ciernote/Modelo/tarefa_modelo.dart';
import 'package:flutter/material.dart';
import '../Uteis/constantes.dart';

class TarefaWidget extends StatefulWidget {
  const TarefaWidget({Key? key, required this.item}) : super(key: key);

  final TarefaModelo item;

  @override
  State<TarefaWidget> createState() => _TarefaWidgetState();
}

class _TarefaWidgetState extends State<TarefaWidget> {
  @override
  Widget build(BuildContext context) {
    double larguraTela = MediaQuery.of(context).size.width;
    return Container(
        margin: const EdgeInsets.all(5),
        width: 220,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: widget.item.corTarefa,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30))),
            ),
            onPressed: () {
              var dadosTela = {};
              dadosTela[Constantes.telaParametroDetalhes] = widget.item;
              Navigator.pushReplacementNamed(context, Constantes.telaTarefaDetalhada,
                  arguments: dadosTela);
            },
            child: SizedBox(
              width: 220,
              child: Column(
                children: [
                  SizedBox(
                      width: 220,
                      height: 35,
                      child: Text(widget.item.titulo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                          )
                      )),
                  Container(
                    margin: const EdgeInsets.only(
                        top: 0.0, right: 0.0, bottom: 0.0, left: 0.0),
                    width: larguraTela,
                    height: 90,
                    child: Text(widget.item.conteudo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20,color: Colors.black)),
                  ),
                  SizedBox(
                    height: 46,
                    width: 220,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.access_time_filled,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 5),
                            Text(
                              widget.item.hora,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_month,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 5),
                                Text(
                                  widget.item.data,
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),

                              ],
                            ),
                            SizedBox(
                              width: 30,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  if (widget.item.favorito) {
                                    return const Icon(
                                      Icons.favorite_outlined,
                                      size: 20,
                                      color: Colors.white,
                                    );
                                  } else {
                                    return const Icon(
                                      Icons.favorite_border_outlined,
                                      size: 20,
                                      color: Colors.white,
                                    );
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )));
  }
}
