import 'dart:math';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms/api/api_sms.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _telefone = TextEditingController();
  bool _enviado = false;
  String codigoConfirmacao = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar número de telefone'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _telefone,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TelefoneInputFormatter(),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_telefone.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Informe o telefone'),
                        duration: Duration(seconds: 2),
                      ));
                      return;
                    }

                    String numero =
                        '+55${UtilBrasilFields.obterTelefone(_telefone.text, mascara: false)}';

                    codigoConfirmacao = generateCode();

                    try {
                      ApiSMS().sendSMS(
                        to: numero,
                        bodyMsg: 'Código de confirmação: $codigoConfirmacao',
                      );

                      setState(() {
                        _enviado = true;
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$e'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text('Enviar'),
                ),
              ],
            ),
            const SizedBox(height: 50),
            if (_enviado)
              Row(
                children: [
                  Expanded(
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Código de confirmação',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o código de confirmação';
                          }

                          if (value != codigoConfirmacao) {
                            return 'Código de confirmação inválido';
                          }

                          if (value == codigoConfirmacao) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Código de confirmação válido'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }

                          return null;
                        },
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _formKey.currentState?.validate();
                    },
                    child: const Text('Confirmar'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String generateCode() {
    Random random = Random();
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += random.nextInt(10).toString();
    }
    return code;
  }
}
