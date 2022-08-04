import 'package:ciernote/Uteis/paleta_cores.dart';
import 'package:flutter/material.dart';

import '../Uteis/banco_de_dados.dart';
import '../Uteis/constantes.dart';
import '../Uteis/textos.dart';

class DadosUsuarioWidget extends StatefulWidget {
  const DadosUsuarioWidget({Key? key})
      : super(key: key);


  @override
  State<DadosUsuarioWidget> createState() => _DadosUsuarioWidgetState();
}

class _DadosUsuarioWidgetState extends State<DadosUsuarioWidget> {
  final TextEditingController _controllerNomeUsuario =
      TextEditingController(text: "");
  final TextEditingController _controllerSenhaUsuario =
      TextEditingController(text: "");
  late int idUsuario;
  bool atualizando = false;

// referencia classe para gerenciar o banco de dados
  final bancoDados = BancoDeDados.instance;
  bool ativarDesativarEditText = false;

  // metodo para inserir os dados no banco de dados
  inserirDados() async {
    // linha para incluir os dados
    Map<String, dynamic> linha = {
      BancoDeDados.columnUsuarioNome: _controllerNomeUsuario.text,
      BancoDeDados.columnUsuarioSenha: _controllerSenhaUsuario.text,
    };
    await bancoDados.inserir(linha, Constantes.nomeTabelaUsuario);
  }

  // metodo para inserir os dados no banco de dados
  atualizarDados() async {
    // linha para incluir os dados
    Map<String, dynamic> linha = {
      BancoDeDados.columnId: idUsuario,
      BancoDeDados.columnUsuarioNome: _controllerNomeUsuario.text,
      BancoDeDados.columnUsuarioSenha: _controllerSenhaUsuario.text,
    };
    await bancoDados.atualizar(linha, Constantes.nomeTabelaUsuario);
  }

  @override
  void initState() {
    super.initState();
    consultaBancoDados();
  }

  consultaBancoDados() async {
    final registros =
        await bancoDados.consultarLinhas(Constantes.nomeTabelaUsuario);
    if (registros.isNotEmpty) {
      for (var linha in registros) {
        setState(() {
          idUsuario = linha[Constantes.bancoId];
          _controllerNomeUsuario.text = linha[Constantes.bancoNomeUsuario];
          _controllerSenhaUsuario.text = linha[Constantes.bancoSenha];
        });
      }
      if (_controllerNomeUsuario.text.isNotEmpty) {
        setState(() {
          ativarDesativarEditText = true;
        });
      }
    } else {
      setState(() {
        ativarDesativarEditText = false;
        _controllerNomeUsuario.text = "";
        _controllerSenhaUsuario.text = "";
      });
    }
  }

  //variavel usada para validar o formulario
  final _chaveFormulario = GlobalKey<FormState>();

  Widget botoes(String tituloBotao, Color cor) => SizedBox(
        height: 50,
        width: 150,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            side: BorderSide(color: cor),
            primary: Colors.white,
            elevation: 5,
            shadowColor: cor,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
          ),
          onPressed: () {
            if (tituloBotao == Textos.btnSalvar) {
              if (_chaveFormulario.currentState!.validate()) {
                inserirDados();
                consultaBancoDados();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(Textos.sucessoSalvarUsuario)));
              }
            } else if (tituloBotao == Textos.btnAtualizar) {
              setState(() {
                ativarDesativarEditText = false;
                atualizando = true;
              });
            } else if (tituloBotao == Textos.btnAtualizarUsuario) {
              if (_chaveFormulario.currentState!.validate()) {
                atualizarDados();
                setState(() {
                  ativarDesativarEditText = true;
                });
                consultaBancoDados();
              }
            }
          },
          child: Text(
            tituloBotao,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      );

  Widget textFields(double larguraTela, String titutoTextField,
          TextEditingController controle,bool tipo) =>
      SizedBox(
        width: larguraTela * 0.40,
        height: 60,
        child: TextFormField(
            validator: (value) {
              if (value!.isEmpty) {
                return Textos.erroCampoVazio;
              }
              return null;
            },
            readOnly: ativarDesativarEditText,
            obscureText: tipo,
            maxLines: 1,
            keyboardType: TextInputType.text,
            controller: controle,
            decoration: InputDecoration(
              label: Text(titutoTextField),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 1, color: Colors.black),
                borderRadius: BorderRadius.circular(5),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 1, color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 2, color: Colors.red),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 1, color: Colors.black),
                borderRadius: BorderRadius.circular(5),
              ),
            )),
      );

  @override
  Widget build(BuildContext context) {
    double larguraTela = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.all(10),
      width: larguraTela,
      child: Card(
        elevation: 10,
        shadowColor: PaletaCores.corAzulCianoClaro,
        child: Column(
          children: [
            Text(
              Textos.txtTelaUsuarioLeg,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Form(
                key: _chaveFormulario,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 5.0),
                      height: 80,
                      child: textFields(larguraTela, Textos.labelUsuarioNome,
                          _controllerNomeUsuario,false),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 5.0),
                      height: 80,
                      child: textFields(larguraTela, Textos.labelUsuarioSenha,
                          _controllerSenhaUsuario,true),
                    )
                  ],
                )),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (ativarDesativarEditText) {
                      return botoes(
                          Textos.btnAtualizar, PaletaCores.corAmarela);
                    } else if (atualizando) {
                      return botoes(Textos.btnAtualizarUsuario,
                          PaletaCores.corAzulCianoClaro);
                    } else {
                      return botoes(
                          Textos.btnSalvar, PaletaCores.corVerde);
                    }
                  },
                ),
                SizedBox(
                  height: 50,
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: PaletaCores.corVermelho),
                      primary: Colors.white,
                      elevation: 5,
                      shadowColor: PaletaCores.corVermelho,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                    ),
                    onPressed: () {
                      bancoDados.excluir(
                          idUsuario, Constantes.nomeTabelaUsuario);
                      setState(() {
                        ativarDesativarEditText = false;
                        atualizando = false;
                        _controllerNomeUsuario.text = "";
                        _controllerSenhaUsuario.text = "";
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(Textos.sucessoExclusaoUsuario)));
                    },
                    child: Text(
                      Textos.btnExcluir,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
